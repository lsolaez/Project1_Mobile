import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> get database async {
    return openDatabase(
      join(await getDatabasesPath(), 'progress.db'),
      onCreate: (db, version) async {
        // Crear la tabla para el progreso, ahora incluye grasas (fat)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS progress (
            date TEXT PRIMARY KEY,
            calories REAL,
            proteins REAL,
            carbs REAL,
            fat REAL
          )
        ''');

        // Crear la tabla para las metas, ahora incluye grasas (fat)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS goals (
            date TEXT PRIMARY KEY,
            calories REAL,
            proteins REAL,
            carbs REAL,
            fat REAL
          )
        ''');

        // Crear la tabla para la ingesta de agua
        await db.execute('''
          CREATE TABLE IF NOT EXISTS water (
            date TEXT PRIMARY KEY,
            water REAL
          )
        ''');

        // Crear la tabla para el tamaño del vaso
        await db.execute('''
          CREATE TABLE IF NOT EXISTS glassSize (
            date TEXT PRIMARY KEY,
            glassSize REAL
          )
        ''');
      },
      version: 4, // Cambiar versión a 4 para incluir "fat"
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS water (
              date TEXT PRIMARY KEY,
              water REAL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS glassSize (
              date TEXT PRIMARY KEY,
              glassSize REAL
            )
          ''');
        }
        if (oldVersion < 4) {
          // Añadir columna fat a las tablas "progress" y "goals"
          await db.execute('ALTER TABLE progress ADD COLUMN fat REAL');
          await db.execute('ALTER TABLE goals ADD COLUMN fat REAL');
        }
      },
    );
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Método para guardar o actualizar las metas para una fecha específica, ahora incluye grasas (fat)
  static Future<void> saveGoalsForDate(
      DateTime date, double calories, double proteins, double carbs, double fat) async {
    final db = await database;
    String formattedDate = formatDate(date);

    await db.insert(
      'goals',
      {
        'date': formattedDate,
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
        'fat': fat,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Método para obtener las metas de una fecha específica
  static Future<Map<String, dynamic>?> getGoalsForDate(DateTime date) async {
    final db = await database;
    String formattedDate = formatDate(date);

    List<Map<String, dynamic>> result = await db.query(
      'goals',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Método para guardar o actualizar el progreso de una fecha específica, ahora incluye grasas (fat)
  static Future<void> updateProgressForDate(
      DateTime date, double calories, double proteins, double carbs, double fat) async {
    final db = await database;
    String formattedDate = formatDate(date);

    await db.insert(
      'progress',
      {
        'date': formattedDate,
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
        'fat': fat,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Método para obtener el progreso de una fecha específica
  static Future<Map<String, dynamic>?> getProgressForDate(DateTime date) async {
    final db = await database;
    String formattedDate = formatDate(date);

    List<Map<String, dynamic>> result = await db.query(
      'progress',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Método para guardar o actualizar la ingesta de agua para una fecha específica
  static Future<void> updateWaterForDate(
      DateTime date, double waterAmount) async {
    final db = await database;
    String formattedDate = formatDate(date);

    await db.insert(
      'water',
      {
        'date': formattedDate,
        'water': waterAmount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplazar si ya existe
    );
  }

  // Método para guardar o actualizar el tamaño del vaso para una fecha específica
  static Future<void> saveGlassSizeForDate(DateTime date, double glassSize) async {
    final db = await database;
    String formattedDate = formatDate(date);

    await db.insert(
      'glassSize',
      {
        'date': formattedDate,
        'glassSize': glassSize,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplazar si ya existe
    );
  }

  // Método para obtener la ingesta de agua para una fecha específica
  static Future<Map<String, dynamic>?> getWaterForDate(DateTime date) async {
    final db = await database;
    String formattedDate = formatDate(date);

    List<Map<String, dynamic>> result = await db.query(
      'water',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Método para obtener el tamaño del vaso para una fecha específica
  static Future<Map<String, dynamic>?> getGlassSizeForDate(DateTime date) async {
    final db = await database;
    String formattedDate = formatDate(date);

    List<Map<String, dynamic>> result = await db.query(
      'glassSize',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Método para eliminar la base de datos (si necesitas resetearla)
  static Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'progress.db');
    await databaseFactory.deleteDatabase(path);
  }
}
