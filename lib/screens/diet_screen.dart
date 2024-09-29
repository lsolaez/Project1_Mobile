import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project1/Controllers/DietController.dart';
import 'package:project1/widgets/ConsumptionDialog.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DietController dietController = Get.find();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,  // Asegurar que ocupe todo el ancho disponible
          children: [
            const Text(
              'Daily Nutrition Breakdown',
              textAlign: TextAlign.center,  // Centrar el texto del título
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            buildNutritionCard(
              'Proteins',
              dietController.totalProteins,
              dietController.maxProteins,
              Colors.blue,
              context, // Pasar el context para el diálogo
            ),
            const SizedBox(height: 20),
            buildNutritionCard(
              'Calories',
              dietController.totalCalories,
              dietController.maxCalories,
              Colors.orange,
              context,
            ),
            const SizedBox(height: 20),
            buildNutritionCard(
              'Carbs',
              dietController.totalCarbs,
              dietController.maxCarbs,
              Colors.green,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNutritionCard(String title, RxDouble currentValue, double maxValue, Color color, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Obx(() {
                return SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: currentValue.value / maxValue,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Obx(() {
              return Text(
                '$title: ${currentValue.value.toStringAsFixed(1)} / $maxValue',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              );
            }),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConsumptionDialog(dietController: Get.find());
                  },
                );
              },
              child: const Text('Update Consumption'),
            ),
          ],
        ),
      ),
    );
  }
}
