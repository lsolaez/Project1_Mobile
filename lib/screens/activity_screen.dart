import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> activities = [];
  List<Activity> deletedActivities = [
    Activity('Medications', 'Health', 'assets/imagenes/A1.jpg'),
    Activity('Sleep', 'Health', 'assets/imagenes/A2.jpg'),
    Activity('Heart', 'Health', 'assets/imagenes/A3.jpg'),
    Activity('Running', 'Sports', 'assets/imagenes/A4.jpg'),
    Activity('Yoga', 'Sports', 'assets/imagenes/A5.jpg'),
    Activity('Handwashing', 'Health', 'assets/imagenes/A6.jpg'),
  ];

  Map<String, List<String>> sleepData = {};
  Map<String, List<String>> yogaData = {};
  Map<String, List<String>> runningData = {};
  Map<String, List<String>> handwashingData = {};
  Map<String, List<String>> heartData = {}; 
  Map<String, List<String>> medicationsData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9A8B),
        elevation: 0,
        title: const Text(
          'Activities',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
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
                fontWeight: day.day == today.day
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
      onDismissed: (direction) {
        setState(() {
          if (isActive) {
            activities.remove(activity);
            deletedActivities.add(activity);
          } else {
            deletedActivities.remove(activity);
            activities.add(activity);
          }
        });
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
void showMedicationsDialog() {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  String selectedUnit = 'mg'; 
  String customUnit = ''; 
  List<String> medicationsEntries = medicationsData['Medications'] ?? [];

  showDialog(
    context: context,
    builder: (context) {
      String currentSelectedUnit = selectedUnit; 

      return StatefulBuilder( 
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Add Medications Data'),
            content: Column(
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
                  value: currentSelectedUnit,
                  items: ['mg', 'g', 'ml', 'mm', 'others']
                      .map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      currentSelectedUnit = newValue!;
                      if (currentSelectedUnit != 'others') {
                        customUnit = '';
                      }
                    });
                  },
                ),
                if (currentSelectedUnit == 'others')
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
                      const Text('Medications Entries:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                  medicationsData['Medications'] = medicationsEntries;
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
            actions: [
              TextButton(
                onPressed: () {
                  final name = nameController.text;
                  final quantity = quantityController.text;
                  if (name.isNotEmpty || quantity.isNotEmpty) {
                    setState(() {
                      String unitToUse = currentSelectedUnit == 'others' ? customUnit : currentSelectedUnit;
                      String entry = '$name: ${quantity.isNotEmpty ? quantity + (unitToUse.isNotEmpty ? unitToUse : '') : ""}';
                      if (medicationsData['Medications'] == null) {
                        medicationsData['Medications'] = [];
                      }
                      medicationsData['Medications']!.add(entry);
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
            ],
          );
        },
      );
    },
  );
}


  void showSleepDialog() {
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    List<String> sleepEntries = sleepData['Sleep'] ?? [];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Sleep Data'),
          content: Column(
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
                    const Text('Sleep Entries:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                sleepData['Sleep'] = sleepEntries;
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
          actions: [
            TextButton(
              onPressed: () {
                final hours = hoursController.text;
                final minutes = minutesController.text;
                if (hours.isNotEmpty || minutes.isNotEmpty) {
                  setState(() {
                    String entry =
                        '${hours.isNotEmpty ? hours + "h" : ""} ${minutes.isNotEmpty ? minutes + "m" : ""}';
                    if (sleepData['Sleep'] == null) {
                      sleepData['Sleep'] = [];
                    }
                    sleepData['Sleep']!.add(entry);
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
          ],
        );
      },
    );
  }

  void showYogaDialog() {
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();
  String selectedTimeOfDay = 'Morning';
  List<String> yogaEntries = yogaData['Yoga'] ?? [];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add Yoga Data'),
            content: Column(
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
                                  yogaData['Yoga'] = yogaEntries;
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
            actions: [
              TextButton(
                onPressed: () {
                  final hours = hoursController.text;
                  final minutes = minutesController.text;
                  if (hours.isNotEmpty || minutes.isNotEmpty) {
                    setState(() {
                      String entry =
                          '${selectedTimeOfDay}: ${hours.isNotEmpty ? hours + "h" : ""} ${minutes.isNotEmpty ? minutes + "m" : ""}';
                      if (yogaData['Yoga'] == null) {
                        yogaData['Yoga'] = [];
                      }
                      yogaData['Yoga']!.add(entry);
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
            ],
          );
        },
      );
    },
  );
}

 void showRunningDialog() {
  final hoursController = TextEditingController();
  final distanceController = TextEditingController();
  List<String> runningEntries = runningData['Running'] ?? [];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Running Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Hours'),
            ),
            TextField(
              controller: distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Distance (km)'),
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
                  const Text('Running Entries:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              runningData['Running'] = runningEntries;
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
        actions: [
          TextButton(
            onPressed: () {
              final hours = hoursController.text;
              final distance = distanceController.text;

              if (hours.isNotEmpty || distance.isNotEmpty) {
                setState(() {
                  String entry = '';
                  if (hours.isNotEmpty) {
                    entry += '${hours}h';
                  }
                  if (distance.isNotEmpty) {
                    entry += ' ${distance}km';
                  }
                  if (runningData['Running'] == null) {
                    runningData['Running'] = [];
                  }
                  runningData['Running']!.add(entry.trim());
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
        ],
      );
    },
  );
}

  void showHandwashingDialog() {
    final secondsController = TextEditingController();
    List<String> handwashingEntries = handwashingData['Handwashing'] ?? [];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Handwashing Data'),
          content: Column(
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
                    const Text('Handwashing Entries:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                handwashingData['Handwashing'] = handwashingEntries;
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
          actions: [
            TextButton(
              onPressed: () {
                final seconds = secondsController.text;
                if (seconds.isNotEmpty) {
                  setState(() {
                    String entry = '${seconds}s';
                    if (handwashingData['Handwashing'] == null) {
                      handwashingData['Handwashing'] = [];
                    }
                    handwashingData['Handwashing']!.add(entry);
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
          ],
        );
      },
    );
  }

  void showHeartDialog() {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final timeController = TextEditingController();
    List<String> heartEntries = heartData['Heart'] ?? [];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Heart Data'),
          content: Column(
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
                    const Text('Heart Entries:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                heartData['Heart'] = heartEntries;
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
          actions: [
            TextButton(
              onPressed: () {
                final systolic = systolicController.text;
                final diastolic = diastolicController.text;
                final time = timeController.text;
                if (systolic.isNotEmpty || diastolic.isNotEmpty || time.isNotEmpty) {
                  setState(() {
                    String entry =
                        'S: $systolic mmHg, D:$diastolic mmHg,$time';
                    if (heartData['Heart'] == null) {
                      heartData['Heart'] = [];
                    }
                    heartData['Heart']!.add(entry);
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