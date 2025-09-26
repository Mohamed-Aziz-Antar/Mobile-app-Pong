import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pong_app.db');
    return await openDatabase(
      path,
      version: 2, // Still use version 2
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        avatar BLOB,
        wins INTEGER DEFAULT 0,
        game_played INTEGER DEFAULT 0,
        loses INTEGER DEFAULT 0,
        draws INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1
      )
    ''');
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUserAvatar(String email, Uint8List avatarBytes) async {
    final db = await database;
    await db.update(
      'users',
      {'avatar': avatarBytes},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<Uint8List?> getAvatarBytes(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      columns: ['avatar'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first['avatar'] as Uint8List? : null;
  }

  Future<Map<String, dynamic>?> getUserData(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
}
