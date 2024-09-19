import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily plan'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Fechas
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DateChip(text: '22 Mon'),
                DateChip(text: '23 Tue'),
                DateChip(text: '24 Wed', isSelected: true),
                DateChip(text: '25 Thu'),
                DateChip(text: '26 Fri'),
              ],
            ),
            const SizedBox(height: 20),

            // Gráfico de barras de calorías
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  'Graph: Total Kcal vs Burn',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Comidas del día
            const Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MealCard(
                      meal: 'Breakfast',
                      kcal: '800 kcal',
                      proteins: 'Proteins',
                      fats: 'Fat',
                      carbs: 'Carbs',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MealCard(
                      meal: 'Mid lunch',
                      kcal: '345 kcal',
                      proteins: 'Proteins',
                      fats: 'Fat',
                      carbs: 'Carbs',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MealCard(
                      meal: 'Night dinner',
                      kcal: '643 kcal',
                      proteins: 'Proteins',
                      fats: 'Fat',
                      carbs: 'Carbs',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seguimiento de agua
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Water Intake'),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(Icons.local_drink, color: index < 3 ? Colors.blue : Colors.grey);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DateChip extends StatelessWidget {
  final String text;
  final bool isSelected;

  const DateChip({super.key, required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (_) {},
    );
  }
}

class MealCard extends StatelessWidget {
  final String meal;
  final String kcal;
  final String proteins;
  final String fats;
  final String carbs;

  const MealCard({super.key, 
    required this.meal,
    required this.kcal,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meal, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(kcal, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(proteins, style: const TextStyle(color: Colors.blue)),
                    const SizedBox(height: 5),
                    const Text('Proteins', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text(fats, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 5),
                    const Text('Fats', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text(carbs, style: const TextStyle(color: Colors.orange)),
                    const SizedBox(height: 5),
                    const Text('Carbs', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
