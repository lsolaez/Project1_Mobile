import 'package:flutter/material.dart';
import 'package:project1/screens/login.dart';

import 'screens/get_started.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

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
        '/loginscreen': (context) =>  LoginScreen(),
      },
    );
  }
}
