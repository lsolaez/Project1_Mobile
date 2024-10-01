import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project1/Controllers/hydration_controller.dart'; // Controlador de hidratación
import 'package:intl/intl.dart';

class HydrationScreen extends StatefulWidget {
  final DateTime selectedDate;

  const HydrationScreen({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  _HydrationScreenState createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  final HydrationController hydrationController =
      Get.put(HydrationController());

  static const double dailyGoal = 3000.0; // Meta diaria de agua (en ml)

  @override
  void initState() {
    super.initState();
    hydrationController.loadWaterForDate(
        widget.selectedDate); // Cargar los datos para la fecha seleccionada
  }

  @override
  void didUpdateWidget(HydrationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      // Cargar los datos de agua para la nueva fecha seleccionada
      hydrationController.loadWaterForDate(widget.selectedDate);
    }
  }

  // Método para calcular cuántos vasos mostrar
  List<Widget> buildWaterGlasses() {
    int totalGlasses =
        (dailyGoal / hydrationController.glassSize.value).ceil(); // Número total de vasos
    int filledGlasses = (hydrationController.totalWater.value /
            hydrationController.glassSize.value)
        .floor(); // Número de vasos llenos

    return List.generate(totalGlasses, (index) {
      return Icon(
        Icons.local_drink,
        size: 40,
        color: index < filledGlasses
            ? Colors.blue
            : Colors.grey[300], // Color para vaso lleno o vacío
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Water intake for ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Obx(() {
              double progress =
                  hydrationController.totalWater.value / dailyGoal;
              return buildWaterCircle(
                  progress.clamp(0.0, 1.0)); // Mostrar progreso en círculo
            }),
            const SizedBox(height: 30),
            // Mostrar los vasos de agua con GridView
            Obx(() {
              return GridView.count(
                crossAxisCount: 5, // Máximo 5 vasos por fila
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap:
                    true, // Esto permite que el GridView se ajuste a su contenido
                physics:
                    const NeverScrollableScrollPhysics(), // Evitar el scroll dentro del grid
                children: buildWaterGlasses(),
              );
            }),
            const SizedBox(height: 30),
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
            ElevatedButton(
              onPressed: () {
                hydrationController.addWater(
                    hydrationController.glassSize.value, widget.selectedDate);
              },
              child: const Text("Add glass of water"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWaterCircle(double progress) {
    return CustomPaint(
      size: const Size(200, 200), // Tamaño del círculo
      painter: WaterCirclePainter(
          progress), // Usar el WaterCirclePainter para el círculo
    );
  }
}

// Pintor para el círculo de agua
class WaterCirclePainter extends CustomPainter {
  final double progress;

  WaterCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint waterPaint = Paint()..color = Colors.blueAccent;

    Paint backgroundPaint = Paint()..color = Colors.blue[100]!;

    // Dibujar el fondo del círculo
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      backgroundPaint,
    );

    // Dibujar el progreso del agua dentro del círculo
    double fillHeight =
        size.height * (1 - progress); // Altura del relleno según el progreso
    Rect waterRect = Rect.fromLTRB(0, fillHeight, size.width, size.height);
    canvas.clipRect(waterRect); // Recortar el área donde se llenará el agua

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      waterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
