import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project1/Helpers/db_helper.dart';

class ActivityScreen extends StatefulWidget {
  final int userId;
  final DateTime dateSelected;

  ActivityScreen({required this.userId, required this.dateSelected}) {
    print('Constructor: dateSelected is $dateSelected');
  }

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late DateTime selectedDate;
  List<Activity> activities = [];
  List<Activity> deletedActivities = [
    Activity('Medications', 'Health', 'assets/imagenes/Medications.jpg'),
    Activity('Sleep', 'Health', 'assets/imagenes/Sleep.jpg'),
    Activity('Heart', 'Health', 'assets/imagenes/Heart.jpg'),
    Activity('Running', 'Sports', 'assets/imagenes/Running.jpg'),
    Activity('Yoga', 'Sports', 'assets/imagenes/Yoga.jpg'),
    Activity('Handwashing', 'Health', 'assets/imagenes/Handwashing.jpg'),
  ];
  Map<String, List<String>> activityData = {};

  @override
  void initState() {
    super.initState();
    selectedDate = widget.dateSelected;
    loadActivitiesForDate();
    loadDeletedActivities();
  }

  @override
  void didUpdateWidget(ActivityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dateSelected != widget.dateSelected) {
      setState(() {
        selectedDate = widget.dateSelected;
        loadActivitiesForDate();
      });
    }
  }

  Future<void> loadActivitiesForDate() async {
    setState(() {
      activityData = {
        'Medications': [],
        'Sleep': [],
        'Yoga': [],
        'Running': [],
        'Handwashing': [],
        'Heart': [],
      };
    });

    List<Map<String, dynamic>> result =
        await DBHelper.getActivitiesForDate(widget.userId, selectedDate);

    setState(() {
      Map<String, List<String>> mutableActivityData =
          Map<String, List<String>>.from(activityData);

      activities.clear();

      activities = result.map((activityData) {
        String? activityTitle = activityData['title'] as String?;
        String? activityContent = activityData['data']?.toString();

        if (activityTitle != null && activityTitle.isNotEmpty) {
          if (activityContent != null && activityContent.isNotEmpty) {
            mutableActivityData[activityTitle] =
                List<String>.from(activityContent.split(';'));
          }

          return Activity(
            activityTitle,
            'Health',
            'assets/imagenes/$activityTitle.jpg',
          );
        } else {
          return Activity(
            'Unknown Activity',
            'Health',
            'assets/imagenes/default.jpg',
          );
        }
      }).toList();

      activityData = mutableActivityData;
    });

    loadDeletedActivities();
  }

  Future<void> loadDeletedActivities() async {
    List<String> allActivityTitles = [
      'Medications',
      'Sleep',
      'Yoga',
      'Running',
      'Handwashing',
      'Heart'
    ];
    List<String> activeActivityTitles =
        activities.map((activity) => activity.title).toList();

    setState(() {
      deletedActivities.clear();

      deletedActivities = allActivityTitles
          .where((title) => !activeActivityTitles.contains(title))
          .map((title) =>
              Activity(title, 'Health', 'assets/imagenes/$title.jpg'))
          .toList();
    });
  }

  Future<void> saveActivity(Activity activity, String data) async {
    await DBHelper.saveActivityForDate(
        widget.userId, activity.title, data, selectedDate);
    loadActivitiesForDate();
  }

  Future<void> deleteActivity(Activity activity) async {
    await DBHelper.deleteActivityForUser(
        widget.userId, activity.title, selectedDate);
    loadActivitiesForDate();
  }

  void showAddActivityDialog() {
    final nameController = TextEditingController();
    final frequencyController = TextEditingController();
    List<String> entries = [];

    showDialog(
      context: context,
      builder: (context) {
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

                  saveActivity(
                    Activity(name, 'Health', 'assets/imagenes/$name.jpg'),
                    entries.join(';'),
                  );
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Activities',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            showAddActivityDialog();
                          },
                        ),
                      ],
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
    final days = List.generate(7, (index) {
      final day = selectedDate
          .subtract(Duration(days: selectedDate.weekday - 1 - index));
      return Column(
        children: [
          Text(DateFormat.E().format(day)),
          Container(
            decoration: BoxDecoration(
              color: day.day == selectedDate.day
                  ? Colors.orange
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Text(
              day.day.toString(),
              style: TextStyle(
                fontWeight: day.day == selectedDate.day
                    ? FontWeight.bold
                    : FontWeight.normal,
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
        setState(() {
          if (isActive) {
            activities.remove(activity);
            deletedActivities.add(activity);
          } else {
            deletedActivities.remove(activity);
            activities.add(activity);
          }
        });

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
  bool sleepCompleted = false;

  void showSleepDialog() {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    List<String> sleepEntries = activityData['Sleep'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
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
                if (sleepCompleted)
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
            if (!sleepCompleted)
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

                    // Save the data in the database
                    String dataToSave = sleepEntries.join(';');
                    saveActivity(
                        Activity(
                            'Sleep', 'Health', 'assets/imagenes/Sleep.jpg'),
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
            if (!sleepCompleted)
              TextButton(
                onPressed: () {
                  setState(() {
                    sleepCompleted = true; // Mark the activity as completed
                  });
                  Navigator.of(context).pop();

                  // Show a message indicating the activity is completed
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Activity Completed'),
                        content: Text(
                            'The sleep activity has been marked as completed.'),
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
      },
    );
  }

  bool yogaCompleted =
      false; // Variable para controlar si la actividad está completada

  void showYogaDialog() {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    String selectedTime = 'Morning'; // Tiempo por defecto
    List<String> yogaEntries = activityData['Yoga'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
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
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTime = newValue!;
                      });
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
                // Mensaje de actividad completada, debajo de las entradas de yoga
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
            if (!yogaCompleted) // Botón para agregar datos solo si no está completado
              TextButton(
                onPressed: () {
                  final hours = hoursController.text;
                  final minutes = minutesController.text;
                  if (hours.isNotEmpty || minutes.isNotEmpty) {
                    setState(() {
                      // Formato de entrada: "morning: 1h 12m"
                      String entry =
                          '$selectedTime: ${hours.isNotEmpty ? hours + "h" : "0h"} ${minutes.isNotEmpty ? minutes + "m" : "0m"}';
                      yogaEntries.add(entry);
                      activityData['Yoga'] = yogaEntries;

                      // Guardar los datos en la base de datos
                      String dataToSave = yogaEntries.join(';');
                      saveActivity(
                        Activity('Yoga', 'Health', 'assets/imagenes/Yoga.jpg'),
                        dataToSave,
                      );
                    });
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
            if (!yogaCompleted) // Botón para marcar la actividad como completada
              TextButton(
                onPressed: () {
                  setState(() {
                    yogaCompleted = true; // Marcar la actividad como completada
                  });
                  Navigator.of(context).pop();

                  // Mostrar un mensaje indicando que la actividad está completada
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Activity Completed'),
                        content: Text(
                            'The yoga activity has been marked as completed.'),
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
      },
    );
  }

  bool runningCompleted =
      false; // Variable para controlar si la actividad está completada

  void showRunningDialog() {
    final distanceController = TextEditingController();
    final hoursController = TextEditingController();
    List<String> runningEntries = activityData['Running'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              runningCompleted ? 'Activity Completed' : 'Add Running Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!runningCompleted) ...[
                  // Mostrar campos solo si no está completada
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
                      const Text('Running Entries:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...runningEntries.map((entry) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry),
                            if (!runningCompleted) // Solo mostrar botón de eliminar si no está completada
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
                // Mensaje de actividad completada
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
            if (!runningCompleted) // Botón para agregar datos solo si no está completada
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

                      // Guardar los datos en la base de datos
                      String dataToSave = runningEntries.join(';');
                      saveActivity(
                          Activity('Running', 'Health',
                              'assets/imagenes/Running.jpg'),
                          dataToSave);
                    });
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
            if (!runningCompleted) // Botón para marcar la actividad como completada
              TextButton(
                onPressed: () {
                  setState(() {
                    runningCompleted =
                        true; // Marcar la actividad como completada
                  });
                  Navigator.of(context).pop();

                  // Mostrar un mensaje indicando que la actividad está completada
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Activity Completed'),
                        content: Text(
                            'The running activity has been marked as completed.'),
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
      },
    );
  }

  bool handwashingCompleted =
      false; // Variable para controlar si la actividad está completada

  void showHandwashingDialog() {
    final secondsController = TextEditingController();
    List<String> handwashingEntries = activityData['Handwashing'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(handwashingCompleted
              ? 'Activity Completed'
              : 'Add Handwashing Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!handwashingCompleted) ...[
                  // Mostrar campos solo si no está completada
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
                      const Text('Handwashing Entries:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...handwashingEntries.map((entry) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry),
                            if (!handwashingCompleted) // Solo mostrar botón de eliminar si no está completada
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
                // Mensaje de actividad completada
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
            if (!handwashingCompleted) // Botón para agregar datos solo si no está completada
              TextButton(
                onPressed: () {
                  final seconds = secondsController.text;
                  if (seconds.isNotEmpty) {
                    setState(() {
                      String entry = '${seconds}s';
                      handwashingEntries.add(entry);
                      activityData['Handwashing'] = handwashingEntries;

                      // Guardar los datos en la base de datos
                      String dataToSave = handwashingEntries.join(';');
                      saveActivity(
                          Activity('Handwashing', 'Health',
                              'assets/imagenes/Handwashing.jpg'),
                          dataToSave);
                    });
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
            if (!handwashingCompleted) // Botón para marcar la actividad como completada
              TextButton(
                onPressed: () {
                  setState(() {
                    handwashingCompleted =
                        true; // Marcar la actividad como completada
                  });
                  Navigator.of(context).pop();

                  // Mostrar un mensaje indicando que la actividad está completada
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Activity Completed'),
                        content: Text(
                            'The handwashing activity has been marked as completed.'),
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
      },
    );
  }

  bool heartCompleted =
      false; // Variable para controlar si la actividad está completada

  void showHeartDialog() {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final timeController = TextEditingController();
    List<String> heartEntries = List.from(activityData['Heart'] ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  heartCompleted ? 'Activity Completed' : 'Add Heart Data'),
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.9, // Ajusta el ancho del diálogo
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!heartCompleted) ...[
                        // Mostrar campos solo si no está completada
                        TextField(
                          controller: systolicController,
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(labelText: 'Systolic (mmHg)'),
                        ),
                        TextField(
                          controller: diastolicController,
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(labelText: 'Diastolic (mmHg)'),
                        ),
                        TextField(
                          controller: timeController,
                          decoration:
                              InputDecoration(labelText: 'Time (HH:mm)'),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                      Container(
                        margin: const EdgeInsets.only(top: 16.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Heart Entries:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (heartEntries.isNotEmpty)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 150, // Altura máxima para la lista
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: heartEntries.length,
                                  itemBuilder: (context, index) {
                                    return SingleChildScrollView(
                                      scrollDirection:
                                          Axis.horizontal, // Scroll horizontal
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(heartEntries[index]),
                                          if (!heartCompleted) // Solo mostrar botón de eliminar si no está completada
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  heartEntries.removeAt(index);
                                                  activityData['Heart'] =
                                                      heartEntries;

                                                  // Guardar los cambios en la base de datos
                                                  String dataToSave =
                                                      heartEntries.join(';');
                                                  saveActivity(
                                                    Activity('Heart', 'Health',
                                                        'assets/imagenes/Heart.jpg'),
                                                    dataToSave,
                                                  );
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              const SizedBox(), // Si no hay entradas, no mostrar nada
                          ],
                        ),
                      ),
                      // Mensaje de actividad completada
                      if (heartCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'This activity has already been completed.',
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (!heartCompleted) // Botón para agregar datos solo si no está completada
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

                          // Guardar los datos en la base de datos
                          String dataToSave = heartEntries.join(';');
                          saveActivity(
                            Activity(
                                'Heart', 'Health', 'assets/imagenes/Heart.jpg'),
                            dataToSave,
                          );
                        });
                      }
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                    child: const Text('Add'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  },
                  child: const Text('Close'),
                ),
                if (!heartCompleted) // Botón para marcar la actividad como completada
                  TextButton(
                    onPressed: () {
                      setState(() {
                        heartCompleted =
                            true; // Marcar la actividad como completada
                      });
                      Navigator.of(context).pop();

                      // Mostrar un mensaje indicando que la actividad está completada
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Activity Completed'),
                            content: Text(
                                'The heart activity has been marked as completed.'),
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
                    child: const Text('Completed'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  bool medicationsCompleted =
      false; // Variable para controlar si la actividad está completada

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
              title: Text(medicationsCompleted
                  ? 'Activity Completed'
                  : 'Add Medications Data'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!medicationsCompleted) ...[
                      // Mostrar campos solo si no está completada
                      TextField(
                        controller: nameController,
                        decoration:
                            InputDecoration(labelText: 'Medication Name'),
                      ),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Quantity'),
                      ),
                      DropdownButton<String>(
                        value: selectedUnit,
                        items: ['mg', 'g', 'ml', 'mm', 'others']
                            .map((String unit) {
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
                          const Text('Medications Entries:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...medicationsEntries.map((entry) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry),
                                if (!medicationsCompleted) // Solo mostrar botón de eliminar si no está completada
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
                    // Mensaje de actividad completada
                    if (medicationsCompleted)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'This activity has already been completed.',
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                if (!medicationsCompleted) // Botón para agregar datos solo si no está completada
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

                          // Guardar los datos en la base de datos
                          String dataToSave = medicationsEntries.join(';');
                          saveActivity(
                              Activity('Medications', 'Health',
                                  'assets/imagenes/Medications.jpg'),
                              dataToSave);
                        });
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
                if (!medicationsCompleted) // Botón para marcar la actividad como completada
                  TextButton(
                    onPressed: () {
                      setState(() {
                        medicationsCompleted =
                            true; // Marcar la actividad como completada
                      });
                      Navigator.of(context).pop();

                      // Mostrar un mensaje indicando que la actividad está completada
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Activity Completed'),
                            content: Text(
                                'The medications activity has been marked as completed.'),
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
