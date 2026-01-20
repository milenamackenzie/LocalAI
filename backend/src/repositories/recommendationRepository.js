const BaseRepository = require('./baseRepository');

class RecommendationRepository extends BaseRepository {
  constructor() {
    super('recommendations');
  }

  async findByUserId(userId, limit = 20) {
    return this.db.all(`
      SELECT * FROM recommendations 
      WHERE user_id = ? 
      ORDER BY created_at DESC 
      LIMIT ?
    `, [userId, limit]);
  }

  async create(recData) {
    const { userId, itemType, itemTitle, itemDescription, score } = recData;
    const sql = `
      INSERT INTO recommendations (user_id, item_type, item_title, item_description, recommendation_score)
      VALUES (?, ?, ?, ?, ?)
    `;
    const result = await this.db.run(sql, [userId, itemType, itemTitle, itemDescription, score]);
    return { id: result.id, ...recData };
  }
}

module.exports = new RecommendationRepository();
