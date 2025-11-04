import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

class Receipt {
  final int? id;
  final String vendorName;
  final double totalAmount;
  final String date;
  final String category;
  final String filePath;
  final String userId;
  final String tags;

  Receipt({
    this.id,
    required this.vendorName,
    required this.totalAmount,
    required this.date,
    required this.category,
    required this.filePath,
    required this.userId,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "vendorName": vendorName,
      "totalAmount": totalAmount,
      "date": date,
      "category": category,
      "filePath": filePath,
      "userId": userId,
      "tags": tags,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map["id"],
      vendorName: map["vendorName"],
      totalAmount: map["totalAmount"],
      date: map["date"],
      category: map["category"],
      filePath: map["filePath"],
      userId: map["userId"],
      tags: map["tags"] ?? "",
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Database and Table names
  static const _databaseName = "ReceiptOCR.db";
  static const _databaseVersion = 1;

  static const tableUser = "user_info";
  static const tableReceipts = "receipts";

  // Private method to get or initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Get the directory where databases are stored
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);

    // Open the database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
    );
  }

  // Method called when the database is created for the first time
  Future _createDB(Database db, int version) async {
    if (kDebugMode) print("DB: Creating tables...");
    // 1. User Info Table (for storing a single logged-in user email)
    await db.execute('''
      CREATE TABLE $tableUser (
        id INTEGER PRIMARY KEY,
        email TEXT NOT NULL
      )
    ''');

    // 2. Receipts Data Table (for storing parsed data and file path)
    await db.execute('''
      CREATE TABLE $tableReceipts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vendorName TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        filePath TEXT NOT NULL,
        userId TEXT NOT NULL,
        tags TEXT NOT NULL
      )
    ''');
    if (kDebugMode) print("DB: Tables created successfully.");
  }

  Future<int> saveUserEmail(String email) async {
    final db = await instance.database;

    await db.delete(tableUser);

    return await db.insert(tableUser, {
      "id": 1,
      "email": email,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getLoggedInUserEmail() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableUser, limit: 1);

    if (maps.isNotEmpty) {
      return maps.first["email"] as String;
    }
    return null;
  }

  // --- Receipt Operations ---

  // Inserts a new receipt record into the database
  Future<int> saveReceipt(Receipt receipt) async {
    try {
      if (kDebugMode)
        print("DB: Attempting to insert receipt: ${receipt.toMap()}");
      final db = await instance.database;

      final result = await db.insert(
        tableReceipts,
        receipt.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (kDebugMode) print("DB: Insert successful. Row ID: $result");
      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('!!! DB ERROR in saveReceipt !!!');
        print('SQLITE Error: $e');
        print('Stack Trace: $stackTrace');
      }
      // Re-throw the error so the UI catch block can handle it
      rethrow;
    }
  }

  // Retrieves all stored receipts for a specific user ID
  Future<List<Receipt>> getReceipts({required String userId}) async {
    final db = await instance.database;

    // Query the table and order by the most recent ID
    final List<Map<String, dynamic>> maps = await db.query(
      tableReceipts,
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "id DESC",
    );

    // Convert the List<Map<String, dynamic>> to List<Recipe>
    return List.generate(maps.length, (i) {
      return Receipt.fromMap(maps[i]);
    });
  }

  Future<List<Receipt>> getMostRecentReceipts({required String userId}) async {
    final db = await instance.database;

    // Query the table and order by the most recent ID
    final List<Map<String, dynamic>> maps = await db.query(
      tableReceipts,
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "id DESC",
      limit: 10,
    );

    // Convert the List<Map<String, dynamic>> to List<Recipe>
    return List.generate(maps.length, (i) {
      return Receipt.fromMap(maps[i]);
    });
  }

  // Retrieves a single receipt by ID
  Future<Receipt?> getReceiptById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableReceipts,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Receipt.fromMap(maps.first);
    }
    return null;
  }

  // Deletes a specific receipt entry
  Future<void> deleteReceipt(int id) async {
    final db = await instance.database;
    await db.delete(tableReceipts, where: "id = ?", whereArgs: [id]);
  }

  // Updates an existing receipt (based on its ID)
  Future<int> updateReceipt(Receipt receipt) async {
    final db = await instance.database;
    return await db.update(
      tableReceipts,
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  Future<double> getTotalAmountForMonth({
    required int month,
    required int year,
    required String userId,
  }) async {
    final db = await instance.database;

    final String monthFilter = month.toString().padLeft(2, '0');
    final String yearFilter = year.toString();

    final String targetPattern = '$yearFilter-$monthFilter';

    final queryString = '''
      SELECT SUM(totalAmount) as total
      FROM $tableReceipts
      WHERE (substr(date, 7, 4) || '-' || substr(date, 1, 2)) = ? AND userId = ?
    ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(queryString, [
      targetPattern,
      userId,
    ]);
    print(queryString);
    print("result: $result");

    final double? total = result.first["total"] as double?;

    return total ?? 0.0;
  }
}
