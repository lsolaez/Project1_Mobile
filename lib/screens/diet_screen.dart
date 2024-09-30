import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:project1/Controllers/dietCrontroller.dart';
import 'package:project1/screens/recipes_.dart';

class DietScreen extends StatefulWidget {
  final String userName;

  const DietScreen({super.key, required this.userName, required String nombre});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  int _selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  final DietController dietController = Get.put(DietController());

  final List<String> _titles = [
    'Progress',
    'Healthy Recipes',
    'Human Metrics',
    'Hydration',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    dietController.loadProgressForDate(selectedDate);
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      dietController.loadProgressForDate(picked);
    }
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
      body: _selectedIndex == 0
          ? _buildDietContent() // Mostrar el contenido de Diet
          : _selectedIndex == 1
              ? RecipesContent(selectedDate: selectedDate) // Pantalla de recetas
              : const Text('Other Screen'), // Otras pantallas placeholder
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
            icon: Icon(Icons.pie_chart, size: 30),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank, size: 30),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Metrics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop, size: 30),
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

  Widget _buildDietContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hi ${widget.userName}, here is your progress for ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: const Color.fromARGB(255, 255, 173, 173),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Select Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            buildNutritionCard(
              'Proteins',
              dietController.totalProteins,
              dietController.maxProteins,
              Colors.blue,
            ),
            const SizedBox(height: 20),
            buildNutritionCard(
              'Calories',
              dietController.totalCalories,
              dietController.maxCalories,
              Colors.orange,
            ),
            const SizedBox(height: 20),
            buildNutritionCard(
              'Carbs',
              dietController.totalCarbs,
              dietController.maxCarbs,
              Colors.green,
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  dietController.addToChart(200, 50, 80, selectedDate); // Guardar según la fecha seleccionada
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: const Color.fromARGB(255, 255, 173, 173),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Update Consumption',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            Obx(() {
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
