import 'package:flutter/material.dart';
import 'cause_symptoms_screen.dart';
import 'disease_symptoms_screen.dart';
import 'recovery_symptoms_screen.dart';

class SymptomsNavigationScreen extends StatefulWidget {
  @override
  _SymptomsNavigationScreenState createState() => _SymptomsNavigationScreenState();
}

class _SymptomsNavigationScreenState extends State<SymptomsNavigationScreen> {
  int _currentIndex = 1; // Default index set to 1 (Disease Symptoms)

  final List<Widget> _screens = [
    CauseSymptomsScreen(),
    DiseaseSymptomsScreen(),
    RecoverySymptomsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Cause',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Disease',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing), // Recovery icon
            label: 'Recovery',
          ),
        ],
      ),
    );
  }
}
