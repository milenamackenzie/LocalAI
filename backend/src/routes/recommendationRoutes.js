const express = require('express');
const recommendationController = require('../controllers/recommendationController');
const { generateRecommendationValidators } = require('../validators/recommendationValidator');
const authenticate = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');

const router = express.Router();

router.get('/', authenticate, recommendationController.getRecommendations);

router.post(
  '/generate',
  authenticate,
  generateRecommendationValidators,
  validate,
  recommendationController.generateRecommendations
);

module.exports = router;
