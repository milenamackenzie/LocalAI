const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');
const AppError = require('../utils/AppError');

const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new AppError('Access denied. No token provided or invalid format.', 401, 'UNAUTHORIZED'));
  }

  const token = authHeader.split(' ')[1];

  try {
    const secret = process.env.JWT_SECRET || 'fallback_secret_for_dev_only';
    const decoded = jwt.verify(token, secret);
    
    // Attach user info to request
    req.user = decoded;
    next();
  } catch (err) {
    logger.warn(`Authentication failed: ${err.message}`);
    return next(new AppError('Invalid or expired token.', 401, 'UNAUTHORIZED'));
  }
};

module.exports = authenticate;
