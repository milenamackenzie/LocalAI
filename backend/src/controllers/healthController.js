const db = require('../database/connection');
const aiService = require('../services/aiService');
const os = require('os');

exports.checkHealth = async (req, res) => {
    const healthCheck = {
        status: 'UP',
        timestamp: new Date(),
        version: process.env.npm_package_version || '1.0.0',
        system: {
            uptime: process.uptime(),
            load: os.loadavg(),
            freeMemory: os.freemem(),
            totalMemory: os.totalmem(),
        },
        services: {
            database: { status: 'PENDING' },
            ai_model: { status: aiService.state || 'UNKNOWN' }
        }
    };

    try {
        // Database Check
        await db.get('SELECT 1');
        healthCheck.services.database.status = 'UP';
    } catch (e) {
        healthCheck.services.database.status = 'DOWN';
        healthCheck.services.database.error = e.message;
        healthCheck.status = 'PARTIAL_OUTAGE';
    }

    // Overall status check
    const isDown = Object.values(healthCheck.services).some(s => s.status === 'DOWN');
    if (isDown) healthCheck.status = 'DOWN';

    const statusCode = healthCheck.status === 'UP' ? 200 : (healthCheck.status === 'PARTIAL_OUTAGE' ? 200 : 503);
    res.status(statusCode).json(healthCheck);
};

