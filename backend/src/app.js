const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const logger = require('./utils/logger');
const routes = require('./routes');
const { errorHandler } = require('./middleware/errorHandler');
const { apiLimiter } = require('./middleware/rateLimitMiddleware');

const app = express();

// Security Middleware
app.use(helmet());
app.use(cors());
app.use(apiLimiter); // Apply rate limiting globally

// Request Parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging
app.use(morgan('combined', { stream: logger.stream }));

// API Routes (Version 1)
app.use('/api/v1', routes);
// Also mount /api for convenience (redirecting or just alias)
app.use('/api', routes);

// 404 Handler
app.use((req, res, next) => {
  const error = new Error(`Route not found: ${req.originalUrl}`);
  error.status = 404;
  next(error);
});

// Global Error Handler
app.use(errorHandler);

module.exports = app;
