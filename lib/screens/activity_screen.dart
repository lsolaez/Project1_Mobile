import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project1/Helpers/db_helper.dart';

class ActivityScreen extends StatefulWidget {
  final int userId;
  final DateTime dateSelected;

  ActivityScreen({required this.userId, required this.dateSelected});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> activities = [];
  List<Activity> deletedActivities = [];
  late DateTime selectedDate;
  Map<String, List<String>> activityData = {
    'Medications': [],
    'Sleep': [],
    'Yoga': [],
    'Running': [],
    'Handwashing': [],
    'Heart': [],
  }; // Aquí se guardarán los datos de la actividad

  @override
  void initState() {
    super.initState();
    selectedDate = widget.dateSelected; // Asigna la fecha seleccionada
    loadActivitiesForDate();
    loadDeletedActivities(); // Cargar actividades eliminadas
  }

  // Método para detectar cambios en el widget, en particular la fecha seleccionada
  @override
  void didUpdateWidget(ActivityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Solo actualizar si la fecha seleccionada cambió
    if (oldWidget.dateSelected != widget.dateSelected) {
      setState(() {
        selectedDate = widget.dateSelected;
        loadActivitiesForDate(); // Cargar actividades para la nueva fecha
      });
    }
  }

  // Cargar las actividades activas
  Future<void> loadActivitiesForDate() async {
    // Limpiar los datos antes de cargar nuevas actividades
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

    // Ahora cargar las actividades de la base de datos para la fecha seleccionada
    List<Map<String, dynamic>> result =
        await DBHelper.getActivitiesForDate(widget.userId, selectedDate);

    setState(() {
      Map<String, List<String>> mutableActivityData =
          Map<String, List<String>>.from(activityData);

      // Limpiar la lista de actividades antes de cargar nuevas
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
            'Health', // Puedes manejar el subtítulo como desees
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

    // Asegúrate de que las actividades eliminadas estén actualizadas
    loadDeletedActivities();
  }

  // Cargar las actividades eliminadas (More Activities)
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
      // Limpiar la lista de actividades eliminadas antes de cargar nuevas
      deletedActivities.clear();

      // Filtrar actividades que no estén activas
      deletedActivities = allActivityTitles
          .where((title) => !activeActivityTitles.contains(title))
          .map((title) =>
              Activity(title, 'Health', 'assets/imagenes/$title.jpg'))
          .toList();
    });
  }

  Future<void> saveActivity(Activity activity, String data) async {
    await DBHelper.saveActivityForDate(
        widget.userId,
        activity.title,
        data, // Aquí ahora pasamos el valor de data
        selectedDate);
    loadActivitiesForDate();
    loadDeletedActivities();
  }

  Future<void> deleteActivity(Activity activity) async {
    await DBHelper.deleteActivityForUser(
        widget.userId, activity.title, selectedDate);
    loadActivitiesForDate();
    loadDeletedActivities();
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
          // Aseguramos que el ListView expanda correctamente
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
            // Remover de actividades activas
            activities.remove(activity);
            // Agregar a actividades eliminadas
            deletedActivities.add(activity);
          } else {
            // Remover de actividades eliminadas
            deletedActivities.remove(activity);
            // Agregar a actividades activas
            activities.add(activity);
          }
        });

        // Ejecutar la acción después de modificar las listas
        if (isActive) {
          await deleteActivity(activity);
        } else {
          await saveActivity(
              activity, activityData[activity.title]?.join(';') ?? '');
        }
      },
      child: GestureDetector(
        onTap: () {
          openActivityDetails(
              activity); // Llamada para abrir el diálogo según la actividad
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

  void openActivityDetails(Activity activity) {
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
  }

  // Diálogo de Medications
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
                        decoration:
                            InputDecoration(labelText: 'Custom Unit'),
                      ),
                    SizedBox(
                      height: 150,
                      child: ListView(
                        shrinkWrap: true,
                        children: medicationsEntries.map((entry) {
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

                      // Guardar los datos reales
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

  // El resto de los diálogos se mantienen igual, pero ya cuentan con la limpieza de los datos por fecha.

  // Diálogo de Sleep
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
                SizedBox(
                  height: 150,
                  child: ListView(
                    shrinkWrap: true,
                    children: sleepEntries.map((entry) {
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

                  // Guardar los datos reales
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

  // Diálogo de Yoga
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
                    SizedBox(
                      height: 150,
                      child: ListView(
                        shrinkWrap: true,
                        children: yogaEntries.map((entry) {
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

                      // Guardar los datos reales
                      String dataToSave = yogaEntries.join(';');
                      saveActivity(
                          Activity(
                              'Yoga', 'Sports', 'assets/imagenes/Yoga.jpg'),
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

  // Diálogo de Running
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
                SizedBox(
                  height: 150,
                  child: ListView(
                    shrinkWrap: true,
                    children: runningEntries.map((entry) {
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

                  // Guardar los datos reales
                  String dataToSave = runningEntries.join(';');
                  saveActivity(
                      Activity(
                          'Running', 'Sports', 'assets/imagenes/Running.jpg'),
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

  // Diálogo de Handwashing
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
                SizedBox(
                  height: 150,
                  child: ListView(
                    shrinkWrap: true,
                    children: handwashingEntries.map((entry) {
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

                  // Guardar los datos reales
                  String dataToSave = handwashingEntries.join(';');
                  saveActivity(
                      Activity('Handwashing', 'Health',
                          'assets/imagenes/Handwashing.jpg'),
                      dataToSave);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo de Heart
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
                SizedBox(
                  height: 150,
                  child: ListView(
                    shrinkWrap: true,
                    children: heartEntries.map((entry) {
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

                  // Guardar los datos reales
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
}

class Activity {
  final String title;
  final String subtitle;
  final String imagePath;

  Activity(this.title, this.subtitle, this.imagePath);
}
