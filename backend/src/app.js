const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const routes = require('./routes');
const { errorHandler } = require('./middleware/errorHandler');
const { apiLimiter } = require('./middleware/rateLimitMiddleware');

const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./config/swagger');
const { metricsMiddleware, requestLogger, register } = require('./middleware/monitoringMiddleware');

const app = express();

// Security Middleware
app.use(helmet());
app.use(cors());
app.use(apiLimiter);

// Monitoring & Logging
app.use(metricsMiddleware);
app.use(requestLogger); // JSON logging for Splunk

// Documentation
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs));

// Metrics Endpoint (Prometheus)
app.get('/metrics', async (req, res) => {
    res.setHeader('Content-Type', register.contentType);
    res.send(await register.metrics());
});

// Request Parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging (Removed morgan in favor of custom JSON logger)
// app.use(morgan('combined', { stream: logger.stream }));

// API Routes (Version 1)
// Unified routing for the discovery engine
app.use('/api/v1', routes);

// Also mount /api for convenience (redirecting or just alias)
app.use('/api', routes);

// 404 Handler
app.use((req, res, next) => {
  const error = new Error(`Route not found: ${req.originalUrl}`);
  error.statusCode = 404;
  error.status = 'fail';
  next(error);
});

// Global Error Handler
app.use(errorHandler);

module.exports = app;
