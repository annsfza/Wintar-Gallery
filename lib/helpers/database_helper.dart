import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gallery.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      username TEXT UNIQUE,
      email TEXT UNIQUE,
      password TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      image BLOB,
      date TEXT,
      isFavorite INTEGER DEFAULT 0
    )
    ''');
  }

  // Hash password menggunakan SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Register user baru
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final db = await instance.database;

    try {
      final existingUser = await db.query(
        'users',
        where: 'username = ? OR email = ?',
        whereArgs: [username, email],
      );

      if (existingUser.isNotEmpty) {
        return {'success': false, 'message': 'Username or email already exists'};
      }

      final hashedPassword = _hashPassword(password);
      final id = await db.insert('users', {
        'name': name,
        'username': username,
        'email': email,
        'password': hashedPassword,
      });

      return {'success': true, 'message': 'Registration successful', 'userId': id};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: ${e.toString()}'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    final db = await instance.database;
    try {
      final hashedPassword = _hashPassword(password);

      final results = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, hashedPassword],
      );

      if (results.isEmpty) {
        return {'success': false, 'message': 'Invalid username or password'};
      }

      return {'success': true, 'message': 'Login successful', 'user': results.first};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  // Simpan gambar ke database
  Future<int> insertImage(File imageFile, DateTime date) async {
    final db = await instance.database;
    final imageBytes = await imageFile.readAsBytes();
    final dateString = date.toIso8601String();

    return await db.insert('images', {
      'image': imageBytes,
      'date': dateString,
      'isFavorite': 0,
    });
  }

  // Ambil semua gambar (bisa dilihat oleh semua user)
  Future<List<Map<String, dynamic>>> getAllImages() async {
    final db = await instance.database;
    return await db.query(
      'images',
      columns: ['id', 'image', 'date', 'isFavorite'],
    );
  }

  // Hapus gambar berdasarkan ID
  Future<int> deleteImage(int id) async {
    final db = await instance.database;
    return await db.delete(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tandai gambar sebagai favorit
  Future<int> toggleFavoriteImage(int id, bool isFavorite) async {
    final db = await instance.database;
    return await db.update(
      'images',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ambil semua gambar yang difavoritkan
  Future<List<Map<String, dynamic>>> getFavoriteImages() async {
    final db = await instance.database;
    return await db.query(
      'images',
      where: 'isFavorite = ?',
      whereArgs: [1],
      columns: ['id', 'image', 'date'],
    );
  }
}
