import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/Helpers/db_helper.dart'; // Importar DBHelper para la gestión de la base de datos
import 'dart:math';

class StreakScreen extends StatefulWidget {
  final String userName;
  final int userId; // Necesitamos el userId para acceder a la DB

  const StreakScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  _StreakScreenState createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  Map<String, bool> claimedCodes = {};
  Map<String, String>? selectedDish;
  String? selectedCategory;
  int userCredits = 0; // Créditos actuales del usuario

  final List<Map<String, String>> allRewards = [
    {
      'name': 'BODYTECH',
      'price': '1', // Número de créditos necesarios (sin "STREAK")
      'image': 'assets/imagenes/S1.jpg',
      'description': '1 day free',
      'category': 'Sport',
    },
    {
      'name': 'OAKBERRY',
      'price': '1',
      'image': 'assets/imagenes/S2.jpg',
      'description': '4 free toppings',
      'category': 'Food',
    },
    {
      'name': 'BODYTECH2',
      'price': '1',
      'image': 'assets/imagenes/S1.jpg',
      'description': 'A double pass for 3 days',
      'category': 'Sport',
    },
    {
      'name': 'FIT CHOICE',
      'price': '1',
      'image': 'assets/imagenes/S3.jpg',
      'description': 'Free a signature salad',
      'category': 'Food',
    },
    {
      'name': 'Sportfitness',
      'price': '1',
      'image': 'assets/imagenes/S4.jpg',
      'description': 'Free yoga mat',
      'category': 'Sport',
    },
    {
      'name': 'Rappi',
      'price': '1',
      'image': 'assets/imagenes/S5.jpg',
      'description': 'Free Rappi Prime',
      'category': 'Membership',
    },
    {
      'name': 'Fithub',
      'price': '1',
      'image': 'assets/imagenes/S6.jpg',
      'description': '100 market voucher',
      'category': 'Food',
    },
    {
      'name': 'MILPA',
      'price': '1',
      'image': 'assets/imagenes/S7.jpg',
      'description': '1 month of free yoga',
      'category': 'Membership',
    },
    {
      'name': 'DECATHLON',
      'price': '1',
      'image': 'assets/imagenes/S8.jpg',
      'description': '150 voucher for the store',
      'category': 'Sport',
    },
    {
      'name': 'SPINNING CENTER',
      'price': '1',
      'image': 'assets/imagenes/S9.jpeg',
      'description': 'One month free and 10 days for a guest',
      'category': 'Membership',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserCredits();
    _loadClaimedRewards(); // Cargar los premios reclamados al iniciar la sesión
  }

// Nueva función para cargar los premios reclamados
  Future<void> _loadClaimedRewards() async {
    for (var reward in allRewards) {
      bool isClaimed =
          await DBHelper.isRewardClaimed(widget.userId, reward['name']!);
      setState(() {
        claimedCodes[reward['name']!] = isClaimed;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning, ${widget.userName}';
    } else if (hour < 17) {
      return 'Good Afternoon, ${widget.userName}';
    } else if (hour < 20) {
      return 'Good Evening, ${widget.userName}';
    } else {
      return 'Good Night, ${widget.userName}';
    }
  }

  Future<void> _loadUserCredits() async {
    // Obtener los créditos del usuario desde la base de datos
    int credits = await DBHelper.getCreditsForUser(widget.userId);
    setState(() {
      userCredits = credits; // Actualizamos el estado con los créditos
    });
  }

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9A8B), Color(0xFFF3ECEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            const SizedBox(height: 20),
            Text(
              _getGreeting(), // Saludo personalizado
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Credits: $userCredits', // Mostrar créditos actuales
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Find your rewards',
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Categories',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryIcon(Icons.sports_soccer, 'Sport'),
                _buildCategoryIcon(Icons.card_membership, 'Membership'),
                _buildCategoryIcon(Icons.lunch_dining, 'Food'),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'New rewards',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildRewardsGrid(), // Usar la función para construir el Grid de recompensas
            if (selectedDish != null)
              _buildDishDetail(
                  selectedDish!), // Mostrar detalles si se selecciona un premio
          ],
        ),
      ),
    );
  }

  // Método para mostrar el cuadro de diálogo de canje
  void _showRedeemDialog(Map<String, String> dish) {
    int price = int.parse(dish['price']!); // Precio en créditos
    bool isClaimed = claimedCodes[dish['name']!] ?? false;

    if (userCredits >= price && !isClaimed) {
      // El usuario tiene suficientes créditos
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Redeem ${dish['name']} for $price credits?'),
            content: SingleChildScrollView(
              // Evitar overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(dish['image']!, height: 150),
                  const SizedBox(height: 10),
                  const Text('This reward will cost you credits.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _redeemReward(dish['name']!, price);
                  Navigator.of(context).pop();
                },
                child: const Text('Redeem'),
              ),
            ],
          );
        },
      );
    } else if (isClaimed) {
      // Si el premio ya fue canjeado
      _showAlreadyClaimedWarning();
    } else {
      // Si no tiene suficientes créditos
      _showInsufficientCreditsWarning();
    }
  }

  // Mostrar advertencia de "premio ya canjeado"
  void _showAlreadyClaimedWarning() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Already Claimed'),
          content: const Text('You have already claimed this reward.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar advertencia de "créditos insuficientes"
  void _showInsufficientCreditsWarning() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Insufficient Credits'),
          content: const Text(
              'You do not have enough credits to claim this reward.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _redeemReward(String rewardName, int price) async {
    // Verifica si el premio ya fue canjeado
    bool isClaimed = claimedCodes[rewardName] ?? false;

    // Si no ha sido canjeado y hay suficientes créditos
    if (!isClaimed && userCredits >= price) {
      // Registrar el canje en la base de datos
      await DBHelper.redeemReward(widget.userId, rewardName);

      // Descontar los créditos del usuario
      int newCredits = userCredits - price;
      await DBHelper.updateCreditsForUser(widget.userId, newCredits);

      // Actualizar el estado local de los créditos y marcar como reclamado
      setState(() {
        userCredits = newCredits;
        claimedCodes[rewardName] = true; // Marcar el premio como reclamado
      });

      // Mostrar el cuadro de diálogo con el código generado
      _showClaimDialog(rewardName);
    } else if (isClaimed) {
      // Si el premio ya fue canjeado, mostrar advertencia
      _showAlreadyClaimedWarning();
    } else {
      // Si no hay suficientes créditos, mostrar advertencia
      _showInsufficientCreditsWarning();
    }
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

  // Método para construir las tarjetas de recompensas (recompensas visuales)
  Widget _buildDishCard(int index) {
    final dish = _getRewardsByCategory()[index];
    bool isClaimed = claimedCodes[dish['name']!] ??
        false; // Verificar si el premio fue reclamado

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(dish['image']!,
              height: 80,
              fit: BoxFit.cover), // Limitar altura y ajuste de la imagen
          Text(
            dish['name']!,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis, // Limitar la longitud del texto
            maxLines: 1, // Solo una línea de texto
          ),
          Text(
            dish['description']!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            overflow: TextOverflow.ellipsis, // Limitar texto a una línea
            maxLines: 2, // Limitar a dos líneas
          ),
          // Mostrar mensaje de reclamación o el precio según el estado de "isClaimed"
          if (isClaimed)
            const Text(
              'You have already claimed this reward', // Mensaje cuando el premio ya fue reclamado
              style: TextStyle(color: Colors.green),
            )
          else
            Text(
              '${dish['price']} STREAK', // Mostrar el precio si no ha sido reclamado
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildRewardsGrid() {
    return Container(
      height: 500, // Puedes ajustar la altura según el contenido
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dos columnas en la cuadrícula
          childAspectRatio: 0.8, // Relación de aspecto para ajustar el tamaño
          crossAxisSpacing: 10, // Espacio entre las columnas
          mainAxisSpacing: 10, // Espacio entre las filas
        ),
        itemCount: _getRewardsByCategory().length, // Número de recompensas
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDish =
                    _getRewardsByCategory()[index]; // Seleccionar la recompensa
              });
              _showRedeemDialog(
                  selectedDish!); // Mostrar el diálogo para canjear la recompensa
            },
            child:
                _buildDishCard(index), // Construir la tarjeta de la recompensa
          );
        },
      ),
    );
  }

  // Método para mostrar el detalle del premio
  Widget _buildDishDetail(Map<String, String> dish) {
    bool isClaimed = claimedCodes[dish['name']!] ?? false;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDish = null;
        });
      },
      child: SingleChildScrollView(
        // Evitar overflow
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(dish['image']!, height: 150),
                const SizedBox(height: 10),
                Text(
                  dish['name']!,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  _getDetailDescription(dish['name']!),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (isClaimed)
                  const Text(
                    'The code for this product has already been claimed.',
                    style: TextStyle(color: Colors.red),
                  ),
                if (!isClaimed)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 255, 173, 173), // Color del botón
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      _showClaimDialog(dish['name']!);
                    },
                    child: const Text(
                      'Claim',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mostrar cuadro de diálogo con el código generado
  void _showClaimDialog(String productName) {
    showDialog(
      context: context,
      builder: (context) {
        // Generar el código aleatorio para la redención
        String randomCode = _generateRandomCode();

        return AlertDialog(
          title: Text('Claim Code for $productName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Here is your unique code for this reward:'),
              const SizedBox(height: 10),
              SelectableText(
                randomCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 255, 173, 173), // Color del botón
                ),
                onPressed: () {
                  // Copiar el código generado al portapapeles
                  Clipboard.setData(ClipboardData(text: randomCode));
                  // Actualizar el estado para marcar el premio como reclamado
                  setState(() {
                    claimedCodes[productName] = true;
                  });
                  // Cerrar el cuadro de diálogo
                  Navigator.of(context).pop();
                },
                child: const Text('Copy and Claim'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Generar código aleatorio
  String _generateRandomCode() {
    String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // Descripciones detalladas de los premios
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
        return 'Sports? Your streak covers it! We’re giving you a 150 voucher for Decathlon.';
      case 'SPINNING CENTER':
        return 'You’re a Master! That’s why we want to gift you one month free and 10 days for your guest. Redeem it at the nearest gym.';
      default:
        return 'Reward description not available.';
    }
  }
}
