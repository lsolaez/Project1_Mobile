import 'package:flutter/material.dart';
import 'package:project1/Helpers/db_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;

  const EditProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Cargar los datos del perfil desde la base de datos
  Future<void> _loadUserProfile() async {
    final userData = await DBHelper.getUserData(widget.userId);
    if (userData != null) {
      setState(() {
        _fullNameController.text = userData['fullName'];
        _emailController.text = userData['email'];
        _phoneController.text = userData['phone'];
        _sexController.text = userData['sex'];
        _ageController.text = userData['age'].toString();
      });
    }
  }

  // Guardar los cambios en la base de datos
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await DBHelper.updateUserProfile(
        widget.userId,
        _fullNameController.text,
        _emailController.text,
        _phoneController.text,
        _sexController.text,
        int.parse(_ageController.text),
      );
      Navigator.pop(context); // Regresar a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor:const Color.fromARGB(255, 255, 173, 173),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mostrar imagen de perfil
              CircleAvatar(
                radius: 80,
                backgroundImage: const AssetImage('assets/imagenes/profile_pic.png'),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 20),

              // Campos para editar el perfil con controladores
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _sexController,
                decoration: const InputDecoration(
                  labelText: 'Sex',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 173, 173), // Color del botón
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar los controladores cuando la pantalla se destruye
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _sexController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
