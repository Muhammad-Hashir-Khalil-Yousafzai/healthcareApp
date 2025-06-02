import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../CommonScreens/AI assistant/ai_assistant_screen.dart';
import '../CommonScreens/Diet/recommended_foods_screen.dart';
import 'Screens/BMR/BMRscreen.dart';
import 'Screens/GYM/gym_screen.dart';
import 'Screens/BMI Calculator/bmi_prediction_screen.dart';
import 'Screens/Trainer//gym_trainer_screen.dart';
// import 'package:healthcare/UserDashboard/Categories/CommonScreens/AI assistant/ai_assistant_screen.dart';

class PhysicalHealthScreen extends StatelessWidget {
  final String categoryTitle;

  // Constructor to receive category title
  PhysicalHealthScreen({super.key, required this.categoryTitle});

  final List<Map<String, dynamic>> gridItems = [
    {'title': 'Diet', 'icon': Icons.restaurant},
    {'title': 'BMR', 'icon': Icons.whatshot},
    {'title': 'Gym', 'icon': Icons.fitness_center},
    {'title': 'BMI Prediction', 'icon': Icons.analytics},
    {'title': 'Gym Trainer', 'icon': Icons.group},
    {'title': 'AI Assistant', 'icon': Icons.smart_toy},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '$categoryTitle Features', // Dynamic title
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: gridItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = gridItems[index];
            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  switch (item['title']) {

                    case 'Diet':
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => RecommendedFoodsScreen(category: categoryTitle),
                      ),
                      );
                      break;

                    case 'BMR':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BMRScreen()),
                      );
                      break;
                    case 'Gym':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GymScreen()),
                      );
                      break;
                    case 'BMI Prediction':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BMICalculatorScreen()),
                      );
                      break;
                    case 'Gym Trainer':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GymTrainerScreen()),
                      );
                      break;
                    case 'AI Assistant':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AIAssistantScreen(categoryTitle: categoryTitle,)),
                      );
                      break;

                    default:
                      print('${item['title']} tapped in $categoryTitle');
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'], size: 48, color: Colors.deepPurple),
                    SizedBox(height: 8),
                    Text(
                      item['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}