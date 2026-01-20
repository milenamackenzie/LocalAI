const db = require('../database/connection');

class BaseRepository {
  constructor(tableName) {
    this.tableName = tableName;
    this.db = db;
  }

  async findAll() {
    return this.db.all(`SELECT * FROM ${this.tableName}`);
  }

  async findById(id) {
    return this.db.get(`SELECT * FROM ${this.tableName} WHERE id = ?`, [id]);
  }

  async delete(id) {
    return this.db.run(`DELETE FROM ${this.tableName} WHERE id = ?`, [id]);
  }
}

module.exports = BaseRepository;
