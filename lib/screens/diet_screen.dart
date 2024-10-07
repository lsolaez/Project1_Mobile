import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project1/Controllers/dietController.dart';
import 'package:project1/Controllers/hydration_controller.dart';
import 'package:project1/screens/hydration_screen.dart';
import 'package:project1/widgets/ConsumptionDialog.dart';
import 'package:project1/widgets/GoalSettingDialog.dart';
import 'recipes_.dart';

class DietScreen extends StatefulWidget {
  final String userName;

  const DietScreen({super.key, required this.userName, required String nombre});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  int _selectedIndex = 0;
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada por defecto: Hoy
  final DietController dietController = Get.put(DietController());
  final ScrollController _scrollController =
      ScrollController(); // Controlador para el ListView

  final List<String> _titles = [
    'Progress',
    'Healthy Recipes',
    'Settings',
  ];

  int daysInPast = 30; // Número de días en el pasado
  int daysInFuture = 30; // Número de días en el futuro

  @override
  void initState() {
    super.initState();
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

  // Aquí se pasa el `selectedDate` a las pantallas correspondientes
  List<Widget> _screens() => [
        buildProgressScreen(),
        RecipesContent(selectedDate: selectedDate), // Pantalla de recetas
        const Text('Settings Screen'), // Pantalla de ajustes
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

  // Pantalla de progreso
  Widget buildProgressScreen() {
    final HydrationController hydrationController =
        Get.put(HydrationController());

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
            HydrationCard(selectedDate: selectedDate),
          ],
        ),
      ),
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
              leading: const Icon(Icons.assignment),
              title: const Text('Activities'),
              onTap: () {
                Navigator.pop(context); // Cerrar el Drawer
                // Aquí puedes redirigir a la pantalla de "Activities"
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Update Goals'),
              onTap: () {
                Navigator.pop(context); // Cerrar el Drawer
                // Abrir el diálogo de actualización de metas
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return GoalSettingDialog(
                      dietController: dietController,
                      selectedDate: selectedDate,
                    );
                  },
                );
              },
            ),
            const Divider(), // Separador
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pop(context); // Cerrar el Drawer
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/imagenes/Macuernas.png',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 8),
            Text(
              _titles[_selectedIndex],
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/imagenes/Macuernas.png',
              height: 40,
              width: 40,
            ),
          ],
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
            icon: Icon(Icons.settings, size: 30),
            label: 'Settings',
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
