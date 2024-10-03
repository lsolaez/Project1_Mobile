import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project1/Controllers/dietController.dart';
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
    'Human Metrics',
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
    // El índice del día seleccionado (hoy está en el centro del rango de días)
    int selectedIndex = daysInPast; // El día de hoy es el índice 'daysInPast'

    // Calcular la posición para desplazar el ScrollController
    double scrollPosition =
        (selectedIndex * 76.0) - MediaQuery.of(context).size.width / 2 + 30.0;

    // Desplazar la lista de días
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
        const Text('Human Metrics Screen'), // Pantalla de métricas
        const Text('Settings Screen'), // Pantalla de ajustes
      ];

  // Método para mostrar los días de forma horizontal y scroleable
  Widget buildDateSelector() {
    return SizedBox(
      height: 80, // Altura de los cuadrados con los días
      child: ListView.builder(
        controller:
            _scrollController, // Asignar el controlador de desplazamiento
        scrollDirection: Axis.horizontal, // Desplazamiento horizontal
        reverse: false, // Mostrar los días de izquierda a derecha
        itemCount: daysInPast +
            daysInFuture +
            1, // Total de días (pasados + futuros + hoy)
        itemBuilder: (BuildContext context, int index) {
          DateTime date = DateTime.now().subtract(Duration(
              days: daysInPast -
                  index)); // Mostrar días desde el pasado al futuro

          bool isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date; // Actualizar la fecha seleccionada
                dietController.loadProgressForDate(
                    selectedDate); // Cargar datos para la nueva fecha
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
                      color: isSelected
                          ? Colors.white
                          : Colors
                              .black, // Cambiar el color del texto si está seleccionado
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date), // Mostrar el mes abreviado
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : Colors
                              .grey, // Cambiar el color del texto si está seleccionado
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

            // Disposición de las tarjetas de progreso en dos filas y dos columnas
            Table(
              children: [
                TableRow(
                  children: [
                    // Calorías (Izquierda Arriba)
                    buildNutritionCard('Calories', dietController.totalCalories,
                        dietController.maxCalories, Colors.orange),
                    // Proteínas (Derecha Arriba)
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
                    // Carbohidratos (Izquierda Abajo)
                    buildNutritionCard('Carbs', dietController.totalCarbs,
                        dietController.maxCarbs, Colors.green),

                    buildNutritionCard('Fats', dietController.totalFat,
                        dietController.maxFat, Colors.purple),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20), // Espacio antes de colocar el botón
            HydrationCard(selectedDate: selectedDate),
            const SizedBox(height: 20),
            // Botón para establecer metas debajo de la carta del agua
            buildGoalsButton(),
          ],
        ),
      ),
    );
  }

  // Botón para establecer metas
  Widget buildGoalsButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          // Mostrar el diálogo de actualización de metas
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return GoalSettingDialog(
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
          'Update Goals',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        selectedItemColor: const Color.fromARGB(255, 255, 173, 173),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            icon: Icon(Icons.assignment, size: 30), // Icono de humano
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget buildNutritionCard(
      String title, RxDouble currentValue, RxDouble maxValue, Color color) {
    return GestureDetector(
      onTap: () {
        // Detectar si es un gráfico específico y abrir el diálogo correspondiente
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ConsumptionDialog(
              dietController: dietController,
              selectedDate: selectedDate,
              title:
                  title, // Pasar el título para identificar qué nutriente se está modificando
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
