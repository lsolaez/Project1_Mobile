import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project1/Controllers/DietController.dart';
import 'package:project1/screens/diet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    const DietScreen(), // Pantalla de Dieta
    const Text('Settings Screen'),
  ];

  final List<String> _titles = [
    'Healthy Recipes', // Título para la pantalla de inicio
    'Diet Tracker',    // Título para la pantalla de dieta
    'Settings',        // Título para la pantalla de configuración
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]), // Cambiar el título dinámicamente
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFA7268), // Color degradado superior
                Color(0xFFF3ECEF), // Color degradado inferior
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _screens[_selectedIndex], // Cargar la pantalla seleccionada
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1D1B20), // Color de fondo de la barra (negro/gris oscuro)
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart, size: 30),
              label: 'Diet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 30),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final DietController dietController = Get.put(DietController());
  final List<Recipe> recipes = [
    Recipe(
      title: 'Avocado Toast',
      image: 'assets/imagenes/avocado_toast.jpg',
      ingredients: 'Avocado, Whole-grain bread, Olive oil, Salt',
      preparation:
          'Toast the bread, mash the avocado, add olive oil and salt.',
      calories: 250,
      protein: 6,
      fat: 12,
      carbs: 20,
    ),
    Recipe(
      title: 'Quinoa Salad',
      image: 'assets/imagenes/quinoa_salad.jpg',
      ingredients: 'Quinoa, Cucumber, Tomato, Olive oil, Lemon juice',
      preparation:
          'Cook quinoa, chop vegetables, mix everything with olive oil and lemon juice.',
      calories: 320,
      protein: 10,
      fat: 14,
      carbs: 40,
    ),
    Recipe(
      title: 'Smoothie Bowl',
      image: 'assets/imagenes/smoothie_bowl.jpg',
      ingredients: 'Banana, Berries, Greek yogurt, Granola, Honey',
      preparation:
          'Blend banana and berries, top with yogurt, granola, and honey.',
      calories: 350,
      protein: 8,
      fat: 9,
      carbs: 58,
    ),
    Recipe(
      title: 'Grilled Chicken Salad',
      image: 'assets/imagenes/chicken_salad.jpg',
      ingredients: 'Chicken breast, Lettuce, Tomato, Cucumber, Olive oil',
      preparation: 'Grill chicken, chop vegetables, mix with olive oil.',
      calories: 400,
      protein: 35,
      fat: 20,
      carbs: 10,
    ),
    Recipe(
      title: 'Vegetable Stir-fry',
      image: 'assets/imagenes/veggie_stirfry.jpg',
      ingredients: 'Broccoli, Carrot, Bell pepper, Soy sauce, Sesame oil',
      preparation: 'Stir-fry vegetables with sesame oil and soy sauce.',
      calories: 200,
      protein: 4,
      fat: 8,
      carbs: 30,
    ),
    Recipe(
      title: 'Overnight Oats',
      image: 'assets/imagenes/Overnight-Oats.jpg',
      ingredients: 'Oats, Almond milk, Chia seeds, Berries, Honey',
      preparation:
          'Mix oats, milk, chia seeds, refrigerate overnight, top with berries and honey.',
      calories: 280,
      protein: 8,
      fat: 5,
      carbs: 50,
    ),
  ];

  HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFA7268), // Color degradado superior
            Color(0xFFF3ECEF), // Color degradado inferior
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.5,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return RecipeCard(
                  recipe: recipes[index], dietController: dietController);
            },
          ),
        ),
      ),
    );
  }
}

class Recipe {
  final String title;
  final String image;
  final String ingredients;
  final String preparation;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;

  Recipe({
    required this.title,
    required this.image,
    required this.ingredients,
    required this.preparation,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final DietController dietController;

  const RecipeCard({super.key, required this.recipe, required this.dietController});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reducimos el flex para que la imagen no ocupe tanto espacio
          Expanded(
            flex: 2, // Reducir el flex de la imagen
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                recipe.image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          // Aumentamos el flex para el contenido y lo hacemos scrolleable
          Expanded(
            flex: 3, // Aumentar el flex para el contenido
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 14, // Tamaño de texto ajustado
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Calories: ${recipe.calories} kcal',
                      style: TextStyle(
                        fontSize: 10, // Tamaño de texto reducido
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Protein: ${recipe.protein}g, Fat: ${recipe.fat}g, Carbs: ${recipe.carbs}g',
                      style: TextStyle(
                        fontSize: 10, // Tamaño de texto reducido
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Preparation: ${recipe.preparation}',
                      style: TextStyle(
                        fontSize: 10, // Tamaño de texto reducido
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          dietController.addToChart(recipe.calories.toDouble(),
                              recipe.protein.toDouble(), recipe.carbs.toDouble());
                        },
                        child: const Text(
                          'Add to Chart',
                          style: TextStyle(fontSize: 12), // Ajuste del tamaño del botón
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
