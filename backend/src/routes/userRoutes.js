const express = require('express');
const authController = require('../controllers/authController');
const authenticate = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/profile', authenticate, authController.getProfile);

module.exports = router;
