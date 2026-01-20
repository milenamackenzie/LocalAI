const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const logger = require('../utils/logger');

const dbPath = process.env.DB_PATH || path.resolve(__dirname, '../../localai.db');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    logger.error('Error opening database ' + dbPath + ': ' + err.message);
  } else {
    logger.info('Connected to the SQLite database.');
    initDb();
  }
});

function initDb() {
  db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT,
      role TEXT DEFAULT 'user',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
    
    // Add other tables here
  });
}

module.exports = db;
