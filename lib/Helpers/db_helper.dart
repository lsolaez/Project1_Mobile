import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:project1/screens/activity_screen.dart';
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
          password TEXT,
          profileImage TEXT default 'assets/imagenes/profile_pic.png',
          credits INTEGER DEFAULT 0,
          ultimoDiaCreditoDieta TEXT,
          ultimoDiaCreditoAgua TEXT
        )
        ''');
        // Agregar tabla de premios canjeados
        await db.execute('''
          CREATE TABLE IF NOT EXISTS claimed_rewards (
            userId INTEGER,
            rewardName TEXT,
            PRIMARY KEY (userId, rewardName),
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');

        // Crear las tablas de progreso y metas
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

        // Tabla de actividades
        await db.execute('''
          CREATE TABLE IF NOT EXISTS activities (
            userId INTEGER,
            title TEXT,
            date TEXT,
            data TEXT,
            isCompleted INTEGER DEFAULT 0,
            PRIMARY KEY (userId, title, date),
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
      },
      version: 7,
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

  static Future<DateTime?> getUltimoDiaCreditoDieta(int userId) async {
    final db = await database;
    var result = await db.query(
      'users',
      columns: ['ultimoDiaCreditoDieta'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty && result.first['ultimoDiaCreditoDieta'] != null) {
      final ultimoDiaCreditoStr =
          result.first['ultimoDiaCreditoDieta']?.toString();
      return DateTime.parse(ultimoDiaCreditoStr!); // Aseguramos que no sea nulo
    }

    return null;
  }

  static Future<DateTime?> getUltimoDiaCreditoAgua(int userId) async {
    final db = await database;
    var result = await db.query(
      'users',
      columns: ['ultimoDiaCreditoAgua'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty && result.first['ultimoDiaCreditoAgua'] != null) {
      final ultimoDiaCreditoStr =
          result.first['ultimoDiaCreditoAgua']?.toString();
      return DateTime.parse(ultimoDiaCreditoStr!); // Aseguramos que no sea nulo
    }

    return null;
  }

  static Future<void> setUltimoDiaCreditoDieta(
      int userId, DateTime date) async {
    final db = await database;
    await db.update(
      'users',
      {'ultimoDiaCreditoDieta': DateFormat('yyyy-MM-dd').format(date)},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  static Future<void> setUltimoDiaCreditoAgua(int userId, DateTime date) async {
    final db = await database;
    await db.update(
      'users',
      {'ultimoDiaCreditoAgua': DateFormat('yyyy-MM-dd').format(date)},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Método para verificar si el usuario cumplió sus metas en una fecha
  static Future<bool> cumplioMetasParaFecha(int userId, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    var result = await db.query(
      'progress',
      where: 'id = ? AND date = ?',
      whereArgs: [userId, formattedDate],
    );

    if (result.isNotEmpty) {
      return true; // Si se encontraron resultados, metas cumplidas
    }
    return false; // Si no, metas no cumplidas
  }

  static Future<Map<String, dynamic>?> getUserData(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Actualizar la información del perfil del usuario (sin cambiar la imagen)
  static Future<void> updateUserProfile(
    int userId,
    String fullName,
    String email,
    String phone,
    String sex,
    int age,
  ) async {
    final db = await database;
    await db.update(
      'users',
      {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'sex': sex,
        'age': age,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Método para obtener los créditos actuales de un usuario
  static Future<int> getCreditsForUser(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['credits'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return result.first['credits'];
    } else {
      return 0; // Si no se encuentra, devolvemos 0 créditos
    }
  }

  // Método para actualizar los créditos de un usuario
  static Future<void> updateCreditsForUser(int userId, int credits) async {
    final db = await database;
    await db.update(
      'users',
      {'credits': credits},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Método para registrar un canje de premio
  static Future<void> redeemReward(int userId, String rewardName) async {
    final db = await database;

    // Insertar el premio reclamado en la tabla claimed_rewards
    await db.insert(
      'claimed_rewards',
      {
        'userId': userId,
        'rewardName': rewardName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Evitar duplicados
    );
  }

  static Future<bool> isRewardClaimed(int userId, String rewardName) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'claimed_rewards',
      where: 'userId = ? AND rewardName = ?',
      whereArgs: [userId, rewardName],
    );

    return result.isNotEmpty; // Devuelve true si el premio ya fue reclamado
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

  // Obtener actividades para un usuario en una fecha específica
  static Future<List<Activity>> getActivitiesForUser(
      int userId, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final result = await db.query(
      'activities',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, formattedDate],
    );

    return result.map((activityData) {
      return Activity(
        activityData['title'] as String,
        'Health', // El subtítulo puede ser gestionado en la UI
        'assets/imagenes/${activityData['title']}.jpg',
      );
    }).toList();
  }

// Actualizar el estado de completitud de una actividad
static Future<void> updateActivityCompletionStatus(int userId, String title, DateTime date, bool isCompleted) async {
    final db = await database;
    int completionStatus = isCompleted ? 1 : 0;

    // Convertimos `date` a solo la parte de la fecha en el mismo formato que se guardó
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    print('Updating completion status for $title to $completionStatus on $formattedDate');

    await db.update(
      'activities',
      {'isCompleted': completionStatus},
      where: 'userId = ? AND title = ? AND date = ?',
      whereArgs: [userId, title, formattedDate],
    );

    // Verifica si la actualización tuvo éxito
    final updatedActivity = await db.query(
      'activities',
      where: 'userId = ? AND title = ? AND date = ?',
      whereArgs: [userId, title, formattedDate],
    );
    print('Updated activity: $updatedActivity');
  }

  // Guardar actividad para un usuario en una fecha
  static Future<void> saveActivityForUser(
      int userId, String title, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    await db.insert(
      'activities',
      {
        'userId': userId,
        'title': title,
        'date': formattedDate,
        'data': '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Eliminar actividad para un usuario en una fecha
  static Future<void> deleteActivityForUser(
      int userId, String title, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    await db.delete(
      'activities',
      where: 'userId = ? AND title = ? AND date = ?',
      whereArgs: [userId, title, formattedDate],
    );
  }

  // Guardar datos específicos de una actividad en una fecha
  static Future<void> saveActivityDataForUser(
      int userId, String title, DateTime date, String data) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    await db.update(
      'activities',
      {'data': data},
      where: 'userId = ? AND title = ? AND date = ?',
      whereArgs: [userId, title, formattedDate],
    );
  }

  // Obtener metas de una fecha específica para un usuario
  static Future<Map<String, dynamic>?> getGoalsForDate(
      int userId, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd')
        .format(date); // Asegura que el formato de la fecha coincida

    // Consulta a la tabla 'goals' para obtener las metas del día y el usuario
    List<Map<String, dynamic>> result = await db.query(
      'goals', // Asegúrate de que este sea el nombre correcto de tu tabla de metas
      where: 'Id = ? AND date = ?', // Cambia los campos según tu esquema
      whereArgs: [userId, formattedDate], // Pasa los argumentos correctos
    );

    if (result.isNotEmpty) {
      print("Metas encontradas para la fecha $formattedDate: ${result.first}");
      return result.first; // Devuelve el primer resultado
    } else {
      print("No se encontraron metas para la fecha $formattedDate");
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
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first['id'];
    } else {
      throw Exception('User not found');
    }
  }

  // Obtener el nombre completo de un usuario dado su correo electrónico
  static Future<String> getUserFullName(String email) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['fullName'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first['fullName'];
    } else {
      return '';
    }
  }

  // Método para validar el usuario
  static Future<bool> validateUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty;
  }

  // Obtener actividades para un usuario en una fecha específica
  static Future<List<Map<String, dynamic>>> getActivitiesForDate(
      int userId, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    List<Map<String, dynamic>> result = await db.query(
      'activities',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, formattedDate],
    );

    return result;
  }

  // Guardar una actividad para un usuario en una fecha específica
  static Future<void> saveActivityForDate(
      int userId, String title, String data, DateTime date,
      {bool isCompleted = false}) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    await db.insert(
      'activities',
      {
        'userId': userId,
        'title': title,
        'date': formattedDate,
        'data': data,
        'isCompleted':
            isCompleted ? 1 : 0, // Guarda 1 si está completa, 0 si no
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Método para eliminar la base de datos
  static Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'progress.db');
    await databaseFactory.deleteDatabase(path);
  }
}
