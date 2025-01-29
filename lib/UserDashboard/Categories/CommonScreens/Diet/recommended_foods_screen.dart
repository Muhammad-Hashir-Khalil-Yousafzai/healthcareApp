import 'package:flutter/material.dart';
import 'non_recommended_foods_screen.dart';

class RecommendedFoodsScreen extends StatefulWidget {
  @override
  _RecommendedFoodsScreenState createState() => _RecommendedFoodsScreenState();
}

class _RecommendedFoodsScreenState extends State<RecommendedFoodsScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> recommendedFoods = [
    {
      'item': 'Fresh Fruits',
      'quantity': '2-3 servings/day',
      'reason': 'Rich in vitamins and antioxidants.',
      'suitable_time': 'Morning or as a snack',
      'vitamins_minerals': 'Vitamin C, Potassium, Fiber',
    },
    {
      'item': 'Leafy Vegetables',
      'quantity': '2 cups/day',
      'reason': 'High in fiber and nutrients',
      'suitable_time': 'Lunch or dinner',
      'vitamins_minerals': 'Vitamin K, Folate, Iron',
    },
    {
      'item': 'Whole Grains',
      'quantity': '3-5 servings/day',
      'reason': 'Good source of energy and fiber',
      'suitable_time': 'Breakfast or lunch',
      'vitamins_minerals': 'Vitamin B, Magnesium, Fiber',
    },
    {
      'item': 'Low-fat Dairy',
      'quantity': '1-2 servings/day',
      'reason': 'Provides calcium and protein',
      'suitable_time': 'Breakfast or dinner',
      'vitamins_minerals': 'Calcium, Vitamin D, Protein',
    },
    {
      'item': 'Lean Proteins',
      'quantity': '50-60 grams/day',
      'reason': 'muscle repair and growth',
      'suitable_time': 'Lunch or dinner',
      'vitamins_minerals': 'Iron, Zinc, Protein',
    },
    {
      'item': 'Nuts and Seeds',
      'quantity': 'A handful/day',
      'reason': 'Rich in healthy fats and omega-3',
      'suitable_time': 'Snack or added to meals',
      'vitamins_minerals': 'Vitamin E, Omega-3, Mg',
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
        title: Text('Recommended Foods', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: recommendedFoods.length,
        itemBuilder: (context, index) {
          final food = recommendedFoods[index];
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
                      Text('Quantity:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Flexible(
                        child: Text(
                          food['quantity']!,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Suitable Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Flexible(
                        child: Text(
                          food['suitable_time']!,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Vitamins & Minerals:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Flexible(
                        child: Text(
                          food['vitamins_minerals']!,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          food['reason']!,
                          textAlign: TextAlign.justify,
                          overflow: TextOverflow.clip,
                        ),
                      ),
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
