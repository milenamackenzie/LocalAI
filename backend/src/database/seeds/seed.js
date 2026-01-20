const bcrypt = require('bcrypt');
const db = require('../connection');
const migrator = require('../migrator');
const userRepository = require('../../repositories/userRepository');
const logger = require('../../utils/logger');

async function seed() {
  try {
    await db.connect();
    await migrator.run(); // Ensure schema exists

    logger.info('Starting database seed...');

    // Check if users exist
    const existingUsers = await db.get('SELECT count(*) as count FROM users');
    if (existingUsers.count > 0) {
        logger.info('Database already seeded. Skipping.');
        return;
    }

    // Create Admin
    const adminPass = await bcrypt.hash('admin123', 10);
    await userRepository.create({
        username: 'admin',
        email: 'admin@localai.com',
        passwordHash: adminPass,
        role: 'admin'
    });
    logger.info('Created admin user (admin@localai.com / admin123)');

    // Create User
    const userPass = await bcrypt.hash('user123', 10);
    const user = await userRepository.create({
        username: 'testuser',
        email: 'user@localai.com',
        passwordHash: userPass,
        role: 'user'
    });
    logger.info('Created test user (user@localai.com / user123)');

    // Add Preferences
    await db.run(`
        INSERT INTO user_preferences (user_id, category, preference_value) VALUES 
        (?, 'theme', 'dark'),
        (?, 'notifications', 'true'),
        (?, 'interests', '["tech", "ai", "hiking"]')
    `, [user.id, user.id, user.id]);
    logger.info('Added default preferences');

    // Add Sample Logs
    await db.run(`
        INSERT INTO ai_model_logs (model_name, prompt, response, processing_time_ms) VALUES
        ('llama-3-8b', 'Hello AI', 'Hello user!', 150),
        ('mistral-7b', 'Summarize this', 'Summary...', 340)
    `);

    logger.info('Seeding completed successfully.');

  } catch (err) {
    logger.error('Seeding failed:', err);
    process.exit(1);
  } finally {
    await db.close();
  }
}

// Execute if run directly
if (require.main === module) {
    seed();
}

module.exports = seed;
