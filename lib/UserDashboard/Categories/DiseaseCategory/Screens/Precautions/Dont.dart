import 'package:flutter/material.dart';
import 'Do.dart';

class DontsScreen extends StatefulWidget {
  @override
  _DontsScreenState createState() => _DontsScreenState();
}

class _DontsScreenState extends State<DontsScreen> {
  int _currentIndex = 1;

  final List<String> dontsList = [
    "Don't skip meals.",
    "Don't ignore mental health.",
    "Don't overeat.",
    "Don't stay up too late.",
    "Don't overwork yourself.",
    "Don't smoke.",
    "Don't drink sugary drinks excessively.",
    "Don't neglect physical activity.",
    "Don't skip your exercise routine.",
    "Don't take stress lightly.",
    "Don't ignore your doctor's advice.",
    "Don't binge-watch TV for long hours.",
    "Don't ignore your body’s signals.",
    "Don't neglect your hygiene.",
    "Don't drink alcohol excessively.",
    "Don't stay sedentary for long periods.",
    "Don't avoid regular check-ups.",
    "Don't spend too much time on your phone.",
    "Don't be too hard on yourself.",
    "Don't skip your vaccinations."
  ];

  final List<Widget> _screens = [
    DosScreen(),
    DontsScreen(),
  ];

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
