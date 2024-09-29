import 'package:flutter/material.dart';
import 'package:project1/Controllers/DietController.dart';


class ConsumptionDialog extends StatelessWidget {
  final DietController dietController;

  ConsumptionDialog({required this.dietController});

  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinsController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter your consumption'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: caloriesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calories',
            ),
          ),
          TextField(
            controller: proteinsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Proteins',
            ),
          ),
          TextField(
            controller: carbsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Carbs',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Cerrar el dialog sin guardar
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Convertimos los valores ingresados y actualizamos el controlador
            final double calories = double.tryParse(caloriesController.text) ?? 0;
            final double proteins = double.tryParse(proteinsController.text) ?? 0;
            final double carbs = double.tryParse(carbsController.text) ?? 0;

            dietController.addToChart(calories, proteins, carbs);

            // Cerrar el dialog
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
