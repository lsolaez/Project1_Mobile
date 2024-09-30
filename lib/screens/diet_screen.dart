import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project1/Controllers/dietController.dart';
import 'package:project1/widgets/ConsumptionDialog.dart';
import 'recipes_.dart';

class DietScreen extends StatefulWidget {
  final String userName;

  const DietScreen({super.key, required this.userName, required String nombre});

  @override
  // ignore: library_private_types_in_public_api
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  int _selectedIndex = 0;
  DateTime selectedDate = DateTime.now(); // Fecha seleccionada por defecto: Hoy
  final DietController dietController = Get.put(DietController());

  final List<String> _titles = [
    'Progress',
    'Healthy Recipes',
    'Human Metrics',
    'Hydration',
    'Settings',
  ];

  // Aquí se pasa el `selectedDate` a las pantallas correspondientes
  List<Widget> _screens() => [
        // Pantalla de progreso (reemplaza aquí por el widget real)
        buildProgressScreen(),
        RecipesContent(selectedDate: selectedDate), // Pantalla de recetas
        const Text('Human Metrics Screen'), // Pantalla de métricas
        const Text('Hydration Screen'), // Pantalla de hidratación
        const Text('Settings Screen'), // Pantalla de ajustes
      ];

  // Método para mostrar los días de forma horizontal y scroleable

Widget buildDateSelector() {
  return SizedBox(
    height: 80, // Altura de los cuadrados con los días
    child: ListView.builder(
      scrollDirection: Axis.horizontal, // Desplazamiento horizontal
      reverse: true, // Mostrar los días de derecha a izquierda
      itemCount: 30, // Mostrar 30 días como ejemplo
      itemBuilder: (BuildContext context, int index) {
        DateTime date = DateTime.now().subtract(Duration(days: index)); // Restar días desde hoy
        
        // Comparar solo el año, mes y día
        bool isSelected = date.year == selectedDate.year &&
                          date.month == selectedDate.month &&
                          date.day == selectedDate.day;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date; // Actualizar la fecha seleccionada
              dietController.loadProgressForDate(selectedDate); // Cargar datos para la nueva fecha
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 60, // Ancho del cuadrado del día
            decoration: BoxDecoration(
              color: isSelected ? const Color.fromARGB(255, 255, 173, 173) : Colors.white, // Cambiar color si está seleccionado
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color.fromARGB(255, 255, 173, 173) : Colors.grey, // Bordes del contenedor
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
                    color: isSelected ? Colors.white : Colors.black, // Cambiar el color del texto si está seleccionado
                  ),
                ),
                Text(
                  DateFormat('MMM').format(date), // Mostrar el mes abreviado
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.grey, // Cambiar el color del texto si está seleccionado
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
            buildDateSelector(), // Aquí agregamos la selección visual de fechas
            const SizedBox(height: 20),
            buildNutritionCard('Calories', dietController.totalCalories, dietController.maxCalories, Colors.orange),
            const SizedBox(height: 20),
            buildNutritionCard('Proteins', dietController.totalProteins, dietController.maxProteins, Colors.blue),
            const SizedBox(height: 20),
            buildNutritionCard('Carbs', dietController.totalCarbs, dietController.maxCarbs, Colors.green),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Mostrar el diálogo de actualización de consumo en lugar de pasar valores predeterminados
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConsumptionDialog(
                        dietController: dietController,
                        selectedDate: selectedDate, // Pasar la fecha seleccionada
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: const Color.fromARGB(255, 255, 173, 173),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Update Consumption',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]), // Cambiar el título dinámicamente
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFA7268), // Color degradado superior
                Color(0xFFF3ECEF), // Color degradado inferior
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
        backgroundColor: const Color(0xFF1D1B20),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart, size: 30), // Gráfico circular
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant, size: 30), // Icono de recetas
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30), // Icono de humano
            label: 'Body',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop, size: 30), // Icono de agua
            label: 'Hydration',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Crear la tarjeta de nutrición
  Widget buildNutritionCard(String title, RxDouble currentValue, double maxValue, Color color) {
    return Card(
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
                    value: currentValue.value / maxValue,
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
                '$title: ${currentValue.value.toStringAsFixed(1)} / $maxValue',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              );
            }),
          ],
        ),
      ),
    );
  }
}
