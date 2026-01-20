const rateLimit = require('express-rate-limit');

const skipIfTest = (req, res) => process.env.NODE_ENV === 'test';

exports.authLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 5, // 5 requests per minute
    message: { success: false, message: 'Too many login attempts, please try again later.' },
    standardHeaders: true,
    legacyHeaders: false,
    skip: skipIfTest
});

exports.apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100,
    message: { success: false, message: 'Too many requests, please try again later.' },
    skip: skipIfTest
});
