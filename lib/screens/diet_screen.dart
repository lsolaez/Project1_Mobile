import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project1/Controllers/dietController.dart';
import 'package:project1/Controllers/hydration_controller.dart';
import 'package:project1/screens/activity_screen.dart';
import 'package:project1/screens/edit_profile_screen.dart';
import 'package:project1/screens/hydration_screen.dart';
import 'package:project1/screens/streak_screen.dart';
import 'package:project1/widgets/ConsumptionDialog.dart';
import 'package:project1/widgets/GoalSettingDialog.dart';
import 'recipes_.dart';

class DietScreen extends StatefulWidget {
  final String userName;
  final String nombre;
  final int userId; // Asegúrate de que este sea int y requerido

  const DietScreen(
      {super.key,
      required this.userName,
      required this.nombre,
      required this.userId});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  int _selectedIndex = 0;
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada por defecto: Hoy
  late DietController dietController;
  final ScrollController _scrollController =
      ScrollController(); // Controlador para el ListView
  final GlobalKey _profileKey =
      GlobalKey(); // Key para obtener la posición del avatar
  OverlayEntry? _overlayEntry;

  final List<String> _titles = [
    'Progress',
    'Healthy Recipes',
    'Activities',
  ];

  int daysInPast = 30; // Número de días en el pasado
  int daysInFuture = 30; // Número de días en el futuro

