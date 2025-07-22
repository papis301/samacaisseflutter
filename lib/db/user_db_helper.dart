import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class UserDBHelper {
  static final UserDBHelper _instance = UserDBHelper._internal();
  static Database? _database;

  factory UserDBHelper() => _instance;
  UserDBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');
    //return openDatabase(path, version: 1, onCreate: _onCreate);
    return openDatabase(
      path,
      version: 2, // passe à 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE users ADD COLUMN last_login TEXT");
      await db.execute("ALTER TABLE users ADD COLUMN last_logout TEXT");
    }
  }




  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final res = await db.query('users');
    return res.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> seedAdminUser() async {
    final db = await database;
    final result = await db.query('users');
    if (result.isEmpty) {
      await db.insert('users', {
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
      });
    }
  }

}
