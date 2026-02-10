const BaseRepository = require('./baseRepository');

class ReviewRepository extends BaseRepository {
  constructor() {
    super('reviews');
  }

  async create({ userId, locationId, rating, comment }) {
    const sql = `
      INSERT INTO reviews (user_id, location_id, rating, comment)
      VALUES (?, ?, ?, ?)
    `;
    const result = await this.db.run(sql, [userId, locationId, rating, comment]);
    return { id: result.id, userId, locationId, rating, comment, createdAt: new Date() };
  }

  async findByLocationId(locationId) {
    const sql = `
      SELECT r.*, u.username, u.avatar_url 
      FROM reviews r
      JOIN users u ON r.user_id = u.id
      WHERE r.location_id = ?
      ORDER BY r.created_at DESC
    `;
    return this.db.all(sql, [locationId]);
  }

  async findByUserAndLocation(userId, locationId) {
    return this.db.get(
      'SELECT * FROM reviews WHERE user_id = ? AND location_id = ?',
      [userId, locationId]
    );
  }

  async getAverageRating(locationId) {
    return this.db.get(
      'SELECT AVG(rating) as averageRating, COUNT(*) as reviewCount FROM reviews WHERE location_id = ?',
      [locationId]
    );
  }
}

module.exports = new ReviewRepository();
