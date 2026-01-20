const { body, query } = require('express-validator');

exports.updateProfileValidators = [
    body('username')
        .optional()
        .trim()
        .isLength({ min: 3, max: 30 })
        .matches(/^[a-zA-Z0-9_]+$/).withMessage('Username must be alphanumeric'),
    
    body('email')
        .optional()
        .trim()
        .isEmail().withMessage('Invalid email format')
        .normalizeEmail()
];

exports.changePasswordValidators = [
    body('currentPassword').notEmpty().withMessage('Current password is required'),
    body('newPassword')
        .isLength({ min: 8 }).withMessage('New password must be at least 8 chars')
        .matches(/[A-Z]/).matches(/[0-9]/).withMessage('New password too weak')
];

exports.updatePreferencesValidators = [
    body('preferences').isArray().withMessage('Preferences must be an array of objects'),
    body('preferences.*.category').notEmpty(),
    body('preferences.*.value').notEmpty()
];

exports.searchUserValidators = [
    query('q').optional().trim().escape(),
    query('role').optional().isIn(['user', 'admin']),
    query('limit').optional().isInt({ min: 1, max: 100 }).toInt(),
    query('page').optional().isInt({ min: 1 }).toInt()
];
