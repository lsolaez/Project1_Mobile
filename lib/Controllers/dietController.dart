import 'package:get/get.dart';
import 'package:project1/Helpers/db_helper.dart';

class DietController extends GetxController {
  RxDouble totalCalories = 0.0.obs;
  RxDouble totalProteins = 0.0.obs;
  RxDouble totalCarbs = 0.0.obs;
  RxDouble totalFat = 0.0.obs;

  RxDouble maxCalories = 2000.0.obs;
  RxDouble maxProteins = 100.0.obs;
  RxDouble maxCarbs = 300.0.obs;
  RxDouble maxFat = 70.0.obs;

  final int userId;

  DietController({required this.userId});

  // Método para agregar al progreso actual del día
  void addToChart(double calories, double proteins, double carbs, double fat,
      DateTime selectedDate) {
    totalCalories.value += calories;
    totalProteins.value += proteins;
    totalCarbs.value += carbs;
    totalFat.value += fat;

    // Guardar los datos usando la fecha seleccionada y userId
    DBHelper.updateProgressForDate(userId, selectedDate, totalCalories.value,
        totalProteins.value, totalCarbs.value, totalFat.value);

    // Verificar racha usando la fecha seleccionada
    checkStreakAndAwardCredit(userId, selectedDate);
  }

  // Método para cargar el progreso de un día específico
  Future<void> loadProgressForDate(DateTime selectedDate) async {
    var data = await DBHelper.getProgressForDate(userId, selectedDate);

    if (data != null) {
      totalCalories.value = data['calories'];
      totalProteins.value = data['proteins'];
      totalCarbs.value = data['carbs'];
      totalFat.value = data['fat'];
    } else {
      totalCalories.value = 0.0;
      totalProteins.value = 0.0;
      totalCarbs.value = 0.0;
      totalFat.value = 0.0;
    }

    await loadGoalsForDate(selectedDate);
  }

  // Método para establecer las metas según la fecha seleccionada
  Future<void> setGoals(double calories, double proteins, double carbs,
      double fat, DateTime selectedDate) async {
    maxCalories.value = calories;
    maxProteins.value = proteins;
    maxCarbs.value = carbs;
    maxFat.value = fat;

    await DBHelper.saveGoalsForDate(
        userId, selectedDate, calories, proteins, carbs, fat);
  }

Future<void> loadGoalsForDate(DateTime selectedDate) async {
  var goals = await DBHelper.getGoalsForDate(userId, selectedDate);

  if (goals != null) {
    // Cargar metas desde la base de datos
    maxCalories.value = goals['calories'];
    maxProteins.value = goals['proteins'];
    maxCarbs.value = goals['carbs'];
    maxFat.value = goals['fat'];
  } else {
    // Si no se encuentran metas, establecer las metas por defecto
    maxCalories.value = 2000.0;
    maxProteins.value = 100.0;
    maxCarbs.value = 300.0;
    maxFat.value = 70.0;

    // Guardar las metas por defecto en la base de datos
    await DBHelper.saveGoalsForDate(
      userId,
      selectedDate,
      maxCalories.value,
      maxProteins.value,
      maxCarbs.value,
      maxFat.value,
    );

    print("Metas por defecto guardadas para la fecha $selectedDate");
  }
}


  // Método para verificar si el progreso cumple con las metas nutricionales
  bool isProgressComplete(
      Map<String, dynamic> progress, Map<String, dynamic> goals) {
    return (progress['calories'] >= goals['calories'] &&
        progress['proteins'] >= goals['proteins'] &&
        progress['carbs'] >= goals['carbs'] &&
        progress['fat'] >= goals['fat']);
  }

// Método para verificar la racha de dos días consecutivos y otorgar crédito
  Future<void> checkStreakAndAwardCredit(
      int userId, DateTime selectedDate) async {
    // Obtener la última vez que se otorgó un crédito por la dieta
    DateTime? lastCreditDate = await DBHelper.getUltimoDiaCreditoDieta(userId);

    if (lastCreditDate == null) {
      lastCreditDate = DateTime(1970); // Fecha inicial para evitar nulos
    }

    DateTime previousDay = selectedDate.subtract(const Duration(days: 1));

    // Verificar si los días seleccionados y anteriores cumplen con las metas
    var progressToday = await DBHelper.getProgressForDate(userId, selectedDate);
    var progressYesterday =
        await DBHelper.getProgressForDate(userId, previousDay);

    var goalsToday = await DBHelper.getGoalsForDate(userId, selectedDate);
    var goalsYesterday = await DBHelper.getGoalsForDate(userId, previousDay);
    print("Datos de progreso de hoy: $progressToday");
    print("Datos de progreso de ayer: $progressYesterday");
    print("Datos de metas de hoy: $goalsToday");
    print("Datos de metas de ayer: $goalsYesterday");

    print(
        "Progreso de hoy: $progressToday, Progreso de ayer: $progressYesterday");
    print("Metas de hoy: $goalsToday, Metas de ayer: $goalsYesterday");

    if (progressToday != null &&
        progressYesterday != null &&
        goalsToday != null &&
        goalsYesterday != null) {
      // Verificar que se cumplan todas las metas: calorías, proteínas, carbohidratos y grasas
      bool isProgressComplete(
          Map<String, dynamic> progress, Map<String, dynamic> goals) {
        print("Verificando progreso...");
        print(
            "Progreso: Calorías: ${progress['calories']}, Proteínas: ${progress['proteins']}, Carbs: ${progress['carbs']}, Grasa: ${progress['fat']}");
        print(
            "Metas: Calorías: ${goals['calories']}, Proteínas: ${goals['proteins']}, Carbs: ${goals['carbs']}, Grasa: ${goals['fat']}");

        return progress['calories'] >= goals['calories'] &&
            progress['proteins'] >= goals['proteins'] &&
            progress['carbs'] >= goals['carbs'] &&
            progress['fat'] >= goals['fat'];
      }

      if (isProgressComplete(progressToday, goalsToday) &&
          isProgressComplete(progressYesterday, goalsYesterday)) {
        // Otorgar un crédito al usuario por la dieta
        int currentCredits = await DBHelper.getCreditsForUser(userId);
        int newCredits = currentCredits + 1;
        await DBHelper.updateCreditsForUser(userId, newCredits);

        // Actualizar la fecha en que se otorgó el último crédito
        await DBHelper.setUltimoDiaCreditoDieta(userId, selectedDate);

        print(
            "Crédito por dieta otorgado por completar dos días consecutivos cumpliendo todas las metas.");
      } else {
        print("No se otorga crédito ya que no se cumplieron todas las metas.");
      }
    } else {
      print(
          "No se otorga crédito ya que no se encontraron datos para los días seleccionados.");
    }
  }
}
