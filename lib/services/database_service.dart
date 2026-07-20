import 'dart:io';
import 'package:health_tracker/models/sessions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:health_tracker/models/vitalsreadings.dart';

class DBService{

  static const String mydbName = 'biovitals.db';

  DBService._();
  static final DBService getInstance = DBService._();

  Database? myDB;
  Future<Database>? _dbOpening;
  Future<Database> getDB() async{
    if (myDB != null) return myDB!;
    // If another call is already opening the DB, wait on that same
    // future instead of starting a second openDatabase() call.
    _dbOpening ??= openDB();
    myDB = await _dbOpening;
    return myDB!;
  }

  Future<Database> openDB() async{
    Directory appdir = await getApplicationDocumentsDirectory();
    String dbpath = join(appdir.path, mydbName);
    return await openDatabase(
      dbpath,
      version: 1,
      onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    }, onCreate: createTables,);
  }

  Future<void> createTables(Database db, int version) async{
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_name TEXT NOT NULL,
        device_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER
      )
    ''');

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

    await db.execute(
      'CREATE INDEX idx_readings_session ON readings(session_id)',
    );
    await db.execute(
      'CREATE INDEX idx_readings_timestamp ON readings(timestamp)',
    );
  }

  Future<int> startSession({
    required String deviceName,
    required String deviceId,
  }) async {
    final db = await getDB();
    final session = mySession(
      deviceName: deviceName,
      deviceId: deviceId,
      startTime: DateTime.now(),
    );
    return await db.insert('sessions', session.toMap());
  }

  /// End a session (set its end_time).
  Future<void> endSession(int sessionId) async {
    final db = await getDB();
    await db.update(
      'sessions',
      {'end_time': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Get all sessions, newest first.
  Future<List<mySession>> getAllSessions() async {
    final db = await getDB();
    final rows = await db.query(
      'sessions',
      orderBy: 'start_time DESC',
    );
    return rows.map((row) => mySession.fromMap(row)).toList();
  }

  /// Get a single session by ID.
  Future<mySession?> getSession(int sessionId) async {
    final db = await getDB();
    final rows = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    if (rows.isEmpty) return null;
    return mySession.fromMap(rows.first);
  }

  //reading operation---------------------------------------------------------

  /// Save a single vital reading.
  Future<int> saveReading(VitalReading reading) async {
    final db = await getDB();
    return await db.insert('readings', reading.toMap());
  }

  /// Get all readings for a session, ordered by time.
  Future<List<VitalReading>> getReadingsForSession(int sessionId) async {
    final db = await getDB();
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
    final db = await getDB();
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
    final db = await getDB();
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
    final db = await getDB();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM readings WHERE session_id = ?',
      [sessionId],
    );
    return result.first['count'] as int;
  }

  // ── Cleanup ──────────────────────────────────────────────────

  /// Close the database connection.
  Future<void> close() async {
    final db = await getDB();
    await db.close();
    myDB = null;
  }

}