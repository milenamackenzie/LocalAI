const BaseRepository = require('./baseRepository');
const User = require('../models/User');

class UserRepository extends BaseRepository {
  constructor() {
    super('users');
  }

  async create({ username, email, passwordHash, role = 'user', verificationToken }) {
    const sql = `
      INSERT INTO users (username, email, password_hash, role, verification_token)
      VALUES (?, ?, ?, ?, ?)
    `;
    const result = await this.db.run(sql, [username, email, passwordHash, role, verificationToken]);
    return new User({ 
        id: result.id, 
        username, 
        email, 
        password_hash: passwordHash, 
        role,
        is_verified: 0,
        verification_token: verificationToken,
        created_at: new Date(),
        updated_at: new Date()
    });
  }

  async findByEmail(email) {
    const row = await this.db.get('SELECT * FROM users WHERE email = ?', [email]);
    return row ? new User(row) : null;
  }
  
  async findByUsername(username) {
    const row = await this.db.get('SELECT * FROM users WHERE username = ?', [username]);
    return row ? new User(row) : null;
  }
  
  async findById(id) {
    const row = await super.findById(id);
    return row ? new User(row) : null;
  }

  async findByVerificationToken(token) {
    const row = await this.db.get('SELECT * FROM users WHERE verification_token = ?', [token]);
    return row ? new User(row) : null;
  }

  async findByResetToken(token) {
    const row = await this.db.get('SELECT * FROM users WHERE reset_token = ? AND reset_token_expires > CURRENT_TIMESTAMP', [token]);
    return row ? new User(row) : null;
  }

  async markVerified(id) {
    return this.db.run('UPDATE users SET is_verified = 1, verification_token = NULL WHERE id = ?', [id]);
  }

  async incrementLoginAttempts(id) {
    return this.db.run('UPDATE users SET failed_login_attempts = failed_login_attempts + 1 WHERE id = ?', [id]);
  }

  async resetLoginAttempts(id) {
    return this.db.run('UPDATE users SET failed_login_attempts = 0, lockout_until = NULL WHERE id = ?', [id]);
  }

  async lockoutUser(id, lockoutUntil) {
    return this.db.run('UPDATE users SET lockout_until = ? WHERE id = ?', [lockoutUntil, id]);
  }

  async setResetToken(id, token, expiresAt) {
    return this.db.run('UPDATE users SET reset_token = ?, reset_token_expires = ? WHERE id = ?', [token, expiresAt, id]);
  }

  async updatePassword(id, passwordHash) {
    return this.db.run('UPDATE users SET password_hash = ?, reset_token = NULL, reset_token_expires = NULL, failed_login_attempts = 0, lockout_until = NULL WHERE id = ?', [passwordHash, id]);
  }
}

module.exports = new UserRepository();
