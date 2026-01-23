const client = require('prom-client');
const responseTime = require('response-time');
const logger = require('../utils/logger');

// Create a Registry
const register = new client.Registry();

// Add default metrics (CPU, Memory, etc.)
client.collectDefaultMetrics({ register });

// Custom Metrics
const httpRequestDurationMicroseconds = new client.Histogram({
  name: 'http_request_duration_ms',
  help: 'Duration of HTTP requests in ms',
  labelNames: ['method', 'route', 'code'],
  buckets: [0.1, 5, 15, 50, 100, 200, 300, 400, 500, 1000, 3000],
});

const dbOperationDuration = new client.Histogram({
    name: 'db_operation_duration_ms',
    help: 'Duration of Database operations in ms',
    labelNames: ['operation', 'table'],
    buckets: [1, 5, 10, 50, 100, 500, 1000],
});

register.registerMetric(httpRequestDurationMicroseconds);
register.registerMetric(dbOperationDuration);

// Middleware to track request duration
const metricsMiddleware = responseTime((req, res, time) => {
  if (req.route) {
    httpRequestDurationMicroseconds.labels(req.method, req.route.path, res.statusCode).observe(time);
  }
});

// Middleware for detailed request logging (Splunk friendly)
const requestLogger = (req, res, next) => {
    const start = Date.now();
    res.on('finish', () => {
        const duration = Date.now() - start;
        logger.info({
            type: 'access_log',
            method: req.method,
            url: req.originalUrl,
            status: res.statusCode,
            duration,
            ip: req.ip,
            userId: req.user ? req.user.id : null,
            userAgent: req.get('user-agent')
        });
    });
    next();
};

module.exports = {
    metricsMiddleware,
    requestLogger,
    register,
    dbOperationDuration
};
