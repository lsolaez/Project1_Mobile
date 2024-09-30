import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Necesario para formatear la fecha
import 'package:project1/Controllers/dietController.dart';
import 'package:project1/widgets/ConsumptionDialog.dart';
import 'recipes_.dart'; // Para la navegación a la pantalla de recetas

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

  final List<String> _titles = [
    'Progress',
    'Healthy Recipes',
    'Human Metrics',
    'Hydration',
    'Settings',
  ];

  // Método para manejar la selección de la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020), // Limitar la fecha mínima
      lastDate: DateTime.now(), // Limitar a la fecha actual
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Actualizar la fecha seleccionada
        dietController.loadProgressForDate(selectedDate); // Cargar los datos de esa fecha
      });
    }
  }

  // Método para manejar el cambio de pantallas en el BottomNavigationBar
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
      body: _screens(), // Aquí se llamará el método que muestra la pantalla correcta
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
            icon: Icon(FontAwesomeIcons.chartPie, size: 30), // Gráfico circular
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.utensils, size: 30), // Cambiar a utensilios
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.person), // Ícono de humano
            label: 'Body', // Etiqueta
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.droplet), // Ícono de gota de agua
            label: 'Hydration', // Etiqueta
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Método para decidir qué pantalla mostrar
  Widget _screens() {
    switch (_selectedIndex) {
      case 0:
        return buildDietContent(); // Pantalla de progreso
      case 1:
        return RecipesContent(selectedDate: selectedDate); // Pantalla de recetas con la fecha seleccionada
      case 2:
        return const Center(child: Text('Human Metrics Screen')); // Pantalla de métricas corporales
      case 3:
        return const Center(child: Text('Hydration Screen')); // Pantalla de hidratación
      case 4:
        return const Center(child: Text('Settings Screen')); // Pantalla de configuración
      default:
        return buildDietContent(); // Por defecto, mostrar el progreso
    }
  }

  // El contenido principal de la pantalla Diet
  Widget buildDietContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hi ${widget.userName}! Here is your progress for ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context), // Seleccionar la fecha
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: const Color.fromARGB(255, 255, 173, 173),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
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

  // Crear una tarjeta para mostrar el progreso nutricional
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
