const express = require('express');
const reviewController = require('../controllers/reviewController');
const authenticate = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const { body, param } = require('express-validator');

const router = express.Router();

// Get reviews for a location
router.get(
  '/locations/:locationId/reviews',
  [
    param('locationId').notEmpty(),
    validate
  ],
  reviewController.getReviews
);

// Submit a review
router.post(
  '/reviews',
  authenticate,
  [
    body('locationId').notEmpty(),
    body('rating').isInt({ min: 1, max: 5 }),
    body('comment').optional().isString().trim(),
    validate
  ],
  reviewController.submitReview
);

module.exports = router;
