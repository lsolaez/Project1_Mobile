import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> get database async {
    return openDatabase(
      join(await getDatabasesPath(), 'progress.db'),
      onCreate: (db, version) async {
        // Crear tabla de usuarios
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT,
            email TEXT,
            phone TEXT,
            sex TEXT,
            age INTEGER,
            password TEXT
          )
        ''');

        // Crear las tablas de progreso y metas, ahora con el campo id (antes userId)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS progress (
            id INTEGER,
            date TEXT,
            calories REAL,
            proteins REAL,
            carbs REAL,
            fat REAL,
            PRIMARY KEY (id, date),
            FOREIGN KEY (id) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS goals (
            id INTEGER,
            date TEXT,
            calories REAL,
            proteins REAL,
            carbs REAL,
            fat REAL,
            PRIMARY KEY (id, date),
            FOREIGN KEY (id) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS water (
            id INTEGER,
            date TEXT,
            water REAL,
            PRIMARY KEY (id, date),
            FOREIGN KEY (id) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS glassSize (
            id INTEGER,
            date TEXT,
            glassSize REAL,
            PRIMARY KEY (id, date),
            FOREIGN KEY (id) REFERENCES users(id)
          )
        ''');
      },
      version: 5, // Nueva versión para actualizar las tablas
    );
  }

  // Método para registrar un nuevo usuario
  static Future<void> registerUser(
    String fullName,
    String email,
    String phone,
    String sex,
    int age,
    String password,
  ) async {
    final db = await database;

    await db.insert(
      'users',
      {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'sex': sex,
        'age': age,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Método para verificar el inicio de sesión
  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final db = await database;

    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Guardar o actualizar metas para un usuario
  static Future<void> saveGoalsForDate(
    int id,
    DateTime date,
    double calories,
    double proteins,
    double carbs,
    double fat,
  ) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    await db.insert(
      'goals',
      {
        'id': id,
        'date': formattedDate,
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
        'fat': fat,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Guardar o actualizar progreso para un usuario
  static Future<void> updateProgressForDate(
    int id,
    DateTime date,
    double calories,
    double proteins,
    double carbs,
    double fat,
  ) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    await db.insert(
      'progress',
      {
        'id': id,
        'date': formattedDate,
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
        'fat': fat,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Guardar ingesta de agua para un usuario
  static Future<void> updateWaterForDate(
      int id, DateTime date, double waterAmount) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    await db.insert(
      'water',
      {
        'id': id,
        'date': formattedDate,
        'water': waterAmount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Guardar tamaño del vaso para un usuario
  static Future<void> saveGlassSizeForDate(
      int id, DateTime date, double glassSize) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    await db.insert(
      'glassSize',
      {
        'id': id,
        'date': formattedDate,
        'glassSize': glassSize,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener metas de una fecha específica para un usuario
  static Future<Map<String, dynamic>?> getGoalsForDate(
      int id, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    List<Map<String, dynamic>> result = await db.query(
      'goals',
      where: 'id = ? AND date = ?',
      whereArgs: [id, formattedDate],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Obtener progreso de una fecha específica para un usuario
  static Future<Map<String, dynamic>?> getProgressForDate(
      int id, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    List<Map<String, dynamic>> result = await db.query(
      'progress',
      where: 'id = ? AND date = ?',
      whereArgs: [id, formattedDate],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Obtener ingesta de agua para una fecha específica y un usuario
  static Future<Map<String, dynamic>?> getWaterForDate(
      int id, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    List<Map<String, dynamic>> result = await db.query(
      'water',
      where: 'id = ? AND date = ?',
      whereArgs: [id, formattedDate],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Obtener tamaño del vaso para una fecha específica y un usuario
  static Future<Map<String, dynamic>?> getGlassSizeForDate(
      int id, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    List<Map<String, dynamic>> result = await db.query(
      'glassSize',
      where: 'id = ? AND date = ?',
      whereArgs: [id, formattedDate],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Método para obtener el ID de un usuario dado su correo electrónico
  static Future<int> getUserId(String email) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users', // Asegúrate de que la tabla 'users' tiene una columna id
      columns: ['id'], // Debe ser la columna que almacena el id
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first['id']; // Cambiado de 'userId' a 'id'
    } else {
      throw Exception('User not found');
    }
  }

  // Obtener el nombre completo de un usuario dado su correo electrónico
  static Future<String> getUserFullName(String email) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users', // Asegúrate de tener una tabla llamada 'users'
      columns: ['fullName'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first['fullName'];
    } else {
      return ''; // Si no se encuentra el usuario, devuelve una cadena vacía
    }
  }

  // Método para validar el usuario
  static Future<bool> validateUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where:
          'email = ? AND password = ?', // Asegúrate de que tengas una columna de "email" y "password"
      whereArgs: [email, password],
    );

    return result.isNotEmpty;
  }

  // Método para eliminar la base de datos (si necesitas resetearla)
  static Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'progress.db');
    await databaseFactory.deleteDatabase(path);
  }
}
