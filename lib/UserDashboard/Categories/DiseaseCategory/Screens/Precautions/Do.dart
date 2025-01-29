import 'package:flutter/material.dart';
import 'Dont.dart';

class DosScreen extends StatefulWidget {
  @override
  _DosScreenState createState() => _DosScreenState();
}

class _DosScreenState extends State<DosScreen> {
  int _currentIndex = 0;

  final List<String> dosList = [
    "Do drink plenty of water.",
    "Do eat a balanced diet.",
    "Do get enough sleep.",
    "Do exercise regularly.",
    "Do practice good hygiene.",
    "Do take breaks from screen time.",
    "Do wear sunscreen.",
    "Do manage your stress.",
    "Do practice meditation or mindfulness.",
    "Do keep a positive mindset.",
    "Do stretch regularly.",
    "Do get regular health check-ups.",
    "Do wash your hands before eating.",
    "Do keep your environment clean.",
    "Do protect your mental health.",
    "Do avoid excessive alcohol consumption.",
    "Do maintain good posture.",
    "Do stay hydrated throughout the day.",
    "Do limit your intake of junk food.",
    "Do try to maintain a healthy weight."
  ];

  final List<Widget> _screens = [
    DosScreen(),
    DontsScreen(),
  ];

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
        backgroundColor: Colors.white,
        elevation: 6,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => _screens[index]),
            );
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Do's",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: "Don'ts",
          ),
        ],
      ),
    );
  }
}
