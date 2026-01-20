const BaseRepository = require('./baseRepository');

class InteractionRepository extends BaseRepository {
  constructor() {
    super('user_interactions');
  }

  async logInteraction({ userId, interactionType, itemId, itemType, data = {} }) {
    const sql = `
      INSERT INTO user_interactions (user_id, interaction_type, item_id, item_type, interaction_data)
      VALUES (?, ?, ?, ?, ?)
    `;
    const jsonData = JSON.stringify(data);
    const result = await this.db.run(sql, [userId, interactionType, itemId, itemType, jsonData]);
    return result.id;
  }

  async getUserHistory(userId, limit = 50) {
    return this.db.all(`
        SELECT * FROM user_interactions 
        WHERE user_id = ? 
        ORDER BY created_at DESC 
        LIMIT ?
    `, [userId, limit]);
  }
}

module.exports = new InteractionRepository();
