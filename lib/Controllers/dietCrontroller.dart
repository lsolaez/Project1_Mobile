import 'package:get/get.dart';
import 'package:project1/Helpers/db_helper.dart';


class DietController extends GetxController {
  RxDouble totalCalories = 0.0.obs;
  RxDouble totalProteins = 0.0.obs;
  RxDouble totalCarbs = 0.0.obs;

  final double maxCalories = 2000;
  final double maxProteins = 100;
  final double maxCarbs = 300;

  void addToChart(double calories, double proteins, double carbs, DateTime selectedDate) {
    totalCalories.value += calories;
    totalProteins.value += proteins;
    totalCarbs.value += carbs;

    // Guardar los datos usando la fecha seleccionada
    DBHelper.updateProgressForDate(selectedDate, totalCalories.value, totalProteins.value, totalCarbs.value);
  }

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
  }
}
