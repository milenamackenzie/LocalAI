const path = require('path');
const db = require('../src/database/connection');
const migrator = require('../src/database/migrator');
const logger = require('../src/utils/logger');
const queueService = require('../src/services/queueService');

// Silence logger during tests
logger.transports.forEach((t) => (t.silent = true));

// Set Test DB Path
process.env.DB_PATH = path.resolve(__dirname, '../localai_test.db');
process.env.JWT_SECRET = 'test-secret-key';
process.env.NODE_ENV = 'test';

beforeAll(async () => {
  // Clean up any existing test db
  await db.connect();
  await migrator.run();
});

afterAll(async () => {
  await db.close();
  await queueService.close();
  // Optional: Delete test db file
  const fs = require('fs');
  if (fs.existsSync(process.env.DB_PATH)) {
    fs.unlinkSync(process.env.DB_PATH);
  }
});

// Helper to clear tables between tests if needed
global.clearDb = async () => {
  await db.run('DELETE FROM user_preferences');
  await db.run('DELETE FROM recommendations');
  await db.run('DELETE FROM user_interactions');
  await db.run('DELETE FROM users');
};
