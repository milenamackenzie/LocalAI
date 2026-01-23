const { body, query } = require('express-validator');

// ... existing chains ...
const emailChain = () => body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Invalid email format')
    .normalizeEmail();

const passwordChain = () => body('password')
    .notEmpty().withMessage('Password is required')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/[A-Z]/).withMessage('Password must contain at least one uppercase letter')
    .matches(/[a-z]/).withMessage('Password must contain at least one lowercase letter')
    .matches(/[0-9]/).withMessage('Password must contain at least one number')
    .matches(/[\W_]/).withMessage('Password must contain at least one special character');

const usernameChain = () => body('username')
    .trim()
    .notEmpty().withMessage('Username is required')
    .isLength({ min: 3, max: 30 }).withMessage('Username must be between 3 and 30 characters')
    .matches(/^[a-zA-Z0-9_]+$/).withMessage('Username can only contain letters, numbers, and underscores')
    .escape();

exports.registerValidators = [
    usernameChain(),
    emailChain(),
    passwordChain()
];

exports.loginValidators = [
    body('email').trim().notEmpty().isEmail(),
    body('password').notEmpty()
];

exports.refreshTokenValidators = [
    body('refreshToken').notEmpty().withMessage('Refresh Token is required')
];

exports.verifyEmailValidators = [
    query('token').notEmpty().withMessage('Verification token is required')
];

exports.forgotPasswordValidators = [
    body('email').trim().notEmpty().isEmail()
];

exports.resetPasswordValidators = [
    body('token').notEmpty().withMessage('Reset token is required'),
    body('newPassword').isLength({ min: 8 }).withMessage('Password must be at least 8 chars')
      .matches(/[A-Z]/).matches(/[a-z]/).matches(/[0-9]/).matches(/[\W_]/)
];
