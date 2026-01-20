const BaseRepository = require('./baseRepository');

class RefreshTokenRepository extends BaseRepository {
  constructor() {
    super('refresh_tokens');
  }

  async create(userId, token, expiresAt) {
    const sql = `
      INSERT INTO refresh_tokens (user_id, token, expires_at)
      VALUES (?, ?, ?)
    `;
    await this.db.run(sql, [userId, token, expiresAt]);
    return { userId, token, expiresAt };
  }

  async findByToken(token) {
    return this.db.get('SELECT * FROM refresh_tokens WHERE token = ?', [token]);
  }

  async revoke(token) {
    return this.db.run('UPDATE refresh_tokens SET revoked = 1 WHERE token = ?', [token]);
  }

  async revokeAllForUser(userId) {
    return this.db.run('UPDATE refresh_tokens SET revoked = 1 WHERE user_id = ?', [userId]);
  }
  
  async deleteExpired() {
      return this.db.run('DELETE FROM refresh_tokens WHERE expires_at < CURRENT_TIMESTAMP');
  }
}

module.exports = new RefreshTokenRepository();
