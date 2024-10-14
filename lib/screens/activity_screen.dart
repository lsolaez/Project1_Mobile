import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project1/Helpers/db_helper.dart'; // Asegúrate de tener importado DBHelper

class ActivityScreen extends StatefulWidget {
  final int userId;
  final DateTime dateSelected;

  ActivityScreen({required this.userId, required this.dateSelected});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> activities = [];
  List<Activity> deletedActivities = [
    Activity('Medications', 'Health', 'assets/imagenes/Medications.jpg'),
    Activity('Sleep', 'Health', 'assets/imagenes/Sleep.jpg'),
    Activity('Heart', 'Health', 'assets/imagenes/Heart.jpg'),
    Activity('Running', 'Sports', 'assets/imagenes/Running.jpg'),
    Activity('Yoga', 'Sports', 'assets/imagenes/Yoga.jpg'),
    Activity('Handwashing', 'Health', 'assets/imagenes/Handwashing.jpg'),
  ];
  Map<String, List<String>> activityData =
      {}; // Para almacenar las entradas de las actividades

  @override
  void initState() {
    super.initState();
    loadActivitiesForDate(); // Cargar actividades de la base de datos al iniciar
  }

  Future<void> loadActivitiesForDate() async {
    // Cargar las actividades de la base de datos para la fecha y usuario seleccionados
    List<Map<String, dynamic>> result =
        await DBHelper.getActivitiesForDate(widget.userId, widget.dateSelected);

    setState(() {
      activities.clear();
      activityData.clear();
      for (var row in result) {
        String title = row['title'];
        String data = row['data'];
        activityData[title] = data.split(';'); // Guardar los datos en el mapa
        activities.add(Activity(title, 'Health', 'assets/imagenes/$title.jpg'));
      }
    });
  }

  Future<void> saveActivity(Activity activity, String data) async {
    // Guardar actividad en la base de datos
    await DBHelper.saveActivityForDate(
        widget.userId, activity.title, data, widget.dateSelected);
    loadActivitiesForDate(); // Recargar las actividades actualizadas
  }

