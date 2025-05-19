import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class RecoverySymptomsScreen extends StatefulWidget {
  final String categoryTitle;

  const RecoverySymptomsScreen({Key? key, required this.categoryTitle}) : super(key: key);

  @override
  _RecoverySymptomsScreenState createState() => _RecoverySymptomsScreenState();
}

class _RecoverySymptomsScreenState extends State<RecoverySymptomsScreen> {
  List<String> recoveries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecoverySymptoms();
  }

  Future<void> loadRecoverySymptoms() async {
    final String jsonString = await rootBundle.loadString('assets/JasonFiles/symptoms_data.json');
    final data = json.decode(jsonString);

    final List<String> loadedRecoveries =
    List<String>.from(data[widget.categoryTitle]?['recovery'] ?? []);

    setState(() {
      recoveries = loadedRecoveries;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recovery Symptoms"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recoveries.isEmpty
          ? Center(child: Text("No recovery data found for ${widget.categoryTitle}"))
          : ListView.builder(
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
