const BaseRepository = require('./baseRepository');

class PreferenceRepository extends BaseRepository {
  constructor() {
    super('user_preferences');
  }

  async findByUserId(userId) {
    return this.db.all('SELECT * FROM user_preferences WHERE user_id = ?', [userId]);
  }

  async upsert(userId, category, value) {
    // Check if exists
    const existing = await this.db.get(
        'SELECT id FROM user_preferences WHERE user_id = ? AND category = ?', 
        [userId, category]
    );

    const stringValue = typeof value === 'object' ? JSON.stringify(value) : String(value);

    if (existing) {
        return this.db.run(
            'UPDATE user_preferences SET preference_value = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', 
            [stringValue, existing.id]
        );
    } else {
        return this.db.run(
            'INSERT INTO user_preferences (user_id, category, preference_value) VALUES (?, ?, ?)',
            [userId, category, stringValue]
        );
    }
  }
}

module.exports = new PreferenceRepository();