  Future<void> deleteActivity(Activity activity) async {
    // Eliminar actividad de la base de datos
    await DBHelper.deleteActivityForUser(
        widget.userId, activity.title, widget.dateSelected);
    loadActivitiesForDate(); // Recargar las actividades actualizadas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF9A8B), Color(0xFFF3ECEF)],
          ),
        ),
        child: Column(
          children: [
            buildCalendar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Available Activities',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...activities.map((activity) {
                    return buildDismissibleActivity(activity, true);
                  }).toList(),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'More Activities',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...deletedActivities.map((activity) {
                    return buildDismissibleActivity(activity, false);
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCalendar() {
    final today = DateTime.now();
    final days = List.generate(7, (index) {
      final day = today.subtract(Duration(days: today.weekday - 1 - index));
      return Column(
        children: [
          Text(DateFormat.E().format(day)),
          Container(
            decoration: BoxDecoration(
              color: day.day == today.day ? Colors.orange : Colors.transparent,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Text(
              day.day.toString(),
              style: TextStyle(
                fontWeight:
                    day.day == today.day ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    });
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days,
      ),
    );
  }

  Widget buildDismissibleActivity(Activity activity, bool isActive) {
    return Dismissible(
      key: Key(activity.title + (isActive ? 'active' : 'deleted')),
      direction: DismissDirection.endToStart,
      background: Container(
        color: isActive ? Colors.red : Colors.green,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          isActive ? Icons.delete : Icons.add,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) async {
        if (isActive) {
          await deleteActivity(activity); // Eliminar actividad si está activa
        } else {
          await saveActivity(activity, ''); // Agregar actividad eliminada
        }
      },
      child: GestureDetector(
        onTap: () {
          if (activity.title == 'Sleep') {
            showSleepDialog();
          } else if (activity.title == 'Yoga') {
            showYogaDialog();
          } else if (activity.title == 'Running') {
            showRunningDialog();
          } else if (activity.title == 'Handwashing') {
            showHandwashingDialog();
          } else if (activity.title == 'Heart') {
            showHeartDialog();
          } else if (activity.title == 'Medications') {
            showMedicationsDialog();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(activity.imagePath),
              radius: 31,
            ),
            title: Text(activity.title),
            subtitle: Text(
              activity.subtitle,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Icon(
              Icons.circle,
              color: isActive ? Colors.red : Colors.green,
              size: 12,
            ),
          ),
        ),
      ),
    );
  }

  // Implementación de los diálogos para cada actividad (Sleep, Yoga, etc.)

  void showSleepDialog() {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    List<String> sleepEntries = activityData['Sleep'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Sleep Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('Sleep Entries:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...sleepEntries.map((entry) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  sleepEntries.remove(entry);
                                  activityData['Sleep'] = sleepEntries;
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
                final hours = hoursController.text;
                final minutes = minutesController.text;
                if (hours.isNotEmpty || minutes.isNotEmpty) {
                  setState(() {
                    String entry =
                        '${hours.isNotEmpty ? hours + "h" : ""} ${minutes.isNotEmpty ? minutes + "m" : ""}';
                    sleepEntries.add(entry);
                    activityData['Sleep'] = sleepEntries;
                  });

                  // Guardar los datos reales en la base de datos
                  String dataToSave = sleepEntries.join(';');
                  saveActivity(
                      Activity('Sleep', 'Health', 'assets/imagenes/Sleep.jpg'),
                      dataToSave);
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
          ],
        );
      },
    );
  }

  void showYogaDialog() {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    String selectedTimeOfDay = 'Morning';
    List<String> yogaEntries = activityData['Yoga'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Yoga Data'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: selectedTimeOfDay,
                      items: ['Morning', 'Afternoon', 'Evening']
                          .map((String time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTimeOfDay = newValue!;
                        });
                      },
                    ),
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
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Yoga Entries:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...yogaEntries.map((entry) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      yogaEntries.remove(entry);
                                      activityData['Yoga'] = yogaEntries;
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
                    final hours = hoursController.text;
                    final minutes = minutesController.text;
                    if (hours.isNotEmpty || minutes.isNotEmpty) {
                      setState(() {
                        String entry =
                            '$selectedTimeOfDay: ${hours.isNotEmpty ? hours + "h" : ""} ${minutes.isNotEmpty ? minutes + "m" : ""}';
                        yogaEntries.add(entry);
                        activityData['Yoga'] = yogaEntries;
                      });

                      // Guardar los datos reales en la base de datos
                      String dataToSave = yogaEntries.join(';');
                      saveActivity(
                          Activity(
                              'Yoga', 'Health', 'assets/imagenes/Yoga.jpg'),
                          dataToSave);
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
              ],
            );
          },
        );
      },
    );
  }

  void showRunningDialog() {
    final distanceController = TextEditingController();
    final hoursController = TextEditingController();
    List<String> runningEntries = activityData['Running'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Running Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('Running Entries:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...runningEntries.map((entry) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  runningEntries.remove(entry);
                                  activityData['Running'] = runningEntries;
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
                final distance = distanceController.text;
                final hours = hoursController.text;
                if (distance.isNotEmpty || hours.isNotEmpty) {
                  setState(() {
                    String entry =
                        '${distance.isNotEmpty ? distance + "km" : ""} ${hours.isNotEmpty ? hours + "h" : ""}';
                    runningEntries.add(entry);
                    activityData['Running'] = runningEntries;
                  });

                  // Guardar los datos reales en la base de datos
                  String dataToSave = runningEntries.join(';');
                  saveActivity(
                      Activity(
                          'Running', 'Health', 'assets/imagenes/Running.jpg'),
                      dataToSave);
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
          ],
        );
      },
    );
  }

  void showHandwashingDialog() {
    final secondsController = TextEditingController();
    List<String> handwashingEntries = activityData['Handwashing'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Handwashing Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: secondsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Seconds'),
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
                      const Text('Handwashing Entries:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...handwashingEntries.map((entry) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  handwashingEntries.remove(entry);
                                  activityData['Handwashing'] =
                                      handwashingEntries;
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
                final seconds = secondsController.text;
                if (seconds.isNotEmpty) {
                  setState(() {
                    String entry = '${seconds}s';
                    handwashingEntries.add(entry);
                    activityData['Handwashing'] = handwashingEntries;
                  });

                  // Guardar los datos reales en la base de datos
                  String dataToSave = handwashingEntries.join(';');
                  saveActivity(
                      Activity('Handwashing', 'Health',
                          'assets/imagenes/Handwashing.jpg'),
                      dataToSave);
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
          ],
        );
      },
    );
  }

  void showHeartDialog() {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final timeController = TextEditingController();
    List<String> heartEntries = activityData['Heart'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Heart Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('Heart Entries:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...heartEntries.map((entry) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  heartEntries.remove(entry);
                                  activityData['Heart'] = heartEntries;
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
                final systolic = systolicController.text;
                final diastolic = diastolicController.text;
                final time = timeController.text;
                if (systolic.isNotEmpty ||
                    diastolic.isNotEmpty ||
                    time.isNotEmpty) {
                  setState(() {
                    String entry =
                        'Systolic: $systolic mmHg, Diastolic: $diastolic mmHg at $time';
                    heartEntries.add(entry);
                    activityData['Heart'] = heartEntries;
                  });

                  // Guardar los datos reales en la base de datos
                  String dataToSave = heartEntries.join(';');
                  saveActivity(
                      Activity('Heart', 'Health', 'assets/imagenes/Heart.jpg'),
                      dataToSave);
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
          ],
        );
      },
    );
  }

  void showMedicationsDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    String selectedUnit = 'mg';
    String customUnit = '';

    // Obtener los datos de medicamentos solo para la fecha seleccionada
    List<String> medicationsEntries = activityData['Medications'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Medications Data'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      items:
                          ['mg', 'g', 'ml', 'mm', 'others'].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUnit = newValue!;
                          if (selectedUnit != 'others') {
                            customUnit = '';
                          }
                        });
                      },
                    ),
                    if (selectedUnit == 'others')
                      TextField(
                        onChanged: (value) {
                          customUnit = value;
                        },
                        decoration: InputDecoration(labelText: 'Custom Unit'),
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
                          const Text('Medications Entries:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...medicationsEntries.map((entry) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      medicationsEntries.remove(entry);
                                      activityData['Medications'] =
                                          medicationsEntries;
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
                    final quantity = quantityController.text;
                    if (name.isNotEmpty || quantity.isNotEmpty) {
                      setState(() {
                        String entry =
                            '$name: ${quantity.isNotEmpty ? quantity + (customUnit.isNotEmpty ? customUnit : selectedUnit) : ""}';
                        medicationsEntries.add(entry);
                        activityData['Medications'] = medicationsEntries;
                      });

                      // Guardar los datos reales en la base de datos
                      String dataToSave = medicationsEntries.join(';');
                      saveActivity(
                          Activity('Medications', 'Health',
                              'assets/imagenes/Medications.jpg'),
                          dataToSave);
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
              ],
            );
          },
        );
      },
    );
  }
}

class Activity {
  final String title;
  final String subtitle;
  final String imagePath;

  Activity(this.title, this.subtitle, this.imagePath);
}
