import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CauseSymptomsScreen extends StatefulWidget {
  final String categoryTitle;

  const CauseSymptomsScreen({Key? key, required this.categoryTitle}) : super(key: key);

  @override
  _CauseSymptomsScreenState createState() => _CauseSymptomsScreenState();
}

class _CauseSymptomsScreenState extends State<CauseSymptomsScreen> {
  List<String> causes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCauseSymptoms();
  }

  Future<void> loadCauseSymptoms() async {
    final String jsonString = await rootBundle.loadString('assets/JasonFiles/symptoms_data.json');
    final data = json.decode(jsonString);

    final List<String> loadedCauses =
    List<String>.from(data[widget.categoryTitle]?['causes'] ?? []);

    setState(() {
      causes = loadedCauses;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cause Symptoms"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : causes.isEmpty
          ? Center(child: Text("No cause data found for ${widget.categoryTitle}"))
          : ListView.builder(
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
