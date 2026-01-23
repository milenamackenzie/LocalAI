import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('localai.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        response TEXT NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        score REAL NOT NULL,
        imageUrl TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<int> insertBookmark(Map<String, dynamic> location) async {
    final db = await database;
    return await db.insert('bookmarks', location, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> removeBookmark(String id) async {
    final db = await database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await database;
    return await db.query('bookmarks', orderBy: 'timestamp DESC');
  }

  Future<bool> isBookmarked(String id) async {
    final db = await database;
    final maps = await db.query('bookmarks', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }

  Future<int> insertChat(String query, String response) async {
    final db = await database;
    return await db.insert('chat_history', {
      'query': query,
      'response': response,
    });
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final db = await database;
    return await db.query('chat_history', orderBy: 'timestamp DESC');
  }

  Future<int> deleteChat(int id) async {
    final db = await database;
    return await db.delete('chat_history', where: 'id = ?', whereArgs: [id]);
  }
}
