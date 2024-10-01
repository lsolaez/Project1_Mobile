import 'package:get/get.dart';
import 'package:project1/Helpers/db_helper.dart';

class HydrationController extends GetxController {
  RxDouble totalWater = 0.0.obs; // Total de agua bebida
  final double dailyGoal = 3000.0; // Meta diaria de agua

  RxDouble glassSize = 250.0.obs; // Tamaño del vaso para cada día

  // Método para añadir agua para un día específico
  void addWater(double glassSize, DateTime selectedDate) {
    totalWater.value += glassSize;

    // Guardar la información de agua y el tamaño del vaso para la fecha seleccionada
    DBHelper.updateWaterForDate(selectedDate, totalWater.value);
    DBHelper.saveGlassSizeForDate(selectedDate, glassSize);
  }

  // Cargar la cantidad de agua y tamaño de vaso para la fecha seleccionada
  Future<void> loadWaterForDate(DateTime selectedDate) async {
    var data = await DBHelper.getWaterForDate(selectedDate);
    var glassData = await DBHelper.getGlassSizeForDate(selectedDate);

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
