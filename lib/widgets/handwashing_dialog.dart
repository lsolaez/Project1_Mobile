import 'package:flutter/material.dart';

class HandwashingDialog extends StatelessWidget {
  final bool handwashingCompleted;
  final List<String> handwashingEntries;
  final Function(String) onAddEntry;
  final Function() onComplete;
  final Function() onSaveCompletion; // Función para guardar el estado de completitud

  HandwashingDialog({
    required this.handwashingCompleted,
    required this.handwashingEntries,
    required this.onAddEntry,
    required this.onComplete,
    required this.onSaveCompletion, // Añadido al constructor
  });

  @override
  Widget build(BuildContext context) {
    final secondsController = TextEditingController();

    return AlertDialog(
      title: Text(handwashingCompleted ? 'Activity Completed' : 'Add Handwashing Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!handwashingCompleted) ...[
              TextField(
                controller: secondsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Seconds'),
              ),
            ],
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Handwashing Entries:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...handwashingEntries.map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry),
                        if (!handwashingCompleted)
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Implementar la función de eliminación si es necesario
                            },
                          ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            if (handwashingCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'This activity has already been completed.',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (!handwashingCompleted)
          TextButton(
            onPressed: () {
              final seconds = secondsController.text;
              if (seconds.isNotEmpty) {
                String entry = '${seconds}s';
                onAddEntry(entry);
              }
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
        if (!handwashingCompleted)
          TextButton(
            onPressed: () {
              onComplete(); // Marca la actividad como completada en la UI
              onSaveCompletion(); // Llama a la función para guardar el estado en la base de datos
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Activity Completed'),
                    content: Text('The handwashing activity has been marked as completed.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Completed'),
          ),
      ],
    );
  }
}
