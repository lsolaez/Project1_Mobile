import 'package:get/get.dart';
import 'package:project1/Helpers/db_helper.dart';

class HydrationController extends GetxController {
  RxDouble totalWater = 0.0.obs; // Total de agua bebida
  final double dailyGoal = 3000.0; // Meta diaria de agua
  RxDouble glassSize = 250.0.obs; // Tamaño del vaso

  int userId; // Id del usuario

  HydrationController(
      {required this.userId}); // Constructor que recibe el userId

  // Método para añadir agua para un día específico
  void addWater(double glassSize, int userId, DateTime selectedDate) {
    totalWater.value += glassSize;

    // Guardar la información de agua y el tamaño del vaso para la fecha seleccionada
    DBHelper.updateWaterForDate(userId, selectedDate, totalWater.value);
    DBHelper.saveGlassSizeForDate(userId, selectedDate, glassSize);

    // Verificar racha y otorgar crédito si se cumplen las condiciones
    checkStreakAndAwardCredit(userId, selectedDate);
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

// Método para verificar la racha de dos días consecutivos y otorgar crédito
  Future<void> checkStreakAndAwardCredit(
      int userId, DateTime selectedDate) async {
    // Obtener la última vez que se otorgó un crédito por agua
    DateTime? lastCreditDate = await DBHelper.getUltimoDiaCreditoAgua(userId);

    if (lastCreditDate == null) {
      lastCreditDate = DateTime(1970); // Fecha inicial para evitar nulos
    }

    DateTime previousDay = selectedDate.subtract(const Duration(days: 1));

    // Verificar si se ha alcanzado la meta de agua para los dos días consecutivos
    var waterToday = await DBHelper.getWaterForDate(userId, selectedDate);
    var waterYesterday = await DBHelper.getWaterForDate(userId, previousDay);

    double totalWaterToday = waterToday != null ? waterToday['water'] : 0.0;
    double totalWaterYesterday =
        waterYesterday != null ? waterYesterday['water'] : 0.0;

    // Solo otorgar crédito si se han alcanzado las metas de agua y el último crédito fue antes del día anterior
    if (lastCreditDate.isBefore(previousDay)) {
      if (totalWaterToday >= dailyGoal && totalWaterYesterday >= dailyGoal) {
        // Otorgar un crédito al usuario por el agua
        int currentCredits = await DBHelper.getCreditsForUser(userId);
        int newCredits = currentCredits + 1;
        await DBHelper.updateCreditsForUser(userId, newCredits);

        // Actualizar la fecha en que se otorgó el último crédito
        await DBHelper.setUltimoDiaCreditoAgua(userId, selectedDate);

        print(
            "Crédito por agua otorgado por completar dos días consecutivos con la meta de agua.");
      }
    }
  }
}
