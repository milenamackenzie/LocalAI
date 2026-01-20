const express = require('express');
const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');
const recommendationRoutes = require('./recommendationRoutes');
const interactionRoutes = require('./interactionRoutes');

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/recommendations', recommendationRoutes);
router.use('/interactions', interactionRoutes);

router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    status: 'UP',
    timestamp: new Date(),
    uptime: process.uptime()
  });
});

module.exports = router;
