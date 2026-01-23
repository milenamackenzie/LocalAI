const express = require('express');
const interactionController = require('../controllers/interactionController');
const { interactionValidators } = require('../validators/interactionValidator');
const authenticate = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');

const router = express.Router();

router.post(
  '/',
  authenticate,
  interactionValidators,
  validate,
  interactionController.logInteraction
);

module.exports = router;
