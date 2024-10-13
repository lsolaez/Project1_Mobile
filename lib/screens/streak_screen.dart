import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class StreakScreen extends StatefulWidget {
  @override
  _StreakScreenState createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 18) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  Map<String, bool> claimedCodes = {};

  Map<String, String>? selectedDish;

  String? selectedCategory;

  final List<Map<String, String>> allRewards = [
    {
      'name': 'BODYTECH',
      'price': '\5 STREAK',
      'image': 'assets/imagenes/S1.jpg',
      'description': '1 day free',
      'category': 'Sport',
    },
    {
      'name': 'OAKBERRY',
      'price': '\10 STREAK',
      'image': 'assets/imagenes/S2.jpg',
      'description': '4 free toppings',
      'category': 'Food',
    },
    {
      'name': 'BODYTECH2',
      'price': '\20 STREAK',
      'image': 'assets/imagenes/S1.jpg',
      'description': 'A double pass for 3 days',
      'category': 'Sport',
    },
    {
      'name': 'FIT CHOICE',
      'price': '\35 STREAK',
      'image': 'assets/imagenes/S3.jpg',
      'description': 'Free a signature salad',
      'category': 'Food',
    },
    {
      'name': 'Sportfitness',
      'price': '\50 STREAK',
      'image': 'assets/imagenes/S4.jpg',
      'description': 'Free yoga mat',
      'category': 'Sport',
    },
    {
      'name': 'Rappi',
      'price': '\60 STREAK',
      'image': 'assets/imagenes/S5.jpg',
      'description': 'Free Rappi Prime',
      'category': 'Membership',
    },
    {
      'name': 'Fithub',
      'price': '\75 STREAK',
      'image': 'assets/imagenes/S6.jpg',
      'description': '100 market voucher',
      'category': 'Food',
    },
    {
      'name': 'MILPA',
      'price': '\90 STREAK',
      'image': 'assets/imagenes/S7.jpg',
      'description': '1 month of free yoga',
      'category': 'Membership',
    },
    {
      'name': 'DECATHLON',
      'price': '\110 STREAK',
      'image': 'assets/imagenes/S8.jpg',
      'description': '150 voucher for the store',
      'category': 'Sport',
    },
    {
      'name': 'SPINNING CENTER',
      'price': '\140 STREAK',
      'image': 'assets/imagenes/S9.jpeg',
      'description': 'One month free and 10 days for a guest',
      'category': 'Membership',
    },
  ];

  List<Map<String, String>> _getRewardsByCategory() {
    if (selectedCategory == null) {
      return allRewards;
    }
    return allRewards
        .where((reward) => reward['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9A8B), Color(0xFFF3ECEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Space to lower greeting and avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getGreeting(),
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                CircleAvatar(
                  backgroundImage: AssetImage('assets/profile_pic.png'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Nathalia',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Find your rewards',
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Categories',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryIcon(Icons.sports_soccer, 'Sport'),
                _buildCategoryIcon(Icons.card_membership, 'Membership'),
                _buildCategoryIcon(Icons.lunch_dining, 'Food'),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'New rewards',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _getRewardsByCategory().length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDish = _getRewardsByCategory()[index];
                      });
                    },
                    child: _buildDishCard(index),
                  );
                },
              ),
            ),
            if (selectedDish != null) _buildDishDetail(selectedDish!),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(IconData iconData, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedCategory == label) {
            selectedCategory = null;
          } else {
            selectedCategory = label;
          }
        });
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white, size: 30),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(int index) {
    final dish = _getRewardsByCategory()[index];
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(dish['image']!, height: 80),
          Text(dish['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            dish['description']!,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(dish['price']!, style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildDishDetail(Map<String, String> dish) {
    bool isClaimed = claimedCodes[dish['name']!] ?? false;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDish = null;
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(dish['image']!, height: 150),
              SizedBox(height: 10),
              Text(
                dish['name']!,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                _getDetailDescription(dish['name']!),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              if (isClaimed)
                Text(
                  'The code for this product has already been claimed.',
                  style: TextStyle(color: Colors.red),
                ),
              if (!isClaimed)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 255, 173, 173), // Button color
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    _showClaimDialog(dish['name']!);
                  },
                  child: Text(
                    'Claim',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClaimDialog(String productName) {
    showDialog(
      context: context,
      builder: (context) {
        String randomCode = _generateRandomCode();
        return AlertDialog(
          title: Text('Claim Code for $productName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Here is your unique code for $productName:'),
              SizedBox(height: 10),
              SelectableText(randomCode),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 255, 173, 173), // Button color
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: randomCode));
                  Navigator.of(context).pop();
                  setState(() {
                    claimedCodes[productName] = true;
                  });
                },
                child: Text('Copy and Claim'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _generateRandomCode() {
    String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  String _getDetailDescription(String productName) {
    switch (productName) {
      case 'BODYTECH':
        return 'Experience the best of fitness with a one-day free pass at BODYTECH gyms.';
      case 'OAKBERRY':
        return 'Enjoy a delicious smoothie with four free toppings at OAKBERRY.';
      case 'BODYTECH2':
        return 'Bring a friend! Get a double pass for 3 days at BODYTECH gyms.';
      case 'FIT CHOICE':
        return 'Savor a healthy signature salad from FIT CHOICE.';
      case 'Sportfitness':
        return 'Your dedication pays off! To keep you motivated. Claim a yoga mat in the color of your choice';
      case 'Rappi':
        return 'Shopping is now easier, and your streak knows it. Enjoy one month free of Rappi Prime.';
      case 'Fithub':
        return 'We’re paying for you! Enjoy a 100 voucher for healthy food.';
      case 'MILPA':
        return 'We’re giving you 1 month of free yoga so you can connect your heart and body in one place.';
      case 'DECATHLON':
        return 'Sports? Your streak covers it! We re giving you a 150 voucher for Decathlon.';
      case 'SPINNING CENTER':
        return 'You’re a Master! That’s why we want to gift you one month free and 10 days for your guest. Redeem it at the nearest gym.';
      default:
        return 'Reward description not available.';
    }
  }
}
