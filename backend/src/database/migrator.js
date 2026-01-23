const fs = require('fs');
const path = require('path');
const db = require('./connection');
const logger = require('../utils/logger');

class Migrator {
  constructor() {
    this.migrationsPath = path.resolve(__dirname, 'migrations');
  }

  async init() {
    // Ensure migrations table exists
    await db.run(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        migration_name TEXT NOT NULL UNIQUE,
        executed_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);
  }

  async getExecutedMigrations() {
    const rows = await db.all('SELECT migration_name FROM schema_migrations');
    return new Set(rows.map(r => r.migration_name));
  }

  async run() {
    await this.init();
    const executed = await this.getExecutedMigrations();
    
    // Read files
    const files = fs.readdirSync(this.migrationsPath)
      .filter(f => f.endsWith('.sql'))
      .sort(); // Ensure order (001, 002...)

    let appliedCount = 0;

    for (const file of files) {
      if (!executed.has(file)) {
        logger.info(`Applying migration: ${file}`);
        const sql = fs.readFileSync(path.join(this.migrationsPath, file), 'utf8');

        try {
            await db.transaction(async (tx) => {
                await tx.exec(sql);
                await tx.run('INSERT INTO schema_migrations (migration_name) VALUES (?)', [file]);
            });
            logger.info(`Migration ${file} applied successfully.`);
            appliedCount++;
        } catch (err) {
            logger.error(`Failed to apply migration ${file}: ${err.message}`);
            throw err; // Stop migration process on failure
        }
      }
    }

    if (appliedCount === 0) {
      logger.info('Database schema is up to date.');
    } else {
      logger.info(`${appliedCount} migrations applied.`);
    }
  }
}

module.exports = new Migrator();
