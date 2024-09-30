import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project1/Controllers/dietCrontroller.dart';
import 'package:project1/main.dart';
import 'package:project1/screens/diet_screen.dart';
import 'package:project1/screens/recipes_.dart';

void main() {
  testWidgets('Get Started button navigates to Home screen',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Get Started button is present.
    expect(find.text('Get Started'), findsOneWidget);

    // Tap the Get Started button and trigger a frame.
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle(); // Esperar hasta que todas las animaciones se completen

    expect(find.text('Ingrese su nombre:'), findsOneWidget);
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();
    // Verify that we have navigated to the Home screen.
    expect(find.text('Healthy Recipes'),
        findsOneWidget); // Ajusta este texto a lo que tengas en la pantalla Home
  });

  testWidgets('Update Consumption button opens dialog',
      (WidgetTester tester) async {
    // Inicializar el controlador
    Get.put(DietController());

    // Construir el widget de la pantalla DietScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(nombre: '',),
      ),
    );

    // Verificar que la pantalla se renderiza correctamente con cualquier valor de proteínas
    expect(find.textContaining('Proteins:'), findsOneWidget);

    // Simular un tap en el botón "Update Consumption"
    await tester.tap(find.text('Update Consumption').first);
    await tester
        .pumpAndSettle(); // Esperar a que el modal se muestre completamente

    // Verificar que el modal se muestra
    expect(find.text('Enter your consumption'), findsOneWidget);
  });

  test('DietController should update values correctly', () {
    final controller = DietController();

    // Inicialmente, los valores deberían ser 0
    expect(controller.totalCalories.value, 0.0);
    expect(controller.totalProteins.value, 0.0);
    expect(controller.totalCarbs.value, 0.0);

    // Añadir consumo
    controller.addToChart(500.0, 30.0, 100.0);

    // Verificar si los valores se actualizaron correctamente
    expect(controller.totalCalories.value, 500.0);
    expect(controller.totalProteins.value, 30.0);
    expect(controller.totalCarbs.value, 100.0);
  });

testWidgets('Charts update with consumption changes', (WidgetTester tester) async {
    // Inicializar el controlador de DietController
    final DietController dietController = Get.put(DietController());

    // Construir el widget de la pantalla DietScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(nombre: '',),
      ),
    );

    // Esperar que la interfaz se actualice
    await tester.pumpAndSettle();

    // Verificar que la pantalla se renderiza correctamente con proteínas, calorías y carbohidratos
    expect(find.textContaining('Proteins:'), findsOneWidget);
    expect(find.textContaining('Calories:'), findsOneWidget);
    expect(find.textContaining('Carbs:'), findsOneWidget);

    // Simular añadir valores de consumo
    dietController.addToChart(300, 40, 60); // Añadir calorías, proteínas, carbohidratos
    await tester.pumpAndSettle(); // Esperar que la UI se actualice con los nuevos valores

    // Verificar que las gráficas se actualicen con los nuevos valores
    expect(find.textContaining('Proteins: 40.0 / 100'), findsOneWidget);
    expect(find.textContaining('Calories: 300.0 / 2000'), findsOneWidget);
    expect(find.textContaining('Carbs: 60.0 / 300'), findsOneWidget);
  });

  testWidgets('BottomNavigationBar navigates between screens',
      (WidgetTester tester) async {
    // Inicializar el controlador
    Get.put(DietController());

    // Construir la pantalla HomeScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Verificar que estamos en la pantalla Home
    expect(find.text('Healthy Recipes'), findsOneWidget);

    // Navegar a la pantalla Diet
    await tester.tap(find.text('Diet'));
    await tester.pumpAndSettle(); // Esperar la transición

    // Verificar que estamos en la pantalla Diet
    expect(find.text('Daily Nutrition Breakdown'), findsOneWidget);

    // Navegar a la pantalla Settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verificar que estamos en la pantalla Settings
    expect(find.text('Settings Screen'), findsOneWidget);
  });
}
