import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/hike.dart';
import '../models/observation.dart';
import 'dart:async';

// Handles all database operations
class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _databaseName = 'mhike.db';
  static const int _databaseVersion = 1; 

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  // Initialize database 
  Future<Database> _initializeDatabase() async {
    final documentsDirectory =
        await getApplicationDocumentsDirectory();
    final databasePath = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      databasePath,
      version: _databaseVersion, 
      onCreate: _createDatabaseSchema, 
    );
  }

  // Create tables 
  Future<void> _createDatabaseSchema(Database database, int version) async {
    await database.execute('''
      CREATE TABLE hikes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        hike_date TEXT NOT NULL,
        parking_available TEXT NOT NULL,
        length REAL NOT NULL,
        difficulty TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Not in the guide, required for project
    await database.execute('''
      CREATE TABLE observations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        observation TEXT NOT NULL,
        observation_time TEXT NOT NULL,
        comments TEXT,
        hike_id INTEGER NOT NULL,
        FOREIGN KEY (hike_id) REFERENCES hikes (id) ON DELETE CASCADE
      )
    ''');
  }


  // Hikes CRUD Operations
  // Add new hike
  Future<int> insertHike(Hike hike) async {
    final db = await database;
    return await db.insert('hikes', hike.toMap()); 
  }

  // Get all hikes
  Future<List<Hike>> getAllHikes() async {
    final db = await database;
    final bookMaps = await db.query(
      'hikes',
      orderBy: 'name ASC',
    );
    return bookMaps.map((map) => Hike.fromMap(map)).toList(); 
  }

  // Update hike
  Future<int> updateHike(Hike hike) async {
    final db = await database;
    return await db.update(
      'hikes',
      hike.toMap(),
      where: 'id = ?',
      whereArgs: [hike.id],
    );
  }

  // Delete hike
  Future<int> deleteHike(int hikeId) async {
    final db = await database;
    return await db.delete(
      'hikes',
      where: 'id = ?',
      whereArgs: [hikeId],
    );
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('observations'); 
    await db.delete('hikes'); 
  }

  // Search (d)
  Future<List<Hike>> searchHikes(String query) async {
    final db = await database;
    final bookMaps = await db.query(
      'hikes',
      where: 'name LIKE ?', 
      whereArgs: ['%$query%'], 
      orderBy: 'name ASC',
    );
    return bookMaps.map((map) => Hike.fromMap(map)).toList();
  }


  // Observations CRUD Operations
  // Add new observation
  Future<int> insertObservation(Observation observation) async {
    final db = await database;
    return await db.insert('observations', observation.toMap());
  }

  // Get all observations for single hike
  Future<List<Observation>> getAllObservationsForHike(int hikeId) async {
    final db = await database;
    final obsMaps = await db.query(
      'observations',
      where: 'hike_id = ?',
      whereArgs: [hikeId],
      orderBy: 'observation_time DESC',
    );
    return obsMaps.map((map) => Observation.fromMap(map)).toList();
  }

  // Delete an observation
  Future<int> deleteObservation(int observationId) async {
    final db = await database;
    return await db.delete(
      'observations',
      where: 'id = ?',
      whereArgs: [observationId],
    );
  }
}
