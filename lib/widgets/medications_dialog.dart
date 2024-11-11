import 'package:flutter/material.dart';

class MedicationsDialog extends StatelessWidget {
  final bool medicationsCompleted;
  final List<String> medicationsEntries;
  final Function(String) onAddEntry;
  final Function() onComplete;

  MedicationsDialog({
    required this.medicationsCompleted,
    required this.medicationsEntries,
    required this.onAddEntry,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    String selectedUnit = 'mg';
    String customUnit = '';

    return AlertDialog(
      title: Text(medicationsCompleted ? 'Activity Completed' : 'Add Medications Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!medicationsCompleted) ...[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Medication Name'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              DropdownButton<String>(
                value: selectedUnit,
                items: ['mg', 'g', 'ml', 'mm', 'others'].map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedUnit = newValue!;
                  if (selectedUnit != 'others') {
                    customUnit = '';
                  }
                },
              ),
              if (selectedUnit == 'others')
                TextField(
                  onChanged: (value) {
                    customUnit = value;
                  },
                  decoration: InputDecoration(labelText: 'Custom Unit'),
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
                    'Medications Entries:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...medicationsEntries.map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry),
                        if (!medicationsCompleted)
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
            if (medicationsCompleted)
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
        if (!medicationsCompleted)
          TextButton(
            onPressed: () {
              final name = nameController.text;
              final quantity = quantityController.text;
              if (name.isNotEmpty || quantity.isNotEmpty) {
                String entry = '$name: ${quantity.isNotEmpty ? quantity + (customUnit.isNotEmpty ? customUnit : selectedUnit) : ""}';
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
        if (!medicationsCompleted)
          TextButton(
            onPressed: onComplete,
            child: Text('Completed'),
          ),
      ],
    );
  }
}
