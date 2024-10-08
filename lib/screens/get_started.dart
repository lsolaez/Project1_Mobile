import 'package:flutter/material.dart';
import 'login.dart'; 

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/imagenes/Welcome.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
          ),

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
                      // Navegar a la pantalla de login
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
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
                : Container(), // Aquí puedes agregar otro contenido si es necesario
          ),
        ],
      ),
    );
  }
}