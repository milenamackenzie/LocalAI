require('dotenv').config();
const app = require('./app');
const logger = require('./utils/logger');
const db = require('./database/connection');
const migrator = require('./database/migrator');

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // 1. Connect to Database
    await db.connect();
    
    // 2. Run Migrations
    await migrator.run();

    // 3. Start Server
    const server = app.listen(PORT, () => {
      logger.info(`Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode`);
    });

    // Graceful Shutdown
    process.on('SIGTERM', async () => {
      logger.info('SIGTERM signal received: closing HTTP server');
      server.close(async () => {
        logger.info('HTTP server closed');
        await db.close();
        process.exit(0);
      });
    });

  } catch (err) {
    logger.error('Failed to start server:', err);
    process.exit(1);
  }
}

startServer();
