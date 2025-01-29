import 'package:flutter/material.dart';
import 'recommended_foods_screen.dart';

class NonRecommendedFoodsScreen extends StatefulWidget {
  @override
  _NonRecommendedFoodsScreenState createState() =>
      _NonRecommendedFoodsScreenState();
}

class _NonRecommendedFoodsScreenState
    extends State<NonRecommendedFoodsScreen> {
  int _currentIndex = 1;

  final List<Map<String, String>> nonRecommendedFoods = [
    {
      'item': 'Sugary Drinks',
      'quantity': 'Avoid completely',
      'reason': 'High in empty calories and sugar',
      'suitable_time': 'Never',
      'harmful_ingredients': 'High fructose',
    },
    {
      'item': 'Processed Snacks',
      'quantity': 'Avoid completely',
      'reason': 'Unhealthy fats',
      'suitable_time': 'Never',
      'harmful_ingredients': 'Trans fats',
    },
    {
      'item': 'Fried Foods',
      'quantity': 'Rarely consume',
      'reason': 'High fats and calories',
      'suitable_time': 'Occasionally (if needed)',
      'harmful_ingredients': 'Trans fats, Acrylamide',
    },
    {
      'item': 'High-fat Meats',
      'quantity': 'Limit to once/week',
      'reason': 'Can increase cholesterol levels.',
      'suitable_time': 'Occasionally (if needed)',
      'harmful_ingredients': 'Cholesterol',
    },
    {
      'item': 'Refined Grains',
      'quantity': 'Rarely consume',
      'reason': 'Lacks essential nutrients and fiber',
      'suitable_time': 'Never',
      'harmful_ingredients': 'Refined flour',
    },
    {
      'item': 'Excess Salt',
      'quantity': 'Less than 2g/day',
      'reason': 'Can lead to high blood pressure',
      'suitable_time': 'During cooking (in moderation)',
      'harmful_ingredients': 'Sodium',
    },
  ];

  final List<Widget> _screens = [
    RecommendedFoodsScreen(),
    NonRecommendedFoodsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Non-Recommended Foods',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: nonRecommendedFoods.length,
        itemBuilder: (context, index) {
          final food = nonRecommendedFoods[index];
          return Card(
            elevation: 6,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['item']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(food['quantity']!),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Suitable Time:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(food['suitable_time']!),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Harmful Ingredients:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(food['harmful_ingredients']!),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reason:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(food['reason']!),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index != _currentIndex) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => _screens[index]),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Recommended',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: 'Non-Recommended',
          ),
        ],
      ),
    );
  }
}
