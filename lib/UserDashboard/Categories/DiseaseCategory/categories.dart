import 'package:flutter/material.dart';
import '../CommonScreens/AI assistant/ai_assistant_screen.dart';
import '../CommonScreens/Diet/recommended_foods_screen.dart';
import 'Screens/Doctor/Doctors.dart';
import 'Screens/Precautions/Do.dart';
import 'Screens/Predictions/heart_prediction_screen.dart';
import 'Screens/Symptoms/symptoms_navigation_screen.dart'; // Heart Prediction Screen
import 'Screens/Predictions/lungs_prediction_screen.dart'; // Physical Prediction Screen
import 'Screens/Predictions/mental_prediction_screen.dart'; // Mental Prediction Screen
import 'Screens/Predictions/bp_prediction_screen.dart';
import 'Screens/Predictions/diabetes_prediction_screen.dart';
// import 'package:healthcare/UserDashboard/Categories/CommonScreens/AI assistant/ai_assistant_screen.dart';
// Add more screens as needed for each category

class NewScreen extends StatelessWidget {
  final String categoryTitle;

  // Constructor to receive category title
  NewScreen({required this.categoryTitle});

  final List<Map<String, dynamic>> gridItems = [
    {'title': 'Symptoms', 'icon': Icons.sick},
    {'title': 'Precautions', 'icon': Icons.security},
    {'title': 'Prediction', 'icon': Icons.analytics},
    {'title': 'Diet', 'icon': Icons.restaurant},
    {'title': 'Doctors', 'icon': Icons.medical_services},
    {'title': 'AI Consultant', 'icon': Icons.smart_toy},
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
                  if (item['title'] == 'Diet') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecommendedFoodsScreen(category: categoryTitle),
                      ),
                    );
                  }

                    else if (item['title'] == 'Precautions') {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => DosScreen(categoryTitle: categoryTitle),
                      ),
                      );

                  }
                  else if (item['title'] == 'AI Consultant') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AIAssistantScreen(categoryTitle: categoryTitle)),
                    );
                  }
                  else if (item['title'] == 'Doctors') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DoctorListScreen(categoryTitle: categoryTitle)),
                    );
                  }
                  else if (item['title'] == 'Symptoms') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SymptomsNavigationScreen(categoryTitle: categoryTitle)),
                    );

                  } else if (item['title'] == 'Prediction') {
                    // Navigate to category-specific Prediction Screen
                    if (categoryTitle == 'Heart') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PredictionScreen()),
                      );
                    } else if (categoryTitle == 'Lungs') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LungsPredictionScreen()),
                      );
                    } else if (categoryTitle == 'Mental Health') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MentalHealthPredictionScreen()),
                      );
                    }
                    else if (categoryTitle == 'Diabetes') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiabetesPredictionScreen()),
                      );

                    }
                    else if (categoryTitle == 'BP') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BPPredictionScreen()),
                      );
                    }
                    else {
                      // Add other prediction screens for more categories
                      print('Prediction screen not defined for $categoryTitle');
                    }
                  } else {
                    // Handle other categories
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
