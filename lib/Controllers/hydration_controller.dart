import 'package:get/get.dart';
import 'package:project1/Helpers/db_helper.dart';

class HydrationController extends GetxController {
  RxDouble totalWater = 0.0.obs; // Total de agua bebida
  final double dailyGoal = 3000.0; // Meta diaria de agua
  RxDouble glassSize = 250.0.obs; // Tamaño del vaso

  int userId; // Id del usuario

  HydrationController({required this.userId}); // Constructor que recibe el userId

  // Método para añadir agua para un día específico
  void addWater(double glassSize, int userId, DateTime selectedDate) {
    totalWater.value += glassSize;

    // Guardar la información de agua y el tamaño del vaso para la fecha seleccionada
    DBHelper.updateWaterForDate(userId, selectedDate, totalWater.value);
    DBHelper.saveGlassSizeForDate(userId, selectedDate, glassSize);
  }

  // Método para cargar la cantidad de agua y tamaño de vaso para la fecha seleccionada
  Future<void> loadWaterForDate(int userId, DateTime selectedDate) async {
    var data = await DBHelper.getWaterForDate(userId, selectedDate);
    var glassData = await DBHelper.getGlassSizeForDate(userId, selectedDate);

    if (data != null) {
      totalWater.value = data['water'];
    } else {
      totalWater.value = 0.0;
    }

    if (glassData != null) {
      glassSize.value = glassData['glassSize'];
    } else {
      glassSize.value = 250.0; // Tamaño de vaso predeterminado
    }
  }
}
