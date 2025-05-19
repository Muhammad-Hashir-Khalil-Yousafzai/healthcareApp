import 'dart:convert';
import 'package:flutter/material.dart';
import 'Dont.dart';

class DosScreen extends StatefulWidget {
  final String categoryTitle;

  DosScreen({required this.categoryTitle});

  @override
  _DosScreenState createState() => _DosScreenState();
}

class _DosScreenState extends State<DosScreen> {
  List<String> dosList = [];
  int _currentIndex = 0;

  Future<void> loadDos() async {
    final jsonString =
    await DefaultAssetBundle.of(context).loadString('assets/JasonFiles/precautions.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      dosList = jsonData
          .where((item) =>
      item['category'] == widget.categoryTitle &&
          item['type'] == 'do')
          .map<String>((item) => item['text'] as String)
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadDos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Do's", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: dosList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 40),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dosList[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                index == 0 ? DosScreen(categoryTitle: widget.categoryTitle) : DontsScreen(categoryTitle: widget.categoryTitle),
              ),
            );
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Do's"),
          BottomNavigationBarItem(icon: Icon(Icons.cancel), label: "Don'ts"),
        ],
      ),
    );
  }
}
