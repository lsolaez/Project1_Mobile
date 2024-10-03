import 'package:flutter/material.dart';
import 'package:project1/Controllers/dietController.dart';

class GoalSettingDialog extends StatelessWidget {
  final DietController dietController;
  final DateTime selectedDate;

  GoalSettingDialog({
    Key? key,
    required this.dietController,
    required this.selectedDate,
  }) : super(key: key);

  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinsController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController(); // Controlador para grasa

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Goals'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories',
              ),
            ),
            TextField(
              controller: _proteinsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Proteins (g)',
              ),
            ),
            TextField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Carbs (g)',
              ),
            ),
            TextField(
              controller: _fatController, // Campo de entrada para la grasa
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fat (g)',
              ),
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
        ElevatedButton(
          onPressed: () {
            double? calories = double.tryParse(_caloriesController.text);
            double? proteins = double.tryParse(_proteinsController.text);
            double? carbs = double.tryParse(_carbsController.text);
            double? fat = double.tryParse(_fatController.text); // Parsear el valor de grasa

            if (calories != null && proteins != null && carbs != null && fat != null) {
              // Actualizar las metas en el controlador y pasar la fecha seleccionada
              dietController.setGoals(calories, proteins, carbs, fat, selectedDate); // Ahora pasando el parámetro de grasa también

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
