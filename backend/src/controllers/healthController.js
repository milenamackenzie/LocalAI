const db = require('../database/connection');
const logger = require('../utils/logger');

exports.checkHealth = async (req, res) => {
    const healthCheck = {
        status: 'UP',
        timestamp: new Date(),
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        dbStatus: 'UNKNOWN'
    };

    try {
        await db.get('SELECT 1');
        healthCheck.dbStatus = 'CONNECTED';
    } catch (e) {
        healthCheck.dbStatus = 'DISCONNECTED';
        healthCheck.status = 'DOWN';
        healthCheck.error = e.message;
        res.status(503);
    }

    res.json(healthCheck);
};
