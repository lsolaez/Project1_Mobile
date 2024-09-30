import 'package:intl/intl.dart'; // Asegúrate de tener este import para usar DateFormat
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> get database async {
    return openDatabase(
      join(await getDatabasesPath(), 'progress.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS progress (
            date TEXT PRIMARY KEY,
            calories REAL,
            proteins REAL,
            carbs REAL
          )
        ''');
      },
      version: 1,
    );
  }

  static String formatDate(DateTime date) {
    // Formateamos la fecha sin milisegundos ni zonas horarias
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Método para insertar o actualizar el progreso de una fecha específica
  static Future<void> updateProgressForDate(DateTime date, double calories, double proteins, double carbs) async {
    final db = await database;

    String formattedDate = formatDate(date);

    await db.insert(
      'progress',
      {
        'date': formattedDate,
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si ya existe
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

  // Método para eliminar la base de datos (si necesitas resetearla)
  static Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'progress.db');
    await databaseFactory.deleteDatabase(path);
  }
}