  @override
  void initState() {
    super.initState();
    dietController = Get.put(DietController(userId: widget.userId));
    dietController.loadProgressForDate(selectedDate);
    // Al iniciar, desplazar la lista para que el día actual quede centrado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedDate();
    });
  }

  // Método para desplazar el ListView hacia la fecha seleccionada
  void scrollToSelectedDate() {
    int selectedIndex = daysInPast; // El día de hoy es el índice 'daysInPast'
    double scrollPosition =
        (selectedIndex * 76.0) - MediaQuery.of(context).size.width / 2 + 30.0;
    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Método para mostrar el cuadro emergente debajo del avatar
  void _showProfilePopup() {
    final RenderBox renderBox =
        _profileKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior:
            HitTestBehavior.translucent, // Detecta toques fuera del cuadro
        onTap: _hideOverlay, // Ocultar si se toca fuera del cuadro
        child: Stack(
          children: [
            Positioned(
              top: offset.dy +
                  size.height +
                  10, // Posición justo debajo del avatar
              left: (screenWidth / 2), // Centrado con el avatar
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap:
                      () {}, // Prevenir que el cuadro se cierre al tocar dentro de él
                  child: Stack(
                    children: [
                      Container(
                        width: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  AssetImage('assets/imagenes/profile_pic.png'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                _hideOverlay();
                                // Navegar a la pantalla de Editar Perfil
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                        userId: widget.userId),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 173, 173),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -10,
                        left: 80,
                        child: CustomPaint(
                          painter: TrianglePainter(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Aquí se pasa el `selectedDate` a las pantallas correspondientes
  List<Widget> _screens() => [
        buildProgressScreen(),
        RecipesContent(selectedDate: selectedDate), // Pantalla de recetas
        ActivityScreen(
          userId: widget.userId,
          dateSelected: selectedDate,
        ), // con el userId
      ];

  // Método para mostrar los días de forma horizontal y scroleable
  Widget buildDateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        reverse: false,
        itemCount: daysInPast + daysInFuture + 1, // Total de días
        itemBuilder: (BuildContext context, int index) {
          DateTime date = DateTime.now().subtract(Duration(
              days: daysInPast - index)); // Mostrar días desde el pasado

          bool isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date; // Actualizar la fecha seleccionada
                dietController.loadProgressForDate(selectedDate);
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 60, // Ancho del cuadrado del día
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 255, 173, 173)
                    : Colors.white, // Cambiar color si está seleccionado
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color.fromARGB(255, 255, 173, 173)
                      : Colors.grey, // Bordes del contenedor
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(date), // Mostrar el día
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date), // Mostrar el mes abreviado
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildProgressScreen() {
    final HydrationController hydrationController =
        Get.put(HydrationController(userId: widget.userId));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hi ${widget.userName}! Here is your progress',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Barra de progreso fuera del AppBar
            Obx(() {
              double calorieProgress = dietController.totalCalories.value /
                  dietController.maxCalories.value;
              double proteinProgress = dietController.totalProteins.value /
                  dietController.maxProteins.value;
              double carbsProgress = dietController.totalCarbs.value /
                  dietController.maxCarbs.value;
              double fatProgress =
                  dietController.totalFat.value / dietController.maxFat.value;
              double waterProgress = hydrationController.totalWater.value /
                  hydrationController.dailyGoal;

              double averageProgress = (calorieProgress +
                      proteinProgress +
                      carbsProgress +
                      fatProgress +
                      waterProgress) /
                  5;

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: averageProgress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              );
            }),
            const SizedBox(height: 20),

            buildDateSelector(),

            const SizedBox(height: 20),

            // Disposición de las tarjetas de progreso en dos filas y dos columnas
            Table(
              children: [
                TableRow(
                  children: [
                    buildNutritionCard('Calories', dietController.totalCalories,
                        dietController.maxCalories, Colors.orange),
                    buildNutritionCard('Proteins', dietController.totalProteins,
                        dietController.maxProteins, Colors.blue),
                  ],
                ),
                const TableRow(
                  children: [
                    SizedBox(height: 20), // Espacio vertical entre filas
                    SizedBox(height: 20),
                  ],
                ),
                TableRow(
                  children: [
                    buildNutritionCard('Carbs', dietController.totalCarbs,
                        dietController.maxCarbs, Colors.green),
                    buildNutritionCard('Fats', dietController.totalFat,
                        dietController.maxFat, Colors.purple),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            HydrationCard(
                selectedDate: selectedDate,
                userId: widget.userId), // Pasar userId al HydrationCard
          ],
        ),
      ),
    );
  }

  void _showGoalSettingDialog(DateTime selectedDate) {
    DateTime today = DateTime.now();

    // Comparar solo el día, mes y año, ignorando la hora
    if (selectedDate.isBefore(DateTime(today.year, today.month, today.day))) {
      _showPastDateWarning(); // Mostrar alerta si el día es pasado
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return GoalSettingDialog(
            dietController: dietController,
            selectedDate: selectedDate,
          );
        },
      );
    }
  }

  void _showPastDateWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text('You cannot adjust goals for past days.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 173, 173),
                    Color.fromARGB(255, 160, 158, 140)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Exchange store'),
              onTap: () {
                Navigator.pop(context); // Cerrar el Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StreakScreen(
                            userName: widget.userName,
                            userId: widget.userId,
                          )), // Navegar a la página de destino
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Update Goals'),
              onTap: () {
                // Llamar a la función con validación
                _showGoalSettingDialog(selectedDate);
              },
            ),

            const Divider(), // Separador
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: () {
                Get.delete<DietController>();
                Navigator.pop(context); // Cerrar el Drawer
                Navigator.pushReplacementNamed(context, '/loginscreen');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 173, 173),
                Color.fromARGB(255, 255, 158, 140),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            key: _profileKey, // Asignar la key al avatar
            onTap: _showProfilePopup, // Mostrar el cuadro emergente al tocar
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/imagenes/profile_pic.png'),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFFFFFFFF),
        selectedItemColor: const Color.fromARGB(255, 255, 173, 173),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart, size: 30),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant, size: 30),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment, size: 30),
            label: 'Activities',
          ),
        ],
      ),
    );
  }

  // Método para manejar la navegación según el índice seleccionado
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildNutritionCard(
      String title, RxDouble currentValue, RxDouble maxValue, Color color) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ConsumptionDialog(
              dietController: dietController,
              selectedDate: selectedDate,
              title: title,
            );
          },
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Obx(() {
                  return SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: currentValue.value / maxValue.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Obx(() {
                return Text(
                  '$title:\n${currentValue.value.toStringAsFixed(1)}/${maxValue.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// Pintor personalizado para el triángulo que apunta hacia la imagen de perfil
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();

    path.moveTo(0, 0);
    path.lineTo(20, 0);
    path.lineTo(10, 10);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
