import 'package:flutter/material.dart';

class NewActivityDetailDialog extends StatelessWidget {
  final bool activityCompleted;
  final List<String> activityEntries;
  final Function(String) onAddEntry;
  final Function(String) onDeleteEntry;
  final Function() onComplete;
  final String activityTitle;

  NewActivityDetailDialog({
    required this.activityCompleted,
    required this.activityEntries,
    required this.onAddEntry,
    required this.onDeleteEntry,
    required this.onComplete,
    required this.activityTitle,
  });

  @override
  Widget build(BuildContext context) {
    final entryController = TextEditingController();

    return AlertDialog(
      title: Text(activityCompleted
          ? 'Activity Completed'
          : 'Add $activityTitle Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!activityCompleted)
              TextField(
                controller: entryController,
                decoration: InputDecoration(labelText: 'Entry'),
              ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Entries:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...activityEntries.map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry),
                        if (!activityCompleted)
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              onDeleteEntry(entry);
                            },
                          ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            if (activityCompleted)
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
        if (!activityCompleted)
          TextButton(
            onPressed: () {
              final entry = entryController.text;
              if (entry.isNotEmpty) {
                onAddEntry(entry);
              }
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        if (!activityCompleted)
          TextButton(
            onPressed: onComplete,
            child: Text('Completed'),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
