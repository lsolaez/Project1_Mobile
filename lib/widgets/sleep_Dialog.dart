import 'package:flutter/material.dart';

class SleepDialog extends StatelessWidget {
  final bool sleepCompleted;
  final List<String> sleepEntries;
  final Function(String) onAddEntry;
  final Function() onComplete;

  SleepDialog({
    required this.sleepCompleted,
    required this.sleepEntries,
    required this.onAddEntry,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();

    return AlertDialog(
      title: Text(sleepCompleted ? 'Activity Completed' : 'Add Sleep Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!sleepCompleted) ...[
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Hours'),
              ),
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Minutes'),
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
                    'Sleep Entries:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...sleepEntries.map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry),
                        if (!sleepCompleted)
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
            if (sleepCompleted)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'This activity has already been completed.',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (!sleepCompleted)
          TextButton(
            key: const Key('SleepcompleteButton'),
            onPressed: () {
              final hours = hoursController.text;
              final minutes = minutesController.text;
              if (hours.isNotEmpty || minutes.isNotEmpty) {
                String entry =
                    '${hours.isNotEmpty ? hours + "h" : ""} ${minutes.isNotEmpty ? minutes + "m" : ""}';
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
        if (!sleepCompleted)
          TextButton(
            onPressed: onComplete,
            child: Text('Completed'),
          ),
      ],
    );
  }
}
