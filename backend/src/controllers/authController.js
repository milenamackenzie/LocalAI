const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/userRepository');
const logger = require('../utils/logger');

exports.register = async (req, res, next) => {
  try {
    const { username, email, password } = req.body;

    // Check if user exists
    const existingUser = await userRepository.findByEmail(email);
    if (existingUser) {
      return res.status(409).json({ success: false, message: 'Email already registered' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await userRepository.create({ username, email, passwordHash });

    logger.info(`New user registered: ${user.id} (${email})`);

    // Generate Token
    const token = generateToken(user);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        token,
        user: user.toJSON()
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await userRepository.findByEmail(email);
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const isMatch = await user.verifyPassword(password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const token = generateToken(user);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: user.toJSON()
      }
    });
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
    
    // Remove password hash
    delete user.password_hash;
    
    res.status(200).json({
      success: true,
      data: user
    });
  } catch (err) {
    next(err);
  }
};

function generateToken(user) {
  const secret = process.env.JWT_SECRET || 'fallback_secret_for_dev_only';
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    secret,
    { expiresIn: '24h' }
  );
}
