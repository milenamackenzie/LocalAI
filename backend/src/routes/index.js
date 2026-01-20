const express = require('express');
const router = express.Router();

// Import route modules
// const authRoutes = require('./authRoutes');
// router.use('/auth', authRoutes);

router.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', timestamp: new Date() });
});

module.exports = router;
