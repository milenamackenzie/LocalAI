const { body } = require('express-validator');

exports.generateRecommendationValidators = [
    body('context')
        .optional()
        .trim()
        .isLength({ max: 500 }).withMessage('Context must not exceed 500 characters')
        .escape(), // Basic sanitization for prompt inputs
    
    body('location')
        .optional()
        .isObject().withMessage('Location must be an object')
        .custom((loc) => {
            if (loc && (typeof loc.lat !== 'number' || typeof loc.lng !== 'number')) {
                throw new Error('Location must have numeric lat and lng properties');
            }
            return true;
        })
];
