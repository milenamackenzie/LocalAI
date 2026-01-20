const express = require('express');
const authController = require('../controllers/authController');
const validate = require('../middleware/validate');
const { authLimiter } = require('../middleware/rateLimitMiddleware');
const authValidator = require('../validators/authValidator');

const router = express.Router();

// Public Routes
router.post(
  '/register',
  authLimiter,
  authValidator.registerValidators,
  validate,
  authController.register
);

router.post(
  '/login',
  authLimiter,
  authValidator.loginValidators,
  validate,
  authController.login
);

router.post(
    '/refresh',
    authValidator.refreshTokenValidators,
    validate,
    authController.refreshToken
);

router.post(
    '/logout',
    authValidator.refreshTokenValidators, // expects refreshToken in body to revoke it
    validate,
    authController.logout
);

router.post(
    '/forgot-password',
    authLimiter,
    authValidator.forgotPasswordValidators,
    validate,
    authController.forgotPassword
);

router.post(
    '/reset-password',
    authLimiter,
    authValidator.resetPasswordValidators,
    validate,
    authController.resetPassword
);

router.get(
    '/verify-email',
    authValidator.verifyEmailValidators,
    validate,
    authController.verifyEmail
);

module.exports = router;
