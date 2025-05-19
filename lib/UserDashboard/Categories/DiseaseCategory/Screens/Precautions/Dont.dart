import 'dart:convert';
import 'package:flutter/material.dart';
import 'Do.dart';

class DontsScreen extends StatefulWidget {
  final String categoryTitle;

  DontsScreen({required this.categoryTitle});

  @override
  _DontsScreenState createState() => _DontsScreenState();
}

class _DontsScreenState extends State<DontsScreen> {
  List<String> dontsList = [];
  int _currentIndex = 1;

  Future<void> loadDonts() async {
    final jsonString =
    await DefaultAssetBundle.of(context).loadString('assets/JasonFiles/precautions.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      dontsList = jsonData
          .where((item) =>
      item['category'] == widget.categoryTitle &&
          item['type'] == 'dont')
          .map<String>((item) => item['text'] as String)
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadDonts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Don'ts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: dontsList.length,
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
                    Icon(Icons.cancel, color: Colors.red, size: 40),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dontsList[index],
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
