const { body } = require('express-validator');

exports.preferenceValidators = [
    body('category')
        .trim()
        .notEmpty().withMessage('Category is required')
        .isLength({ min: 2, max: 50 })
        .matches(/^[a-zA-Z0-9-]+$/).withMessage('Category must be alphanumeric (hyphens allowed)'),
        
    body('value')
        .notEmpty().withMessage('Value is required')
        // Value validation depends on specific category logic, usually handled in controller/model
        // But we ensure it's not massive
        .custom(val => {
            const strVal = typeof val === 'object' ? JSON.stringify(val) : String(val);
            if (strVal.length > 1000) {
                throw new Error('Preference value is too large');
            }
            return true;
        })
];
