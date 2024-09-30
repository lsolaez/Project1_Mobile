import 'package:flutter/material.dart';
import 'package:project1/Controllers/dietController.dart';


class ConsumptionDialog extends StatelessWidget {
  final DietController dietController;
  final DateTime selectedDate;

  const ConsumptionDialog({
    Key? key,
    required this.dietController,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _caloriesController = TextEditingController();
    final TextEditingController _proteinsController = TextEditingController();
    final TextEditingController _carbsController = TextEditingController();

    return AlertDialog(
      title: const Text('Update Consumption'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Calories'),
          ),
          TextField(
            controller: _proteinsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Proteins (g)'),
          ),
          TextField(
            controller: _carbsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Carbs (g)'),
          ),
        ],
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
            final double calories = double.tryParse(_caloriesController.text) ?? 0;
            final double proteins = double.tryParse(_proteinsController.text) ?? 0;
            final double carbs = double.tryParse(_carbsController.text) ?? 0;

            // Llamar al controlador para agregar los valores a la gráfica
            dietController.addToChart(calories, proteins, carbs, selectedDate);

            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
