import 'package:flutter/material.dart';
import 'package:project1/Helpers/db_helper.dart';
import 'package:project1/screens/create_account.dart';
import 'package:project1/screens/diet_screen.dart';


class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height, // Altura mínima igual al tamaño de la pantalla
          ),
          child: IntrinsicHeight(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF9A8B), Color(0xFFF3ECEF)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 80.0),
                      child: Text(
                        'Fitness\nYou Wanna\nHave',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
                      child: Image.asset(
                        'assets/imagenes/logini.png',
                        height: MediaQuery.of(context).size.height * 0.3, // Ajuste dinámico del tamaño de la imagen
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Username',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: 'Password',
                            suffixIcon: Icon(Icons.visibility_off),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Forgot Details?',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateAccountScreen(), // Navegar a la pantalla de crear cuenta
                                  ),
                                );
                              },
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            String email = emailController.text;
                            String password = passwordController.text;

                            // Validar credenciales en la base de datos (en DBHelper)
                            bool isValidUser = await DBHelper.validateUser(email, password);
                            if (isValidUser) {
                              // Obtener el nombre completo del usuario
                              String fullName = await DBHelper.getUserFullName(email);

                              // Extraer el primer nombre
                              String firstName = fullName.split(' ')[0];

                              int userId = await DBHelper.getUserId(email); // Obtener el userId
                              print('Valor de userId enviado a DietScreen: ${userId}');
                              // Navegar a DietScreen pasando el primer nombre
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DietScreen(
                                    userName: firstName, nombre: fullName, userId: userId, // Pasar el primer nombre
                                  ),
                                ),
                              );
                            } else {
                              // Mostrar un mensaje de error si las credenciales no son válidas
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Login Failed'),
                                    content: const Text('Invalid username or password.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: const Color(0xFFFA7268),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Espacio adicional al final
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
