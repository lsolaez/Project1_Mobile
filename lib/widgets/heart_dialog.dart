import 'package:flutter/material.dart';

class HeartDialog extends StatelessWidget {
  final bool heartCompleted;
  final List<String> heartEntries;
  final Function(String) onAddEntry;
  final Function() onComplete;

  HeartDialog({
    required this.heartCompleted,
    required this.heartEntries,
    required this.onAddEntry,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final timeController = TextEditingController();

    return AlertDialog(
      title: Text(heartCompleted ? 'Activity Completed' : 'Add Heart Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!heartCompleted) ...[
              TextField(
                controller: systolicController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Systolic (mmHg)'),
              ),
              TextField(
                controller: diastolicController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Diastolic (mmHg)'),
              ),
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: 'Time (HH:mm)'),
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
                    'Heart Entries:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...heartEntries.map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry),
                        if (!heartCompleted)
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
            if (heartCompleted)
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
        if (!heartCompleted)
          TextButton(
            onPressed: () {
              final systolic = systolicController.text;
              final diastolic = diastolicController.text;
              final time = timeController.text;

              if (systolic.isNotEmpty || diastolic.isNotEmpty || time.isNotEmpty) {
                String entry = 'Systolic: $systolic mmHg, Diastolic: $diastolic mmHg at $time';
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
        if (!heartCompleted)
          TextButton(
            onPressed: onComplete,
            child: Text('Completed'),
          ),
      ],
    );
  }
}
