import 'package:flutter/material.dart';
import 'package:project1/Controllers/dietController.dart';

class ConsumptionDialog extends StatefulWidget {
  final DietController dietController;
  final DateTime selectedDate;
  final String title; // Añadir título para identificar el nutriente

  const ConsumptionDialog({
    Key? key,
    required this.dietController,
    required this.selectedDate,
    required this.title, // Añadir este argumento
  }) : super(key: key);

  @override
  _ConsumptionDialogState createState() => _ConsumptionDialogState();
}

class _ConsumptionDialogState extends State<ConsumptionDialog> {
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update ${widget.title}'), // Mostrar el nutriente que se actualiza
      content: TextField(
        key: Key('${widget.title}TextField'),
        controller: _inputController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '${widget.title} (g)',
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
            final double value = double.tryParse(_inputController.text) ?? 0.0;

            // Actualizar el gráfico correspondiente
            if (widget.title == 'Calories') {
              widget.dietController.addToChart(value, 0, 0, 0, widget.selectedDate);
            } else if (widget.title == 'Proteins') {
              widget.dietController.addToChart(0, value, 0, 0, widget.selectedDate);
            } else if (widget.title == 'Carbs') {
              widget.dietController.addToChart(0, 0, value, 0, widget.selectedDate);
            } else if (widget.title == 'Fats') {
              widget.dietController.addToChart(0, 0, 0, value, widget.selectedDate);
            }

            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
