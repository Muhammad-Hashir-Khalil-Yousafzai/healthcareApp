import 'package:flutter/material.dart';
import 'package:healthcare/UserDashboard/Home/Home.dart';
import '../AI_Features/chatbot.dart';
import '../AI_Features/disease_predictor.dart';
import 'Others/HealthBot.dart';
import 'message.dart';
import 'Others.dart';

class AiFeaturesScreen extends StatefulWidget {
  const AiFeaturesScreen({super.key});

  @override
  _AiFeaturesScreenState createState() => _AiFeaturesScreenState();
}

class _AiFeaturesScreenState extends State<AiFeaturesScreen> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MessageScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OtherScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final List<Map<String, String>> aiFeatures = [
    {
      'title': 'AI Health Consultant',
      'subtitle': 'Ask health-related queries in natural language.',
      'image': 'assets/images/ai_consultant.png'
    },
    {
      'title': 'General Disease Predictor',
      'subtitle': 'Predict disease based on symptoms.',
      'image': 'assets/images/disease_predictor.png'
    },
    {
      'title': 'FAQs ChatBot',
      'subtitle': 'Get instant answers to common health questions.',
      'image': 'assets/images/FAQ.png'
    },
  ];

  Widget _buildAIFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: aiFeatures.map((feature) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 80,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset(
                  feature['image']!,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  feature['title']!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                onTap: () {
                  if (feature['title'] == 'AI Health Consultant') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatBotScreen()),
                    );
                  } else if (feature['title'] == 'General Disease Predictor') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PredictorScreen()),
                    );
                  } else if (feature['title'] == 'FAQs ChatBot') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HealthBotScreen()),
                    );
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Features', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: _buildAIFeaturesSection(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_moon_rounded), label: 'Others'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI Features'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
