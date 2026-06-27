import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/session.dart';
import '../models/vital_reading.dart';

/// ============================================================
/// Database Service — SQLite storage for sessions & readings
/// ============================================================
/// Two tables:
///   sessions — one row per connect→disconnect cycle
///   readings — one row per vital reading, linked to a session
///
/// USAGE:
///   final db = DatabaseService();
///   await db.init();
///   final sessionId = await db.startSession(...);
///   await db.saveReading(reading);
///   await db.endSession(sessionId);

class DatabaseService {
  static const String _dbName = 'biovitals.db';
  static const int _dbVersion = 1;

  Database? _database;

  /// Get the database instance (lazy initialization).
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database and create tables.
  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  /// Create the sessions and readings tables.
  Future<void> _createTables(Database db, int version) async {
    // Sessions table
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_name TEXT NOT NULL,
        device_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER
      )
    ''');

    // Readings table
    await db.execute('''
      CREATE TABLE readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        heart_rate REAL NOT NULL,
        spo2 REAL NOT NULL,
        temperature REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions(id)
      )
    ''');

    // Index for fast queries by session and time
    await db.execute(
      'CREATE INDEX idx_readings_session ON readings(session_id)',
    );
    await db.execute(
      'CREATE INDEX idx_readings_timestamp ON readings(timestamp)',
    );
  }

  // ── Session Operations ───────────────────────────────────────

  /// Start a new session. Returns the session ID.
  Future<int> startSession({
    required String deviceName,
    required String deviceId,
  }) async {
    final db = await database;
    final session = Session(
      deviceName: deviceName,
      deviceId: deviceId,
      startTime: DateTime.now(),
    );
    return await db.insert('sessions', session.toMap());
  }

  /// End a session (set its end_time).
  Future<void> endSession(int sessionId) async {
    final db = await database;
    await db.update(
      'sessions',
      {'end_time': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Get all sessions, newest first.
  Future<List<Session>> getAllSessions() async {
    final db = await database;
    final rows = await db.query(
      'sessions',
      orderBy: 'start_time DESC',
    );
    return rows.map((row) => Session.fromMap(row)).toList();
  }

  /// Get a single session by ID.
  Future<Session?> getSession(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    if (rows.isEmpty) return null;
    return Session.fromMap(rows.first);
  }

  // ── Reading Operations ───────────────────────────────────────

  /// Save a single vital reading.
  Future<int> saveReading(VitalReading reading) async {
    final db = await database;
    return await db.insert('readings', reading.toMap());
  }

  /// Get all readings for a session, ordered by time.
  Future<List<VitalReading>> getReadingsForSession(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'readings',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return rows.map((row) => VitalReading.fromMap(row)).toList();
  }

  /// Get readings in a time range (across all sessions).
  Future<List<VitalReading>> getReadingsInRange(
    DateTime from,
    DateTime to,
  ) async {
    final db = await database;
    final rows = await db.query(
      'readings',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [
        from.millisecondsSinceEpoch,
        to.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp ASC',
    );
    return rows.map((row) => VitalReading.fromMap(row)).toList();
  }

  /// Get the N most recent readings (for quick dashboard history).
  Future<List<VitalReading>> getLatestReadings(int count) async {
    final db = await database;
    final rows = await db.query(
      'readings',
      orderBy: 'timestamp DESC',
      limit: count,
    );
    // Reverse to get chronological order
    return rows.reversed.map((row) => VitalReading.fromMap(row)).toList();
  }

  /// Get reading count for a session (useful for session list display).
  Future<int> getReadingCount(int sessionId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM readings WHERE session_id = ?',
      [sessionId],
    );
    return result.first['count'] as int;
  }

  // ── Cleanup ──────────────────────────────────────────────────

  /// Close the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
