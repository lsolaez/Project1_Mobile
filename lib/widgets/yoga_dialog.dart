import 'package:flutter/material.dart';

class YogaDialog extends StatelessWidget {
  final bool yogaCompleted;
  final List<String> yogaEntries;
  final Function(String) onAddEntry;
  final Function() onComplete;

  YogaDialog({
    required this.yogaCompleted,
    required this.yogaEntries,
    required this.onAddEntry,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    String selectedTime = 'Morning';

    return AlertDialog(
      title: Text(yogaCompleted ? 'Activity Completed' : 'Add Yoga Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!yogaCompleted) ...[
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
              DropdownButton<String>(
                value: selectedTime,
                items: <String>['Morning', 'Afternoon', 'Evening']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedTime = newValue!;
                },
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
                    'Yoga Entries:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...yogaEntries.map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry),
                        if (!yogaCompleted)
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
            if (yogaCompleted)
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
        if (!yogaCompleted)
          TextButton(
            onPressed: () {
              final hours = hoursController.text;
              final minutes = minutesController.text;
              if (hours.isNotEmpty || minutes.isNotEmpty) {
                String entry = '$selectedTime: ${hours.isNotEmpty ? hours + "h" : "0h"} ${minutes.isNotEmpty ? minutes + "m" : "0m"}';
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
        if (!yogaCompleted)
          TextButton(
            onPressed: onComplete,
            child: Text('Completed'),
          ),
      ],
    );
  }
}
