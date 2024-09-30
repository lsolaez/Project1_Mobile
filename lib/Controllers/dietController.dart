import 'package:get/get.dart';
import 'package:project1/Helpers/db_helper.dart';

class DietController extends GetxController {
  RxDouble totalCalories = 0.0.obs;
  RxDouble totalProteins = 0.0.obs;
  RxDouble totalCarbs = 0.0.obs;

  RxDouble maxCalories = 2000.0.obs;
  RxDouble maxProteins = 100.0.obs;
  RxDouble maxCarbs = 300.0.obs;

  // Método para agregar al progreso actual del día
  void addToChart(double calories, double proteins, double carbs, DateTime selectedDate) {
    totalCalories.value += calories;
    totalProteins.value += proteins;
    totalCarbs.value += carbs;

    // Guardar los datos usando la fecha seleccionada
    DBHelper.updateProgressForDate(selectedDate, totalCalories.value, totalProteins.value, totalCarbs.value);
  }

  // Método para cargar el progreso de un día específico
  Future<void> loadProgressForDate(DateTime selectedDate) async {
    var data = await DBHelper.getProgressForDate(selectedDate);

    if (data != null) {
      totalCalories.value = data['calories'];
      totalProteins.value = data['proteins'];
      totalCarbs.value = data['carbs'];
    } else {
      // Si no hay datos para la fecha seleccionada, reiniciar los valores
      totalCalories.value = 0.0;
      totalProteins.value = 0.0;
      totalCarbs.value = 0.0;
    }

    // Cargar las metas para el día seleccionado
    await loadGoalsForDate(selectedDate);
  }

  // Método para establecer las metas según la fecha seleccionada
  Future<void> setGoals(double calories, double proteins, double carbs, DateTime selectedDate) async {
    maxCalories.value = calories;
    maxProteins.value = proteins;
    maxCarbs.value = carbs;

    // Guardar las metas en la base de datos con la fecha seleccionada
    await DBHelper.saveGoalsForDate(selectedDate, calories, proteins, carbs);
  }

  // Método para cargar las metas de un día específico
  Future<void> loadGoalsForDate(DateTime selectedDate) async {
    var goals = await DBHelper.getGoalsForDate(selectedDate);

    if (goals != null) {
      maxCalories.value = goals['calories'];
      maxProteins.value = goals['proteins'];
      maxCarbs.value = goals['carbs'];
    } else {
      // Si no hay metas para la fecha seleccionada, establecer valores predeterminados
      maxCalories.value = 2000.0;
      maxProteins.value = 100.0;
      maxCarbs.value = 300.0;
    }
  }
}
