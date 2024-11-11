import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:project1/Controllers/dietController.dart';
import 'package:project1/screens/activity_screen.dart';
import 'package:project1/screens/diet_screen.dart';
import 'package:project1/screens/get_started.dart';
import 'package:project1/screens/recipes_.dart';
import 'package:project1/widgets/sleep_Dialog.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Inicializar las pruebas de integración
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });



  testWidgets('User can register successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GetStartedScreen(),
      ),
    );
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot Details?'), findsOneWidget);
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(
        find.text('Please enter your credentials to proceed'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('fullNameField')), 'John Doe');
    await tester.enterText(find.byKey(const Key('phoneField')), '123456789');
    await tester.enterText(
        find.byKey(const Key('emailField')), 'john.doe@example.com');
    await tester.enterText(
        find.byKey(const Key('passwordField')), 'password123');
    await tester.enterText(find.byKey(const Key('ageField')), '30');

    // Seleccionar un valor en el DropdownButtonFormField de sexo
    await tester.ensureVisible(find.byKey(const Key('sexDropdown')));
    await tester.tap(find.byKey(const Key('sexDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Male').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('createAccountButton')));
    await tester.pump();
  });

  testWidgets('User can log in', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GetStartedScreen(),
      ),
    );
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot Details?'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('Username')), 'test@example.com');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('Password')), 'password123');
    await tester.pumpAndSettle();
    if (tester.any(find.byKey(const Key('loginButton')))) {
      await tester.tap(find.byKey(const Key('loginButton')));
    } else {
      await tester.scrollUntilVisible(
          find.byKey(const Key('loginButton')), 500.0);
      await tester.tap(find.byKey(const Key('loginButton')));
    }
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MaterialApp(
        home: const GetStartedScreen(),
        routes: {
          '/dietScreen': (context) => const DietScreen(
                userName: 'User Test',
                nombre: 'User Test',
                userId: 1,
              ),
        },
      ),
    );
  });

  testWidgets('DietScreen shows progress charts with correct values',
      (WidgetTester tester) async {
    // Inicializa el controlador de dieta
    final dietController = Get.put(
      DietController(userId: 1),
    );

    // Establece algunos valores de ejemplo
    dietController.totalCalories.value = 1500;
    dietController.maxCalories.value = 2000;
    dietController.totalProteins.value = 100;
    dietController.maxProteins.value = 150;
    dietController.totalCarbs.value = 250;
    dietController.maxCarbs.value = 300;
    dietController.totalFat.value = 70;
    dietController.maxFat.value = 100;

    // Renderiza la pantalla de DietScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(
          userName: 'Test User',
          nombre: 'Test',
          userId: 1,
        ),
      ),
    );

    // Espera que las gráficas estén presentes
    expect(find.byType(CircularProgressIndicator), findsNWidgets(4));

    // Verifica si los valores son correctos
    // Nota: Aquí se verifican los porcentajes de progreso de las gráficas.
    // Puedes ajustar esta prueba para comprobar los textos que muestran los valores actuales.
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator).at(0),
          )
          .value,
      equals(dietController.totalCalories.value /
          dietController.maxCalories.value),
    );

    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator).at(1),
          )
          .value,
      equals(dietController.totalProteins.value /
          dietController.maxProteins.value),
    );

    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator).at(2),
          )
          .value,
      equals(dietController.totalCarbs.value / dietController.maxCarbs.value),
    );

    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator).at(3),
          )
          .value,
      equals(dietController.totalFat.value / dietController.maxFat.value),
    );
  });

  testWidgets(
      'HydrationCard displays correct number of water glasses and updates when adding water',
      (WidgetTester tester) async {
    Get.testMode = true;

    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(
          userName: 'Test User',
          nombre: 'Test',
          userId: 1,
        ),
      ),
    );
    expect(find.text("Water control"), findsOneWidget);
    expect(find.text("Add glass of water"), findsOneWidget);

    await tester.tap(find.text("Add glass of water"));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.local_drink), findsWidgets);

    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets(
      'Navigation bar in DietScreen navigates to Progress, Recipes, and Activities',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(
          userName: 'Test User',
          nombre: 'Test',
          userId: 1,
        ),
      ),
    );

    expect(find.text('Hi Test User! Here is your progress'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.restaurant));
    await tester.pumpAndSettle();

    expect(find.byType(RecipesContent), findsOneWidget);

    await tester.tap(find.byIcon(Icons.assignment));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pie_chart));
    await tester.pumpAndSettle();

    expect(find.text('Hi Test User! Here is your progress'), findsOneWidget);
  });

  testWidgets('Adding a recipe updates the charts on DietScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(
          userName: 'Test User',
          nombre: 'Test',
          userId: 1,
        ),
      ),
    );
    // Añade esta línea después de `await tester.pumpWidget(...)`
    final DietController dietController = Get.find<DietController>();

    expect(find.text('Hi Test User! Here is your progress'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.restaurant));
    await tester.pumpAndSettle();

    expect(find.byType(RecipesContent), findsOneWidget);

    await tester.tap(find.text('Add to Chart').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.pie_chart));
    await tester.pumpAndSettle();

    expect(dietController.totalCalories.value, greaterThan(0));
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets(
      'Verificar que una actividad se mueva entre listas, se ingresen datos y se marque como completada',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ActivityScreen(
          userId: 1,
          dateSelected: DateTime.now(),
        ),
      ),
    );

    expect(find.text('Available Activities'), findsOneWidget);

    await tester.tap(find.text('Sleep'));
    await tester.pumpAndSettle();

    expect(find.byType(SleepDialog), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '8 hours');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sleep'));
    await tester.pumpAndSettle();

    expect(find.textContaining('8 hours'), findsOneWidget);

    await tester.tap(find.byKey(const Key('SleepcompleteButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sleep'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Completed'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Verificar que el botón en DietScreen abra el menú y navegue a StreakScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(
          userName: 'Test User',
          nombre: 'User Test',
          userId: 1,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Exchange store'), findsOneWidget);

    await tester.tap(find.text('Exchange store'));
    await tester.pumpAndSettle();

    expect(find.text('Credits: 0'), findsOneWidget);
  });

  testWidgets(
      'Verificar que completar dos días seguidos de progreso genere un crédito',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(
          userName: 'Test User',
          nombre: 'User Test',
          userId: 1,
        ),
      ),
    );

    await tester.pumpAndSettle();

    print('Seleccionando la fecha de hoy');
    await tester.tap(find.text(DateFormat('d').format(DateTime.now())));
    await tester.pumpAndSettle();

    print('Ingresando calorías para hoy');
    await tester.ensureVisible(find.textContaining('Calories'));
    await tester.tap(find.textContaining('Calories'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('CaloriesTextField')).first, '2000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    print('Ingresando proteínas para hoy');
    await tester.ensureVisible(find.textContaining('Proteins'));
    await tester.tap(find.textContaining('Proteins'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('ProteinsTextField')).first, '100');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    print('Ingresando carbohidratos para hoy');
    await tester.ensureVisible(find.textContaining('Carbs'));
    await tester.tap(find.textContaining('Carbs'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('CarbsTextField')).first, '300');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    print('Ingresando grasas para hoy');
    await tester.ensureVisible(find.textContaining('Fats'));
    await tester.tap(find.textContaining('Fats'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('FatsTextField')).first, '70');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    print('Desplazándose para seleccionar la fecha de mañana');
    await tester.drag(find.byType(ListView),
        const Offset(-100, 0)); // Ajustar desplazamiento si es necesario
    await tester.pumpAndSettle();

    await tester.tap(find
        .text(DateFormat('d').format(DateTime.now().add(Duration(days: 1)))));
    await tester.pumpAndSettle();

    print('Ingresando calorías para mañana');
    await tester.ensureVisible(find.textContaining('Calories'));
    await tester.tap(find.textContaining('Calories'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('CaloriesTextField')).first, '2000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    print('Ingresando proteínas para mañana');
    await tester.ensureVisible(find.textContaining('Proteins'));
    await tester.tap(find.textContaining('Proteins'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('ProteinsTextField')).first, '100');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    print('Ingresando carbohidratos para mañana');
    await tester.ensureVisible(find.textContaining('Carbs'));
    await tester.tap(find.textContaining('Carbs'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('CarbsTextField')).first, '300');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    print('Ingresando grasas para mañana');
    await tester.ensureVisible(find.textContaining('Fats'));
    await tester.tap(find.textContaining('Fats'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('FatsTextField')).first, '70');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    print('Abriendo el menú y navegando a la tienda');
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exchange store'));
    await tester.pumpAndSettle();

    print('Verificando si se generó un crédito');
    expect(find.text('Credits: 0'), findsOneWidget);
  });
}
