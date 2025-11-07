import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scan_flutter/registration/models/register_user_response.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

enum ReceiptCategory {
  groceries,
  foodDining,
  transportation,
  utilities,
  housing,
  entertainment,
  health,
  services,
  shopping,
  travel,
  general,
}

List<String> getCategoryEnumNames() {
  return ReceiptCategory.values.map((e) => e.name).toList();
}

class Receipt {
  final int? id;
  final String vendorName;
  final double totalAmount;
  final DateTime date;
  final ReceiptCategory category;
  final String filePath;
  final String userId;
  final String tags;

  final bool isSynced;

  Receipt({
    this.id,
    required this.vendorName,
    required this.totalAmount,
    required this.date,
    required this.category,
    required this.filePath,
    required this.userId,
    required this.tags,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "vendorName": vendorName,
      "totalAmount": totalAmount,
      "date": date.toIso8601String(),
      "category": category.name,
      "filePath": filePath,
      "userId": userId,
      "tags": tags,
      "isSynced": isSynced ? 1 : 0,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    final int? isSyncedInt = map["isSynced"] as int?;

    return Receipt(
      id: map["id"],
      vendorName: map["vendorName"],
      totalAmount: map["totalAmount"],
      date: DateTime.parse(map["date"]),
      category: ReceiptCategory.values.byName(map["category"]),
      filePath: map["filePath"],
      userId: map["userId"],
      tags: map["tags"] ?? "",
      isSynced: isSyncedInt == 1,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Database and Table names
  static const _databaseName = "ReceiptOCR.db";
  static const _databaseVersion = 2;

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
      onUpgrade: _onUpgrade,
    );
  }

  // Method called when the database version changes
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print("DB: Upgrading database from V$oldVersion to V$newVersion...");
    }

    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $tableReceipts
        ADD COLUMN isSynced INTEGER NOT NULL DEFAULT 0
      ''');
      if (kDebugMode) print("DB: Added 'isSynced' column to $tableReceipts");
    }
  }

  // Method called when the database is created for the first time
  Future _createDB(Database db, int version) async {
    if (kDebugMode) print("DB: Creating tables...");
    // 1. User Info Table (for storing a single logged-in user email)
    await db.execute('''
      CREATE TABLE $tableUser (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL
      )
    ''');

    // 2. Receipts Data Table (for storing parsed data and file path)
    await db.execute('''
      CREATE TABLE $tableReceipts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vendorName TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        date TEXT NOT NULL, -- Stored as ISO 8601 String (YYYY-MM-DD HH:MM:SS)
        category TEXT NOT NULL,
        filePath TEXT NOT NULL,
        userId TEXT NOT NULL,
        tags TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0 -- Integer 0 (false) or 1 (true)
      )
    ''');
    if (kDebugMode) print("DB: Tables created successfully.");
  }

  Future<void> printUserTable() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> userRows = await db.query(
      DatabaseHelper.tableUser,
    );
    if (kDebugMode) print('User Table Rows: $userRows');
  }

  Future<void> printReceiptsTable() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> receiptRows = await db.query(
      DatabaseHelper.tableReceipts,
    );
    if (kDebugMode) print('Receipts Table Rows: $receiptRows');
  }

  Future<int> saveUserInfo(Map<String, dynamic> user) async {
    final db = await instance.database;

    await db.delete(tableUser);

    return await db.insert(tableUser, {
      "id": user["id"],
      "email": user["email"],
      "firstName": user["firstName"],
      "lastName": user["lastName"],
      "phoneNumber": user["phoneNumber"],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getCurrentUser() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableUser, limit: 1);
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // --- Receipt Operations ---

  // Inserts a new receipt record into the database
  Future<int> saveReceipt(Receipt receipt) async {
    try {
      if (kDebugMode) {
        print("DB: Attempting to insert receipt: ${receipt.toMap()}");
      }
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
  Future<List<Receipt>> getReceipts({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await instance.database;

    String whereClause = "userId = ?";
    List<Object?> whereArgs = [userId];

    if (startDate != null && endDate != null) {
      final String startIso = startDate.toIso8601String().substring(0, 10);

      final adjustedEndDate = endDate.add(
        Duration(hours: 23, minutes: 59, seconds: 59),
      );
      final String endIso = adjustedEndDate.toIso8601String();

      whereClause += " AND date BETWEEN ? AND ?";
      whereArgs.add(startIso);
      whereArgs.add(endIso);

      if (kDebugMode) {
        print(
          "DB: Filtering receipts for userId=$userId between $startIso and $endIso",
        );
      }
    } else if (kDebugMode) {
      print("DB: Loading all receipts for userId=$userId (no date filter)");
    }

    // Query the table and order by the MOST RECENT DATE
    final List<Map<String, dynamic>> maps = await db.query(
      tableReceipts,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: "date DESC",
    );

    // Convert the List<Map<String, dynamic>> to List<Recipe>
    return List.generate(maps.length, (i) {
      return Receipt.fromMap(maps[i]);
    });
  }

  Future<List<Receipt>> getMostRecentReceipts({required String userId}) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableReceipts,
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "date DESC",
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

    // Target pattern is YYYY-MM, e.g., "2025-11"
    final String targetPattern = '$yearFilter-$monthFilter';

    final queryString = '''
      SELECT SUM(totalAmount) as total
      FROM $tableReceipts
      WHERE (substr(date, 1, 7)) = ? AND userId = ?
    ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(queryString, [
      targetPattern,
      userId,
    ]);
    if (kDebugMode) {
      print("SQL Query for monthly total:");
      print(queryString);
      print("Args: [$targetPattern, $userId]");
      print("Result: $result");
    }

    final double? total = result.first["total"] as double?;

    return total ?? 0.0;
  }
}
