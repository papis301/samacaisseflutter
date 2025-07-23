import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

class ProductDatabaseHelper {
  static final ProductDatabaseHelper _instance = ProductDatabaseHelper._internal();
  static Database? _database;

  ProductDatabaseHelper._internal();
  factory ProductDatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'products.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            quantity INTEGER,
            price REAL,
            date TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    return db.insert('products', product.toMap());
  }

  Future<List<ProductModel>> getAllProducts() async {
    final db = await database;
    final data = await db.query('products');
    return data.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await database;
    return db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
