import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Recipe> recipes = [
    Recipe(
      title: 'Avocado Toast',
      image: 'imagenes/avocado_toast.jpg',
      ingredients: 'Avocado, Whole-grain bread, Olive oil, Salt',
      preparation: 'Toast the bread, mash the avocado, add olive oil and salt.',
      calories: 250,
      protein: 6,
      fat: 12,
      carbs: 20,
    ),
    Recipe(
      title: 'Quinoa Salad',
      image: 'imagenes/quinoa_salad.jpg',
      ingredients: 'Quinoa, Cucumber, Tomato, Olive oil, Lemon juice',
      preparation: 'Cook quinoa, chop vegetables, mix everything with olive oil and lemon juice.',
      calories: 320,
      protein: 10,
      fat: 14,
      carbs: 40,
    ),
    Recipe(
      title: 'Smoothie Bowl',
      image: 'imagenes/smoothie_bowl.jpg',
      ingredients: 'Banana, Berries, Greek yogurt, Granola, Honey',
      preparation: 'Blend banana and berries, top with yogurt, granola, and honey.',
      calories: 350,
      protein: 8,
      fat: 9,
      carbs: 58,
    ),
    Recipe(
      title: 'Grilled Chicken Salad',
      image: 'imagenes/chicken_salad.jpg',
      ingredients: 'Chicken breast, Lettuce, Tomato, Cucumber, Olive oil',
      preparation: 'Grill chicken, chop vegetables, mix with olive oil.',
      calories: 400,
      protein: 35,
      fat: 20,
      carbs: 10,
    ),
    Recipe(
      title: 'Vegetable Stir-fry',
      image: 'imagenes/veggie_stirfry.jpg',
      ingredients: 'Broccoli, Carrot, Bell pepper, Soy sauce, Sesame oil',
      preparation: 'Stir-fry vegetables with sesame oil and soy sauce.',
      calories: 200,
      protein: 4,
      fat: 8,
      carbs: 30,
    ),
    Recipe(
      title: 'Overnight Oats',
      image: 'imagenes/Overnight-Oats.jpg',
      ingredients: 'Oats, Almond milk, Chia seeds, Berries, Honey',
      preparation: 'Mix oats, milk, chia seeds, refrigerate overnight, top with berries and honey.',
      calories: 280,
      protein: 8,
      fat: 5,
      carbs: 50,
    ),
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthy Recipes'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFA7268),  // Color degradado superior
                Color(0xFFF3ECEF),  // Color degradado inferior
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFA7268),  // Color degradado superior
              Color(0xFFF3ECEF),  // Color degradado inferior
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
                crossAxisCount: 2, // 2 columnas
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 4, // Proporción de las tarjetas
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(recipe: recipes[index]);
              },
            ),
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

  const RecipeCard({super.key, required this.recipe});

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
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                recipe.image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Calories: ${recipe.calories} kcal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Protein: ${recipe.protein}g, Fat: ${recipe.fat}g, Carbs: ${recipe.carbs}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ingredients: ${recipe.ingredients}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Preparation: ${recipe.preparation}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
