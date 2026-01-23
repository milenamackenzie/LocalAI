const express = require('express');
const recommendationController = require('../controllers/recommendationController');
const authenticate = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { body, param, query } = require('express-validator');

const router = express.Router();

router.use(authenticate);

// List
router.get(
    '/',
    [
        query('category').optional().trim().escape(),
        query('limit').optional().isInt({ min: 1, max: 50 }),
        query('page').optional().isInt({ min: 1 }),
        validate
    ],
    recommendationController.getRecommendations
);

// Generate
router.post(
  '/generate',
  [
    body('context').optional().isString().trim().isLength({ max: 500 }),
    validate
  ],
  recommendationController.generateRecommendations
);

// Analytics
router.get('/analytics', recommendationController.getAnalytics);

// Specific Item Operations
router.get('/:id', recommendationController.getRecommendationById);

router.put(
    '/:id/feedback',
    [
        param('id').isInt(),
        body('feedback').isIn(['liked', 'disliked', 'none']),
        validate
    ],
    recommendationController.updateFeedback
);

router.delete(
    '/:id',
    [param('id').isInt(), validate],
    recommendationController.deleteRecommendation
);

module.exports = router;
