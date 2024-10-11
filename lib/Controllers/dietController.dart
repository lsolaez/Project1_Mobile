import 'package:get/get.dart';
import 'package:project1/helpers/db_helper.dart';

class DietController extends GetxController {
  RxDouble totalCalories = 0.0.obs;
  RxDouble totalProteins = 0.0.obs;
  RxDouble totalCarbs = 0.0.obs;
  RxDouble totalFat = 0.0.obs; // Ahora añadimos grasas

  RxDouble maxCalories = 2000.0.obs;
  RxDouble maxProteins = 100.0.obs;
  RxDouble maxCarbs = 300.0.obs;
  RxDouble maxFat = 70.0.obs; // Añadir meta de grasas

  final int userId; // ID del usuario, ahora requerido

  DietController({required this.userId});

  // Método para agregar al progreso actual del día
  void addToChart(double calories, double proteins, double carbs, double fat, DateTime selectedDate) {
    totalCalories.value += calories;
    totalProteins.value += proteins;
    totalCarbs.value += carbs;
    totalFat.value += fat; // Añadir grasas

    // Guardar los datos usando la fecha seleccionada y userId
    DBHelper.updateProgressForDate(userId, selectedDate, totalCalories.value, totalProteins.value, totalCarbs.value, totalFat.value);
  }

  // Método para cargar el progreso de un día específico
  Future<void> loadProgressForDate(DateTime selectedDate) async {
    var data = await DBHelper.getProgressForDate(userId, selectedDate);

    if (data != null) {
      totalCalories.value = data['calories'];
      totalProteins.value = data['proteins'];
      totalCarbs.value = data['carbs'];
      totalFat.value = data['fat']; // Cargar grasas
    } else {
      // Si no hay datos para la fecha seleccionada, reiniciar los valores
      totalCalories.value = 0.0;
      totalProteins.value = 0.0;
      totalCarbs.value = 0.0;
      totalFat.value = 0.0; // Reiniciar grasas
    }

    // Cargar las metas para el día seleccionado
    await loadGoalsForDate(selectedDate);
  }

  // Método para establecer las metas según la fecha seleccionada
  Future<void> setGoals(double calories, double proteins, double carbs, double fat, DateTime selectedDate) async {
    maxCalories.value = calories;
    maxProteins.value = proteins;
    maxCarbs.value = carbs;
    maxFat.value = fat; // Establecer meta de grasas

    // Guardar las metas en la base de datos con la fecha seleccionada y userId
    await DBHelper.saveGoalsForDate(userId, selectedDate, calories, proteins, carbs, fat);
  }

  // Método para cargar las metas de un día específico
  Future<void> loadGoalsForDate(DateTime selectedDate) async {
    var goals = await DBHelper.getGoalsForDate(userId, selectedDate);

    if (goals != null) {
      maxCalories.value = goals['calories'];
      maxProteins.value = goals['proteins'];
      maxCarbs.value = goals['carbs'];
      maxFat.value = goals['fat']; // Cargar metas de grasas
    } else {
      // Si no hay metas para la fecha seleccionada, establecer valores predeterminados
      maxCalories.value = 2000.0;
      maxProteins.value = 100.0;
      maxCarbs.value = 300.0;
      maxFat.value = 70.0; // Meta predeterminada de grasas
    }
  }
}
