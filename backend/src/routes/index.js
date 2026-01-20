const express = require('express');
const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');
const recommendationRoutes = require('./recommendationRoutes');
const interactionRoutes = require('./interactionRoutes');

const router = express.Router();

const healthController = require('../controllers/healthController');

// ... existing code ...

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/recommendations', recommendationRoutes);
router.use('/interactions', interactionRoutes);

router.get('/health', healthController.checkHealth);

module.exports = router;
