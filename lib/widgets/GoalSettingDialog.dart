import 'package:flutter/material.dart';
import 'package:project1/Controllers/dietController.dart';

class GoalSettingDialog extends StatelessWidget {
  final DietController dietController;
  final DateTime selectedDate;

  GoalSettingDialog({required this.dietController, required this.selectedDate});

  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinsController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Daily Goals'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calories Goal (kcal)'),
            ),
            TextField(
              controller: _proteinsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Proteins Goal (g)'),
            ),
            TextField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Carbs Goal (g)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Obtener los valores ingresados por el usuario
            double? calories = double.tryParse(_caloriesController.text);
            double? proteins = double.tryParse(_proteinsController.text);
            double? carbs = double.tryParse(_carbsController.text);

            if (calories != null && proteins != null && carbs != null) {
              // Actualizar las metas en el controlador y pasar la fecha seleccionada
              dietController.setGoals(calories, proteins, carbs, selectedDate);
              Navigator.of(context).pop(); // Cerrar el diálogo después de guardar
            } else {
              // Mostrar un mensaje de error si los valores no son válidos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter valid numbers for all goals.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
