import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project1/Controllers/dietCrontroller.dart';
import 'package:project1/main.dart';
import 'package:project1/screens/diet_screen.dart';
import 'package:project1/screens/recipes_.dart';

void main() {
  // Inicializar las pruebas de integración
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Navegación lenta con Get Started y Home', (WidgetTester tester) async {
    // Cargar la aplicación
    await tester.pumpWidget(const MyApp());

    // Pausa para hacer la prueba más lenta (1 segundo en este caso)
    await tester.pump(const Duration(seconds: 1));

    // Verificar que el botón "Get Started" esté presente
    expect(find.text('Get Started'), findsOneWidget);

    // Tap en el botón "Get Started" y espera la transición
    await tester.tap(find.text('Get Started'));

    // Esperar 2 segundos antes de continuar (para ralentizar la prueba)
    await tester.pump(const Duration(seconds: 2));

    // Asegurarse de que la animación y la transición se completen
    await tester.pumpAndSettle();

    // Verificar que hemos navegado a la pantalla Home
    expect(find.text('Healthy Recipes'), findsOneWidget);

    // Pausa adicional para hacer la prueba aún más lenta (opcional)
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Update Consumption button abre el dialogo', (WidgetTester tester) async {
    // Inicializar el controlador
    Get.put(DietController());

    // Construir la pantalla DietScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(nombre: '', userName: '',),
      ),
    );

    // Esperar para ralentizar la prueba
    await tester.pump(const Duration(seconds: 2));

    // Verificar que la pantalla se renderiza correctamente con proteínas
    expect(find.textContaining('Proteins:'), findsOneWidget);

    // Simular un tap en el botón "Update Consumption"
    await tester.tap(find.text('Update Consumption').first);

    // Pausa antes de que aparezca el modal
    await tester.pump(const Duration(seconds: 1));

    // Verificar que el modal se muestra
    expect(find.text('Enter your consumption'), findsOneWidget);

    // Pausa adicional
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Las gráficas se actualizan con los cambios de consumo', (WidgetTester tester) async {
    // Inicializar el controlador de DietController
    final DietController dietController = Get.put(DietController());

    // Construir el widget de la pantalla DietScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(nombre: '', userName: '',),
      ),
    );

    // Esperar para ralentizar la prueba
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verificar que la pantalla se renderiza correctamente
    expect(find.textContaining('Proteins:'), findsOneWidget);
    expect(find.textContaining('Calories:'), findsOneWidget);
    expect(find.textContaining('Carbs:'), findsOneWidget);

    // Simular añadir valores de consumo
    dietController.addToChart(300, 40, 60); // Añadir calorías, proteínas, carbohidratos
    await tester.pumpAndSettle(const Duration(seconds: 2)); // Pausa antes de actualizar UI

    // Verificar que las gráficas se actualicen con los nuevos valores
    expect(find.textContaining('Proteins: 40.0 / 100'), findsOneWidget);
    expect(find.textContaining('Calories: 300.0 / 2000'), findsOneWidget);
    expect(find.textContaining('Carbs: 60.0 / 300'), findsOneWidget);

    // Pausa adicional
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('BottomNavigationBar navega entre pantallas', (WidgetTester tester) async {
    // Inicializar el controlador
    Get.put(DietController());

    // Construir la pantalla HomeScreen
    await tester.pumpWidget(
      MaterialApp(
        home: RecipesContent(),
      ),
    );

    // Pausa antes de la navegación inicial
    await tester.pump(const Duration(seconds: 2));

    // Verificar que estamos en la pantalla Home
    expect(find.text('Healthy Recipes'), findsOneWidget);

    // Navegar a la pantalla Diet
    await tester.tap(find.text('Diet'));
    await tester.pumpAndSettle(const Duration(seconds: 2)); // Pausa antes de la transición

    // Verificar que estamos en la pantalla Diet
    expect(find.text('Daily Nutrition Breakdown'), findsOneWidget);

    // Navegar a la pantalla Settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle(const Duration(seconds: 2)); // Pausa antes de la transición

    // Verificar que estamos en la pantalla Settings
    expect(find.text('Settings Screen'), findsOneWidget);

    // Pausa adicional
    await tester.pump(const Duration(seconds: 1));
  });
}
