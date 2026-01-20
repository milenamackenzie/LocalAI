const { body } = require('express-validator');

exports.interactionValidators = [
    body('interactionType')
        .trim()
        .notEmpty().withMessage('Interaction type is required')
        .isIn(['view', 'click', 'like', 'dismiss', 'search', 'bookmark', 'share'])
        .withMessage('Invalid interaction type'),
    
    body('itemId')
        .trim()
        .notEmpty().withMessage('Item ID is required')
        .escape(),
        
    body('itemType')
        .trim()
        .notEmpty().withMessage('Item type is required')
        .isIn(['place', 'event', 'article', 'ad'])
        .withMessage('Invalid item type'),
        
    body('data')
        .optional()
        .isObject().withMessage('Data must be a JSON object')
];
