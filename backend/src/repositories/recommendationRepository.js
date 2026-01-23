const BaseRepository = require('./baseRepository');

class RecommendationRepository extends BaseRepository {
  constructor() {
    super('recommendations');
  }

  async findWithFilters({ userId, category, minScore, limit = 20, offset = 0, isArchived = 0 }) {
    let sql = `
        SELECT * FROM recommendations 
        WHERE user_id = ? 
        AND is_archived = ?
    `;
    const params = [userId, isArchived];

    if (category) {
        sql += ' AND category = ?';
        params.push(category);
    }

    if (minScore) {
        sql += ' AND recommendation_score >= ?';
        params.push(minScore);
    }

    sql += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return this.db.all(sql, params);
  }

  async create(recData) {
    const { 
        userId, itemType, itemTitle, itemDescription, score, 
        category, context 
    } = recData;
    
    const sql = `
      INSERT INTO recommendations (
          user_id, item_type, item_title, item_description, 
          recommendation_score, category, generation_context
      )
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    const result = await this.db.run(sql, [
        userId, itemType, itemTitle, itemDescription, 
        score, category, context
    ]);
    return { id: result.id, ...recData };
  }

  async updateFeedback(id, userId, feedback) {
      return this.db.run(
          'UPDATE recommendations SET feedback_status = ? WHERE id = ? AND user_id = ?',
          [feedback, id, userId]
      );
  }

  async archive(id, userId) {
      return this.db.run(
          'UPDATE recommendations SET is_archived = 1 WHERE id = ? AND user_id = ?',
          [id, userId]
      );
  }

  async getAnalytics(userId) {
      // Aggregate stats
      const stats = await this.db.get(`
          SELECT 
            COUNT(*) as total,
            AVG(recommendation_score) as avg_score,
            SUM(CASE WHEN feedback_status = 'liked' THEN 1 ELSE 0 END) as likes,
            SUM(CASE WHEN feedback_status = 'disliked' THEN 1 ELSE 0 END) as dislikes
          FROM recommendations
          WHERE user_id = ?
      `, [userId]);
      
      const byCategory = await this.db.all(`
          SELECT category, COUNT(*) as count 
          FROM recommendations 
          WHERE user_id = ? 
          GROUP BY category
      `, [userId]);

      return { stats, byCategory };
  }
}

module.exports = new RecommendationRepository();
