import 'package:get/get.dart';

class DietController extends GetxController {
  // Rx variables for reactive behavior
  RxDouble totalCalories = 0.0.obs;
  RxDouble totalProteins = 0.0.obs;
  RxDouble totalCarbs = 0.0.obs;

  // Máximos diarios para el ejemplo
  final double maxCalories = 2000;
  final double maxProteins = 100;
  final double maxCarbs = 300;

  // Función para añadir valores a las gráficas
  void addToChart(double calories, double proteins, double carbs) {
    totalCalories.value += calories;
    totalProteins.value += proteins;
    totalCarbs.value += carbs;
  }
}
