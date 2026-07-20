import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DBService{

  static const String mydbName = 'biovitals.db';

  DBService._();
  static final DBService getinstance = DBService._();

  Database? myDB;
  Future<Database> getDB() async{
    myDB ??= await openDB();
    return myDB!;
  }

  Future<Database> openDB() async{
    Directory appdir = await getApplicationDocumentsDirectory();
    String dbpath = join(appdir.path, mydbName);
    return await openDatabase(dbpath,version: 1, onCreate: createTables,);
  }

  Future<void> createTables(Database db, int version) async{
    await db.execute('''
      CREATE TABLE mysessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_name TEXT NOT NULL,
        device_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE myreadings (
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
    final session = Session(
      deviceName: deviceName,
      deviceId: deviceId,
      startTime: DateTime.now(),
    );
    return await db.insert('sessions', session.toMap());
  }

}