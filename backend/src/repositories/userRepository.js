const BaseRepository = require('./baseRepository');
const User = require('../models/User');

class UserRepository extends BaseRepository {
  constructor() {
    super('users');
  }

  async create({ username, email, passwordHash, role = 'user' }) {
    const sql = `
      INSERT INTO users (username, email, password_hash, role)
      VALUES (?, ?, ?, ?)
    `;
    const result = await this.db.run(sql, [username, email, passwordHash, role]);
    // Return User model instance
    return new User({ 
        id: result.id, 
        username, 
        email, 
        password_hash: passwordHash, 
        role,
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
}

module.exports = new UserRepository();
