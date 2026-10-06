import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../log_data.dart/logger_data.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Method to delete database file
  Future<void> deleteDatabaseFile() async {
    await closeDatabase();

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eyvo_offline.db');

    await deleteDatabase(path);

    _db = null;

    LoggerData.dataLog("Database deleted");
  }

  // Method to reset database (delete and recreate)
  Future<void> resetDatabase() async {
    await closeDatabase();

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eyvo_offline.db');

    await deleteDatabase(path); // sqflite delete

    _db = null;

    await db;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eyvo_offline.db');
    LoggerData.dataLog("DB Path: $path");

    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    LoggerData.dataLog("Creating database with version $version");
    await _createTables(db);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 5) {
      await db.execute("DROP TABLE IF EXISTS item_stock");
      await db.execute("DROP TABLE IF EXISTS region_master");
      await db.execute("DROP TABLE IF EXISTS items_location");
      await db.execute("DROP TABLE IF EXISTS items_region");
      await db.execute("DROP TABLE IF EXISTS error_log");

      await _createTables(db);
    } else if (oldVersion < 7) {
      // Add items_region table for existing DBs between v5/v6 -> v7
      await db.execute('''
      CREATE TABLE IF NOT EXISTS items_region (
        ItemID INTEGER,
        Region_ID TEXT,
        PRIMARY KEY (ItemID, Region_ID)
      )
      ''');
      LoggerData.dataLog("items_region table created on upgrade");
    }
  }

  Future<void> _createTables(Database db) async {
    // Create item_stock table
    await db.execute('''
    CREATE TABLE item_stock (
      ItemID INTEGER,
      ItemCode TEXT,
      OutLine TEXT,
      Description TEXT,
      CategoryID INTEGER,
      CategoryCode TEXT,
      Item_Type TEXT,
      IsStock INTEGER,
      Region_ID INTEGER,
      LocationID INTEGER,
      LocationCode TEXT,
      TotalStockCount REAL,
      NewStockCount REAL,
      Comments TEXT,
      UpdatedBy TEXT,
      UpdatedOn TEXT,
      UPC TEXT,
      Synced INTEGER,
      CatchWeight INTEGER DEFAULT 0,
      Splitable INTEGER DEFAULT 0,
      StandardUnitID INTEGER,
      StandardUnit TEXT,
      UnitID INTEGER, 
      Unit TEXT,
      PurchaseUnit_Conversion REAL,
      InventoryUnitID INTEGER,
      InventoryUnit TEXT,
      InventoryUnit_Conversion REAL,
      RecipeUnitID INTEGER,
      RecipeUnit TEXT,
      RecipeUnit_Conversion REAL,
      Unit_Selected INTEGER,
      Unit_Type TEXT DEFAULT 'purchase',
      ActualWeight REAL DEFAULT 0,
      PRIMARY KEY (ItemID, LocationID)
    )
    ''');

    // Create region_master table
    await db.execute('''
    CREATE TABLE region_master (
      Region_ID INTEGER PRIMARY KEY,
      Region_Code TEXT
    )
    ''');

    // Create items_location table with Default_Location column
    await db.execute('''
    CREATE TABLE items_location (
      Location_ID INTEGER PRIMARY KEY,
      Location_Code TEXT,
      Region_Id INTEGER,
      Default_Location INTEGER
    )
    ''');

    // Create items_region table
    await db.execute('''
  CREATE TABLE items_region (
    ItemID INTEGER,
    Region_ID INTEGER,
    PRIMARY KEY (ItemID, Region_ID)
  )
''');
    // Create error_log table
    await db.execute('''
    CREATE TABLE error_log (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exception_message TEXT,
      stack_trace TEXT,
      api_url TEXT,
      request_body TEXT,
      screen_name TEXT,
      method_name TEXT,
      timestamp TEXT,
      synced INTEGER DEFAULT 0
    )
    ''');

    LoggerData.dataLog("All tables created successfully");
  }

  // Helper method to check if database exists
  Future<bool> isDatabaseExists() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'eyvo_offline.db');
      return await File(path).exists();
    } catch (e) {
      LoggerData.dataLog("Error checking database existence: $e");
      return false;
    }
  }

  // Helper method to get database path
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'eyvo_offline.db');
  }

  // Close database connection
  Future<void> closeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      LoggerData.dataLog("Database closed successfully");
    }
  }
}
