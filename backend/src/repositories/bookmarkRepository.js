const BaseRepository = require('./baseRepository');

class BookmarkRepository extends BaseRepository {
  constructor() {
    super('bookmarks');
  }

  async addBookmark({ userId, itemId, itemType, itemTitle, itemCategory, itemScore, itemImageUrl }) {
    const sql = `
      INSERT INTO bookmarks (user_id, item_id, item_type, item_title, item_category, item_score, item_image_url)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(user_id, item_id) DO UPDATE SET
        item_title = excluded.item_title,
        item_category = excluded.item_category,
        item_score = excluded.item_score,
        item_image_url = excluded.item_image_url
    `;
    return this.db.run(sql, [userId, itemId, itemType, itemTitle, itemCategory, itemScore, itemImageUrl]);
  }

  async removeBookmark(userId, itemId) {
    return this.db.run('DELETE FROM bookmarks WHERE user_id = ? AND item_id = ?', [userId, itemId]);
  }

  async getBookmarks(userId) {
    return this.db.all('SELECT * FROM bookmarks WHERE user_id = ? ORDER BY created_at DESC', [userId]);
  }
}

module.exports = new BookmarkRepository();
