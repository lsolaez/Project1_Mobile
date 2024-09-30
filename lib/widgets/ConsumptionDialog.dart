import 'package:flutter/material.dart';
import 'package:project1/Controllers/dietController.dart';

class ConsumptionDialog extends StatefulWidget {
  final DietController dietController;
  final DateTime selectedDate;

  const ConsumptionDialog({
    Key? key,
    required this.dietController,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _ConsumptionDialogState createState() => _ConsumptionDialogState();
}

class _ConsumptionDialogState extends State<ConsumptionDialog> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinsController;
  late TextEditingController _carbsController;

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores de texto
    _caloriesController = TextEditingController();
    _proteinsController = TextEditingController();
    _carbsController = TextEditingController();
  }

  @override
  void dispose() {
    // Asegurarse de liberar los controladores cuando el widget se elimine
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Consumption'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de texto para ingresar las calorías
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calories (kcal)',
            ),
          ),
          const SizedBox(height: 10),
          // Campo de texto para ingresar las proteínas
          TextField(
            controller: _proteinsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Proteins (g)',
            ),
          ),
          const SizedBox(height: 10),
          // Campo de texto para ingresar los carbohidratos
          TextField(
            controller: _carbsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Carbs (g)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Cerrar el diálogo sin guardar
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Obtener los valores ingresados y actualizar el controlador
            final double calories = double.tryParse(_caloriesController.text) ?? 0.0;
            final double proteins = double.tryParse(_proteinsController.text) ?? 0.0;
            final double carbs = double.tryParse(_carbsController.text) ?? 0.0;

            // Pasar la fecha seleccionada como cuarto argumento
            widget.dietController.addToChart(calories, proteins, carbs, widget.selectedDate);

            // Cerrar el diálogo
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
