import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DiseaseSymptomsScreen extends StatefulWidget {
  final String categoryTitle; // e.g., "Heart", "Diabetes"

  const DiseaseSymptomsScreen({super.key, required this.categoryTitle});

  @override
  State<DiseaseSymptomsScreen> createState() => _DiseaseSymptomsScreenState();
}

class _DiseaseSymptomsScreenState extends State<DiseaseSymptomsScreen> {
  List<String> symptoms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSymptoms();
  }

  Future<void> loadSymptoms() async {
    final String response = await rootBundle.loadString('assets/JasonFiles/symptoms_data.json');
    final Map<String, dynamic> data = json.decode(response);

    setState(() {
      symptoms = List<String>.from(
        data[widget.categoryTitle]?['symptoms'] ?? [],
      );
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.categoryTitle} Symptoms"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : symptoms.isEmpty
          ? Center(child: Text("No symptoms found for ${widget.categoryTitle}"))
          : ListView.builder(
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
