const { body, param, query } = require('express-validator');

// Reusable validation chains
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
    body('email')
        .trim()
        .notEmpty().withMessage('Email is required')
        .isEmail().withMessage('Invalid email format')
        .normalizeEmail(),
    body('password').notEmpty().withMessage('Password is required')
];

exports.updateProfileValidators = [
    body('username')
        .optional()
        .trim()
        .isLength({ min: 3, max: 30 })
        .matches(/^[a-zA-Z0-9_]+$/)
        .escape(),
    body('email')
        .optional()
        .trim()
        .isEmail()
        .normalizeEmail()
];

exports.changePasswordValidators = [
    body('currentPassword').notEmpty().withMessage('Current password is required'),
    body('newPassword')
        .notEmpty().withMessage('New password is required')
        .isLength({ min: 8 }).withMessage('New password must be at least 8 characters')
        .matches(/[A-Z]/).withMessage('Must contain uppercase')
        .matches(/[a-z]/).withMessage('Must contain lowercase')
        .matches(/[0-9]/).withMessage('Must contain number')
        .matches(/[\W_]/).withMessage('Must contain special char')
        .custom((value, { req }) => {
            if (value === req.body.currentPassword) {
                throw new Error('New password must be different from current password');
            }
            return true;
        })
];
