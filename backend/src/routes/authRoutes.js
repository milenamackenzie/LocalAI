const express = require('express');
const authController = require('../controllers/authController');
const { registerValidators, loginValidators } = require('../validators/authValidator');
const validate = require('../middleware/validate');

const router = express.Router();

// Register
router.post(
  '/register',
  registerValidators,
  validate,
  authController.register
);

// Login
router.post(
  '/login',
  loginValidators,
  validate,
  authController.login
);

module.exports = router;
