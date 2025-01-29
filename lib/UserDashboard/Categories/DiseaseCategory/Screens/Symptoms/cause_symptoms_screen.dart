import 'package:flutter/material.dart';

class CauseSymptomsScreen extends StatelessWidget {
  final List<String> causes = [
    "Smoking",
    "High Blood Pressure",
    "Diabetes",
    "Obesity",
    "Stress",
    "Excessive Alcohol Consumption",
    "Sedentary Lifestyle",
    "Unhealthy Diet",
    "High Cholesterol Levels",
    "Genetic Factors",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cause Symptoms"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: causes.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: Colors.deepPurple),
              title: Text(causes[index]),
            ),
          );
        },
      ),
    );
  }
}
