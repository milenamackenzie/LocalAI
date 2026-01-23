const logger = require('../utils/logger');

exports.errorHandler = (err, req, res, _next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';
  err.errorCode = err.errorCode || 'INTERNAL_ERROR';

  logger.error({
    message: err.message,
    stack: err.stack,
    errorCode: err.errorCode,
    path: req.originalUrl,
    method: req.method
  });

  if (process.env.NODE_ENV === 'development') {
    res.status(err.statusCode).json({
      success: false,
      status: err.status,
      errorCode: err.errorCode,
      message: err.message,
      stack: err.stack
    });
  } else {
    res.status(err.statusCode).json({
      success: false,
      status: err.status,
      errorCode: err.errorCode,
      message: err.statusCode === 500 ? 'Something went very wrong!' : err.message
    });
  }
};
