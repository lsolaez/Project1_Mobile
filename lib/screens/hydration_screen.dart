import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project1/Controllers/hydration_controller.dart'; // Controlador de hidratación

class HydrationCard extends StatefulWidget {
  final DateTime selectedDate;
  final int userId; // Asegurarse de que el userId esté aquí

  const HydrationCard({Key? key, required this.selectedDate, required this.userId}) : super(key: key);

  @override
  _HydrationCardState createState() => _HydrationCardState();
}

class _HydrationCardState extends State<HydrationCard> {
  late HydrationController hydrationController;

  static const double dailyGoal = 3000.0; // Meta diaria de agua (en ml)

  @override
  void initState() {
    super.initState();
    hydrationController = Get.put(HydrationController(userId: widget.userId)); // Pasar el userId al controlador
    hydrationController.loadWaterForDate(widget.userId, widget.selectedDate); // Cargar los datos para la fecha seleccionada
  }

  @override
  void didUpdateWidget(HydrationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      // Cargar los datos de agua para la nueva fecha seleccionada
      hydrationController.loadWaterForDate(widget.userId, widget.selectedDate);
    }
  }

  // Método para calcular cuántos vasos mostrar
  List<Widget> buildWaterGlasses() {
    int totalGlasses = (dailyGoal / hydrationController.glassSize.value).ceil(); // Número total de vasos
    int filledGlasses = (hydrationController.totalWater.value / hydrationController.glassSize.value).floor(); // Número de vasos llenos

    return List.generate(totalGlasses, (index) {
      return Icon(
        Icons.local_drink,
        size: 40,
        color: index < filledGlasses ? Colors.blue : Colors.grey[300], // Color para vaso lleno o vacío
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              "Water control",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Obx(() {
              return GridView.count(
                crossAxisCount: 5, // Máximo 5 vasos por fila
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true, // Ajustar tamaño según contenido
                physics: const NeverScrollableScrollPhysics(), // Evitar scroll dentro del grid
                children: buildWaterGlasses(),
              );
            }),
            const SizedBox(height: 20),
            Obx(() {
              return Text(
                "Glass size (ml): ${hydrationController.glassSize.value.toInt()}",
                style: const TextStyle(fontSize: 16),
              );
            }),
            Obx(() {
              return Slider(
                value: hydrationController.glassSize.value,
                min: 100,
                max: 500,
                divisions: 8,
                label: hydrationController.glassSize.value.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    hydrationController.glassSize.value = value;
                  });
                },
              );
            }),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                hydrationController.addWater(hydrationController.glassSize.value, widget.userId, widget.selectedDate); // Añadir el userId
              },
              child: const Text("Add glass of water"),
            ),
          ],
        ),
      ),
    );
  }
}
