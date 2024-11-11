import 'package:flutter/material.dart';
import 'package:project1/screens/activity_screen.dart';

class NewActivityDialog extends StatefulWidget {
  final int userId;
  final DateTime selectedDate;
  final Function(Activity, String) onActivityAdded;

  NewActivityDialog({
    required this.userId,
    required this.selectedDate,
    required this.onActivityAdded,
  });

  @override
  _NewActivityDialogState createState() => _NewActivityDialogState();
}

class _NewActivityDialogState extends State<NewActivityDialog> {
  final nameController = TextEditingController();
  final frequencyController = TextEditingController();
  List<String> entries = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Activity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Activity Name'),
            ),
            TextField(
              controller: frequencyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Frequency'),
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
                  const Text(
                    'Entries:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...entries.map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              entries.remove(entry);
                            });
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final name = nameController.text;
            final frequency = frequencyController.text;
            if (name.isNotEmpty && frequency.isNotEmpty) {
              setState(() {
                String entry = '$name: $frequency times';
                entries.add(entry);
              });

              widget.onActivityAdded(
                Activity(name, 'Health', 'assets/imagenes/actividad.jpg'),
                entries.join(';'),
              );
              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
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
