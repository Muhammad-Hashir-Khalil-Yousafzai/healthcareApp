import 'package:flutter/material.dart';
import 'cause_symptoms_screen.dart';
import 'disease_symptoms_screen.dart';
import 'recovery_symptoms_screen.dart';

class SymptomsNavigationScreen extends StatefulWidget {
  final String categoryTitle;

  const SymptomsNavigationScreen({super.key, required this.categoryTitle});

  @override
  _SymptomsNavigationScreenState createState() => _SymptomsNavigationScreenState();
}

class _SymptomsNavigationScreenState extends State<SymptomsNavigationScreen> {
  int _currentIndex = 1; // Default index set to 1 (Disease Symptoms)

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      CauseSymptomsScreen(categoryTitle: widget.categoryTitle),
      DiseaseSymptomsScreen(categoryTitle: widget.categoryTitle),
      RecoverySymptomsScreen(categoryTitle: widget.categoryTitle),
    ];

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Cause',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Disease',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing),
            label: 'Recovery',
          ),
        ],
      ),
    );
  }
}
