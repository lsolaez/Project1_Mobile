import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project1/Controllers/dietController.dart';
import 'package:project1/Helpers/db_helper.dart';
import 'package:project1/screens/diet_screen.dart';
import 'screens/get_started.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Elimina la base de datos
  await DBHelper.deleteDatabase();
  Get.put(DietController());
  // Corre la aplicación
  runApp(const MyApp());
}

//
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStartedScreen(),
      },
    );
  }
}
