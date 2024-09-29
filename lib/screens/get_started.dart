import 'package:flutter/material.dart';
import 'home.dart'; // Importar la nueva pantalla

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GetStartedScreen(),
    );
  }
}

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo que ocupa todo el espacio
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/imagenes/Welcome.jpg'), // Ruta de la imagen
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido encima de la imagen
          Positioned(
            bottom: 30,
            left: 40,
            right: 40,
            child: !_isButtonPressed
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 173, 173),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      setState(() {
                        _isButtonPressed = true;
                      });
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 252, 252),
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ingrese su nombre:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Nombre',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color.fromARGB(135, 155, 155, 155),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            // Puedes eliminar la variable _name si no la necesitas
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            String name = _nameController.text;
                            // Navegar a la pantalla de inicio
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 173, 173),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'Aceptar',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 252, 252),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
