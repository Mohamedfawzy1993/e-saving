import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE,
        full_name TEXT NOT NULL,
        pin_hash TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Groups table
    await db.execute('''
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        admin_id TEXT NOT NULL,
        cycle_type TEXT NOT NULL,
        cycle_duration INTEGER NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        invite_code TEXT UNIQUE NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (admin_id) REFERENCES users (id)
      )
    ''');

    // Group members table
    await db.execute('''
      CREATE TABLE group_members (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        contribution_amount REAL NOT NULL,
        join_date INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (group_id) REFERENCES groups (id),
        FOREIGN KEY (user_id) REFERENCES users (id),
        UNIQUE(group_id, user_id)
      )
    ''');

    // Collection schedule table
    await db.execute('''
      CREATE TABLE collection_schedule (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        collector_user_id TEXT NOT NULL,
        collection_date INTEGER NOT NULL,
        cycle_number INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        total_amount REAL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (group_id) REFERENCES groups (id),
        FOREIGN KEY (collector_user_id) REFERENCES users (id)
      )
    ''');

    // Contributions table
    await db.execute('''
      CREATE TABLE contributions (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        contributor_user_id TEXT NOT NULL,
        collection_schedule_id TEXT NOT NULL,
        amount REAL NOT NULL,
        contribution_date INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (group_id) REFERENCES groups (id),
        FOREIGN KEY (contributor_user_id) REFERENCES users (id),
        FOREIGN KEY (collection_schedule_id) REFERENCES collection_schedule (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_group_members_group_id ON group_members(group_id)');
    await db.execute('CREATE INDEX idx_group_members_user_id ON group_members(user_id)');
    await db.execute('CREATE INDEX idx_collection_schedule_group_id ON collection_schedule(group_id)');
    await db.execute('CREATE INDEX idx_collection_schedule_collector ON collection_schedule(collector_user_id)');
    await db.execute('CREATE INDEX idx_contributions_group_id ON contributions(group_id)');
    await db.execute('CREATE INDEX idx_contributions_contributor ON contributions(contributor_user_id)');
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> update(String table, Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}