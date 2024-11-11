import 'package:flutter/material.dart';

class RunningDialog extends StatelessWidget {
  final bool runningCompleted;
  final List<String> runningEntries;
  final Function(String) onAddEntry;
  final Function() onComplete;

  RunningDialog({
    required this.runningCompleted,
    required this.runningEntries,
    required this.onAddEntry,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final distanceController = TextEditingController();
    final hoursController = TextEditingController();

    return AlertDialog(
      title: Text(runningCompleted ? 'Activity Completed' : 'Add Running Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!runningCompleted) ...[
              TextField(
                controller: distanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Distance (km)'),
              ),
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Time (hours)'),
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
                    'Running Entries:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...runningEntries.map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry),
                        if (!runningCompleted)
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
            if (runningCompleted)
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
        if (!runningCompleted)
          TextButton(
            onPressed: () {
              final distance = distanceController.text;
              final hours = hoursController.text;
              if (distance.isNotEmpty || hours.isNotEmpty) {
                String entry = '${distance.isNotEmpty ? distance + "km" : ""} ${hours.isNotEmpty ? hours + "h" : ""}';
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
        if (!runningCompleted)
          TextButton(
            onPressed: onComplete,
            child: Text('Completed'),
          ),
      ],
    );
  }
}
