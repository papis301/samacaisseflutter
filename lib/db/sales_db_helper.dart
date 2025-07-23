import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SalesDatabaseHelper {
  static final SalesDatabaseHelper _instance = SalesDatabaseHelper._internal();
  static Database? _database;

  factory SalesDatabaseHelper() => _instance;

  SalesDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'sales.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user TEXT,
            total REAL,
            date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE sales_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id INTEGER,
            product_name TEXT,
            quantity INTEGER,
            unit_price REAL,
            FOREIGN KEY(sale_id) REFERENCES sales(id)
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> insertSale({
    required String user,
    required double total,
    required String date,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;

    final saleId = await db.insert('sales', {
      'user': user,
      'total': total,
      'date': date,
    });

    for (var item in items) {
      await db.insert('sales_items', {
        'sale_id': saleId,
        'product_name': item['product'].name,
        'quantity': item['qty'],
        'unit_price': item['product'].price,
      });
    }

    return saleId;
  }

  Future<List<Map<String, dynamic>>> getAllSales() async {
    final db = await database;
    return db.query('sales', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    final db = await database;
    return db.query('sales_items', where: 'sale_id = ?', whereArgs: [saleId]);
  }
}
