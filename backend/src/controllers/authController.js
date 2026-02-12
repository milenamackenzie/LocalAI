const crypto = require('crypto');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/userRepository');
const refreshTokenRepository = require('../repositories/refreshTokenRepository');
const logger = require('../utils/logger');

// Constants
const SALT_ROUNDS = 12; // Increased security
const ACCESS_TOKEN_EXPIRY = '15m';
const REFRESH_TOKEN_EXPIRY_DAYS = 7;
const MAX_LOGIN_ATTEMPTS = 5;
const LOCKOUT_TIME_MS = 15 * 60 * 1000; // 15 minutes

// Helper: Generate Random Token
const generateRandomToken = () => crypto.randomBytes(32).toString('hex');

// Helper: Generate Access Token
const generateAccessToken = (user) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET environment variable is required');
  }
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: ACCESS_TOKEN_EXPIRY }
  );
};

// Helper: Generate Refresh Token
const generateRefreshToken = async (user) => {
    const token = generateRandomToken();
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_EXPIRY_DAYS);
    
    await refreshTokenRepository.create(user.id, token, expiresAt);
    return token;
};

exports.register = async (req, res, next) => {
  try {
    const { username, email, password } = req.body;

    const existingUser = await userRepository.findByEmail(email);
    if (existingUser) {
      return res.status(409).json({ success: false, message: 'Email already registered' });
    }

    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
    const verificationToken = generateRandomToken();
    
    const user = await userRepository.create({ username, email, passwordHash, verificationToken });

    logger.info(`New user registered: ${user.id} (${email})`);

    // Automatically generate tokens for immediate login after registration
    const accessToken = generateAccessToken(user);
    const refreshToken = await generateRefreshToken(user);
    
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        accessToken,
        refreshToken,
        user: user.toJSON(),
        
      }
    });

  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, username, password } = req.body;

    // Allow login with either email or username
    let user;
    if (email) {
      user = await userRepository.findByEmail(email);
    } else if (username) {
      // Check if username is an email format
      if (username.includes('@')) {
        user = await userRepository.findByEmail(username);
      } else {
        user = await userRepository.findByUsername(username);
      }
    }

    if (!user) {
      // Fake delay to prevent timing attacks
      await bcrypt.compare(password, '$2b$12$...'); 
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // Check Lockout
    if (user.isLocked()) {
        const remaining = Math.ceil((user.lockoutUntil - new Date()) / 1000 / 60);
        return res.status(423).json({ 
            success: false, 
            message: `Account is locked. Try again in ${remaining} minutes.` 
        });
    }

    const isMatch = await user.verifyPassword(password);
    if (!isMatch) {
        await userRepository.incrementLoginAttempts(user.id);
        if (user.failedLoginAttempts + 1 >= MAX_LOGIN_ATTEMPTS) {
            const lockoutUntil = new Date(Date.now() + LOCKOUT_TIME_MS);
            await userRepository.lockoutUser(user.id, lockoutUntil);
            logger.warn(`User ${user.id} locked out due to too many failed attempts`);
        }
        return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // Reset lockout on success
    if (user.failedLoginAttempts > 0) {
        await userRepository.resetLoginAttempts(user.id);
    }

    // Generate Tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = await generateRefreshToken(user);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        accessToken,
        refreshToken,
        user: user.toJSON()
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.refreshToken = async (req, res, next) => {
    try {
        const { refreshToken } = req.body;
        
        const storedToken = await refreshTokenRepository.findByToken(refreshToken);
        if (!storedToken || storedToken.revoked || new Date(storedToken.expires_at) < new Date()) {
            return res.status(401).json({ success: false, message: 'Invalid or expired refresh token' });
        }

        // Token Rotation: Revoke old, issue new
        await refreshTokenRepository.revoke(refreshToken);
        
        const user = await userRepository.findById(storedToken.user_id);
        const newAccessToken = generateAccessToken(user);
        const newRefreshToken = await generateRefreshToken(user);

        res.status(200).json({
            success: true,
            data: {
                accessToken: newAccessToken,
                refreshToken: newRefreshToken
            }
        });

    } catch (err) {
        next(err);
    }
};

exports.logout = async (req, res, next) => {
    try {
        const { refreshToken } = req.body;
        if (refreshToken) {
            await refreshTokenRepository.revoke(refreshToken);
        }
        res.status(200).json({ success: true, message: 'Logged out successfully' });
    } catch (err) {
        next(err);
    }
};

exports.verifyEmail = async (req, res, next) => {
    try {
        const { token } = req.query; // GET /verify-email?token=...
        const user = await userRepository.findByVerificationToken(token);
        
        if (!user) {
            return res.status(400).json({ success: false, message: 'Invalid verification token' });
        }

        await userRepository.markVerified(user.id);
        res.status(200).json({ success: true, message: 'Email verified successfully' });
    } catch (err) {
        next(err);
    }
};

exports.forgotPassword = async (req, res, next) => {
    try {
        const { email } = req.body;
        const user = await userRepository.findByEmail(email);
        
        if (user) {
            const resetToken = generateRandomToken();
            const expiresAt = new Date(Date.now() + 3600000); // 1 hour
            await userRepository.setResetToken(user.id, resetToken, expiresAt);
            
logger.info(`Password reset requested for ${email}`);
            // Send email logic here...
            
            return res.status(200).json({ success: true, message: 'If that email exists, a reset link has been sent' });
        }
        
        // Always return 200 to prevent user enumeration
        res.status(200).json({ success: true, message: 'If that email exists, a reset link has been sent' });
    } catch (err) {
        next(err);
    }
};

exports.resetPassword = async (req, res, next) => {
    try {
        const { token, newPassword } = req.body;
        const user = await userRepository.findByResetToken(token);
        
        if (!user) {
            return res.status(400).json({ success: false, message: 'Invalid or expired reset token' });
        }

        const passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
        await userRepository.updatePassword(user.id, passwordHash);

        // Optional: Revoke all refresh tokens on password change
        await refreshTokenRepository.revokeAllForUser(user.id);

        res.status(200).json({ success: true, message: 'Password has been reset' });
    } catch (err) {
        next(err);
    }
};

exports.getProfile = async (req, res, next) => {
  try {
    const user = await userRepository.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.status(200).json({
      success: true,
      data: user.toJSON()
    });
  } catch (err) {
    next(err);
  }
};
