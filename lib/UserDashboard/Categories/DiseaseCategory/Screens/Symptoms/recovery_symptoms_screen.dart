import 'package:flutter/material.dart';

class RecoverySymptomsScreen extends StatelessWidget {
  final List<String> recoveries = [
    "Gradual Resumption of Physical Activity",
    "Reduced Chest Pain",
    "Improved Breathing",
    "Increased Energy Levels",
    "Better Sleep Patterns",
    "Normalization of Blood Pressure",
    "Healthy Weight Management",
    "Improved Cholesterol Levels",
    "Emotional Stability",
    "Ability to Exercise Regularly",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recovery Symptoms"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: recoveries.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.healing, color: Colors.deepPurple),
              title: Text(recoveries[index]),
            ),
          );
        },
      ),
    );
  }
}
