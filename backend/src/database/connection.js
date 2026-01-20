const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const logger = require('../utils/logger');

class Database {
  constructor() {
    this.dbPath = process.env.DB_PATH || path.resolve(__dirname, '../../localai.db');
    this.db = null;
  }

  connect() {
    return new Promise((resolve, reject) => {
      this.db = new sqlite3.Database(this.dbPath, (err) => {
        if (err) {
          logger.error(`Failed to connect to database: ${err.message}`);
          reject(err);
        } else {
          logger.info(`Connected to SQLite database at ${this.dbPath}`);
          // Enable Foreign Keys
          this.db.run('PRAGMA foreign_keys = ON;', (pragmaErr) => {
             if (pragmaErr) {
                 logger.error(`Failed to enable foreign keys: ${pragmaErr.message}`);
                 reject(pragmaErr);
             } else {
                 resolve(this);
             }
          });
        }
      });
    });
  }

  // Run a query that returns no rows (INSERT, UPDATE, DELETE, CREATE)
  run(sql, params = []) {
    return new Promise((resolve, reject) => {
      if (!this.db) return reject(new Error('Database not connected'));
      
      this.db.run(sql, params, function(err) {
        if (err) {
          logger.error(`SQL Error [RUN]: ${err.message} | Query: ${sql}`);
          reject(err);
        } else {
          // 'this' refers to the statement context here, containing lastID and changes
          resolve({ id: this.lastID, changes: this.changes });
        }
      });
    });
  }

  // Get a single row (SELECT ... LIMIT 1)
  get(sql, params = []) {
    return new Promise((resolve, reject) => {
      if (!this.db) return reject(new Error('Database not connected'));

      this.db.get(sql, params, (err, row) => {
        if (err) {
          logger.error(`SQL Error [GET]: ${err.message} | Query: ${sql}`);
          reject(err);
        } else {
          resolve(row);
        }
      });
    });
  }

  // Get all rows
  all(sql, params = []) {
    return new Promise((resolve, reject) => {
      if (!this.db) return reject(new Error('Database not connected'));

      this.db.all(sql, params, (err, rows) => {
        if (err) {
          logger.error(`SQL Error [ALL]: ${err.message} | Query: ${sql}`);
          reject(err);
        } else {
          resolve(rows);
        }
      });
    });
  }

  // Execute a script (multiple statements, useful for migrations)
  exec(sql) {
    return new Promise((resolve, reject) => {
      if (!this.db) return reject(new Error('Database not connected'));

      this.db.exec(sql, (err) => {
        if (err) {
          logger.error(`SQL Error [EXEC]: ${err.message}`);
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }

  // Transaction Helpers
  async transaction(callback) {
    await this.run('BEGIN TRANSACTION');
    try {
      const result = await callback(this);
      await this.run('COMMIT');
      return result;
    } catch (err) {
      await this.run('ROLLBACK');
      throw err;
    }
  }

  close() {
    return new Promise((resolve, reject) => {
      if (!this.db) return resolve();
      this.db.close((err) => {
        if (err) {
          logger.error(`Error closing database: ${err.message}`);
          reject(err);
        } else {
          logger.info('Database connection closed.');
          this.db = null;
          resolve();
        }
      });
    });
  }
}

// Singleton instance
const dbInstance = new Database();
module.exports = dbInstance;
