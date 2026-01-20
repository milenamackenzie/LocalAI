const logger = require('../utils/logger');

const isAdmin = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        next();
    } else {
        logger.warn(`Access denied. User ${req.user ? req.user.id : 'unknown'} attempted to access admin route.`);
        res.status(403).json({ success: false, message: 'Access denied. Admin privileges required.' });
    }
};

module.exports = isAdmin;
