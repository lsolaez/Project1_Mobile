import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project1/Helpers/db_helper.dart';
import 'package:project1/widgets/handwashing_dialog.dart';
import 'package:project1/widgets/heart_dialog.dart';
import 'package:project1/widgets/medications_dialog.dart';
import 'package:project1/widgets/new_activity_detail.dart';
import 'package:project1/widgets/new_activity_dialog.dart';
import 'package:project1/widgets/running_dialog.dart';
import 'package:project1/widgets/sleep_Dialog.dart';
import 'package:project1/widgets/yoga_dialog.dart';

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

  // Lista de actividades con imágenes específicas conocidas
  List<String> knownImages = [
    'Medications',
    'Sleep',
    'Heart',
    'Running',
    'Yoga',
    'Handwashing'
  ];

  List<Map<String, dynamic>> result =
      await DBHelper.getActivitiesForDate(widget.userId, selectedDate);

  setState(() {
    Map<String, List<String>> mutableActivityData =
        Map<String, List<String>>.from(activityData);

    activities.clear();

    // Recorremos los datos y verificamos que el estado de completitud se cargue correctamente
    activities = result.map((activityData) {
      String? activityTitle = activityData['title'] as String?;
      String? activityContent = activityData['data']?.toString();
      bool isCompleted = (activityData['isCompleted'] as int? ?? 0) == 1;

      print('Cargando actividad: $activityTitle, completada: $isCompleted');

      if (activityTitle != null && activityTitle.isNotEmpty) {
        if (activityContent != null && activityContent.isNotEmpty) {
          mutableActivityData[activityTitle] =
              List<String>.from(activityContent.split(';'));
        }

        // Verifica si la actividad tiene una imagen específica conocida
        bool hasSpecificImage = knownImages.contains(activityTitle);

        return Activity(
          activityTitle,
          'Health',
          hasSpecificImage ? 'assets/imagenes/$activityTitle.jpg' : 'assets/imagenes/actividad.jpg',
          isCompleted: isCompleted, // Añade el estado de completitud
        );
      } else {
        return Activity(
          'Unknown Activity',
          'Health',
          'assets/imagenes/default.jpg',
          isCompleted: false,
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
  String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  await DBHelper.saveActivityForDate(
      widget.userId, activity.title, data, formattedDate as DateTime);
  loadActivitiesForDate();
}

  Future<void> deleteActivity(Activity activity) async {
    await DBHelper.deleteActivityForUser(
        widget.userId, activity.title, selectedDate);
    loadActivitiesForDate();
  }

  void showAddActivityDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return NewActivityDialog(
        userId: widget.userId,
        selectedDate: selectedDate,
        onActivityAdded: (activity, data) {
          setState(() {
            saveActivity(activity, data);
          });
        },
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
  // Determina si la actividad está completada
 bool isCompleted = activity.isCompleted;

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
        // Lógica para mostrar los diálogos específicos según el título de la actividad
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
        } else {
          showNewActivityDialog(activity.title);
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
            color: isCompleted ? Colors.green : (isActive ? Colors.red : Colors.grey),
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
    List<String> sleepEntries = activityData['Sleep'] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return SleepDialog(
          sleepCompleted: sleepCompleted,
          sleepEntries: sleepEntries,
          onAddEntry: (entry) {
            setState(() {
              sleepEntries.add(entry);
              activityData['Sleep'] = sleepEntries;
              saveActivity(
                  Activity('Sleep', 'Health', 'assets/imagenes/Sleep.jpg'),
                  sleepEntries.join(';'));
            });
          },
          onComplete: () {
            setState(() {
              sleepCompleted = true;
            });
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Activity Completed'),
                  content:
                      Text('The sleep activity has been marked as completed.'),
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
        );
      },
    );
  }

  bool yogaCompleted =
      false; // Variable para controlar si la actividad está completada

  void showYogaDialog() {
    List<String> yogaEntries = activityData['Yoga'] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return YogaDialog(
          yogaCompleted: yogaCompleted,
          yogaEntries: yogaEntries,
          onAddEntry: (entry) {
            setState(() {
              yogaEntries.add(entry);
              activityData['Yoga'] = yogaEntries;
              saveActivity(
                Activity('Yoga', 'Health', 'assets/imagenes/Yoga.jpg'),
                yogaEntries.join(';'),
              );
            });
          },
          onComplete: () {
            setState(() {
              yogaCompleted = true;
            });
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Activity Completed'),
                  content:
                      Text('The yoga activity has been marked as completed.'),
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
        );
      },
    );
  }

  bool runningCompleted =
      false; // Variable para controlar si la actividad está completada

  void showRunningDialog() {
    List<String> runningEntries = activityData['Running'] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return RunningDialog(
          runningCompleted: runningCompleted,
          runningEntries: runningEntries,
          onAddEntry: (entry) {
            setState(() {
              runningEntries.add(entry);
              activityData['Running'] = runningEntries;
              saveActivity(
                Activity('Running', 'Health', 'assets/imagenes/Running.jpg'),
                runningEntries.join(';'),
              );
            });
          },
          onComplete: () {
            setState(() {
              runningCompleted = true;
            });
            Navigator.of(context).pop();
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
        );
      },
    );
  }

  bool handwashingCompleted =
      false;

void showHandwashingDialog() {
  List<String> handwashingEntries = activityData['Handwashing'] ?? [];
  showDialog(
    context: context,
    builder: (context) {
      return HandwashingDialog(
        handwashingCompleted: handwashingCompleted,
        handwashingEntries: handwashingEntries,
        onAddEntry: (entry) {
          setState(() {
            handwashingEntries.add(entry);
            activityData['Handwashing'] = handwashingEntries;
            saveActivity(
              Activity('Handwashing', 'Health', 'assets/imagenes/Handwashing.jpg'),
              handwashingEntries.join(';'),
            );
          });
        },
        onComplete: () async {
          setState(() {
            handwashingCompleted = true;
          });

          await DBHelper.updateActivityCompletionStatus(widget.userId, 'Handwashing', selectedDate, true);
          
          // Forzar recarga de actividades después de la actualización
          await loadActivitiesForDate();

          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Activity Completed'),
                content: Text('The handwashing activity has been marked as completed.'),
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
        onSaveCompletion: () {
          // Esta función adicional no es necesaria aquí, ya que se está llamando a `DBHelper.updateActivityCompletionStatus` directamente en `onComplete`.
        },
      );
    },
  );
}




  bool heartCompleted =
      false; // Variable para controlar si la actividad está completada

  void showHeartDialog() {
    List<String> heartEntries = activityData['Heart'] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return HeartDialog(
          heartCompleted: heartCompleted,
          heartEntries: heartEntries,
          onAddEntry: (entry) {
            setState(() {
              heartEntries.add(entry);
              activityData['Heart'] = heartEntries;
              saveActivity(
                Activity('Heart', 'Health', 'assets/imagenes/Heart.jpg'),
                heartEntries.join(';'),
              );
            });
          },
          onComplete: () {
            setState(() {
              heartCompleted = true;
            });
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Activity Completed'),
                  content:
                      Text('The heart activity has been marked as completed.'),
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
        );
      },
    );
  }

  bool medicationsCompleted =
      false;

  void showMedicationsDialog() {
    List<String> medicationsEntries = activityData['Medications'] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return MedicationsDialog(
          medicationsCompleted: medicationsCompleted,
          medicationsEntries: medicationsEntries,
          onAddEntry: (entry) {
            setState(() {
              medicationsEntries.add(entry);
              activityData['Medications'] = medicationsEntries;
              saveActivity(
                Activity(
                    'Medications', 'Health', 'assets/imagenes/Medications.jpg'),
                medicationsEntries.join(';'),
              );
            });
          },
          onComplete: () {
            setState(() {
              medicationsCompleted = true;
            });
            Navigator.of(context).pop();
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
        );
      },
    );
  }

bool customActivityCompleted = false; // Nueva variable para la actividad personalizada

void showNewActivityDialog(String title) {
  List<String> activityEntries = activityData[title]?.toList() ?? [];
  bool customActivityCompleted = activities.firstWhere((activity) => activity.title == title).isCompleted;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return NewActivityDetailDialog(
            activityCompleted: customActivityCompleted,
            activityEntries: activityEntries,
            onAddEntry: (entry) {
              if (!customActivityCompleted) {
                setState(() {
                  activityEntries.add(entry);
                  activityData[title] = activityEntries;
                  saveActivity(
                    Activity(title, 'Health', 'assets/imagenes/actividad.jpg'),
                    activityEntries.join(';'),
                  );
                });
              }
            },
            onDeleteEntry: (entry) {
              if (!customActivityCompleted) {
                setState(() {
                  activityEntries.remove(entry);
                  activityData[title] = activityEntries;
                  saveActivity(
                    Activity(title, 'Health', 'assets/imagenes/actividad.jpg'),
                    activityEntries.join(';'),
                  );
                });
              }
            },
            onComplete: () {
              setState(() {
                customActivityCompleted = true;
              });
              DBHelper.updateActivityCompletionStatus(widget.userId, title, selectedDate, true);
              // Recarga las actividades después de marcar como completada
              loadActivitiesForDate();
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Activity Completed'),
                    content: Text('The activity "$title" has been marked as completed.'),
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
            activityTitle: title,
          );
        },
      );
    },
  );
}








}

//cambios
class Activity {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isCompleted; // Nueva propiedad

  Activity(this.title, this.subtitle, this.imagePath, {this.isCompleted = false});
}

