import 'package:flutter/material.dart';

class DiseaseSymptomsScreen extends StatelessWidget {
  final List<String> symptoms = [
    "Chest Pain",
    "Shortness of Breath",
    "Fatigue",
    "Irregular Heartbeat",
    "Dizziness",
    "Nausea or Vomiting",
    "Cold Sweats",
    "Pain in Jaw or Back",
    "Swollen Legs or Feet",
    "Difficulty Exercising",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Disease Symptoms"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: symptoms.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.health_and_safety, color: Colors.deepPurple),
              title: Text(symptoms[index]),
            ),
          );
        },
      ),
    );
  }
}
