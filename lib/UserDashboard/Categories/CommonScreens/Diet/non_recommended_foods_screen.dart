import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'recommended_foods_screen.dart';

class NonRecommendedFoodsScreen extends StatefulWidget {
  final String category;

  NonRecommendedFoodsScreen({required this.category});

  @override
  _NonRecommendedFoodsScreenState createState() => _NonRecommendedFoodsScreenState();
}

class _NonRecommendedFoodsScreenState extends State<NonRecommendedFoodsScreen> {
  int _currentIndex = 1;
  bool isLoading = true;
  List<Map<String, dynamic>> nonRecommendedFoods = [];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RecommendedFoodsScreen(category: widget.category),
      NonRecommendedFoodsScreen(category: widget.category),
    ];
    loadNonRecommendedFoods();
  }

  Future<void> loadNonRecommendedFoods() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/JasonFiles/diet.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      setState(() {
        nonRecommendedFoods = jsonData
            .where((item) =>
        item['type'] == 'non-recommended' &&
            (item['category']?.toLowerCase() == widget.category.toLowerCase()))
            .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading JSON: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load diet data")),
      );
    }
  }

  Widget buildFoodCard(Map<String, dynamic> food) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            food['item'] ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 8),
          buildRow('Quantity:', food['quantity']),
          buildRow('Harmful Time:', food['suitable_time']),
          buildRow('Contents:', food['vitamins_minerals']),
          SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reason:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  food['reason'] ?? '',
                  textAlign: TextAlign.justify,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget buildRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Flexible(
          child: Text(
            value ?? '',
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Non-Recommended Foods', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : nonRecommendedFoods.isEmpty
          ? Center(child: Text("No non-recommended foods available."))
          : ListView.builder(
        itemCount: nonRecommendedFoods.length,
        itemBuilder: (context, index) {
          return buildFoodCard(nonRecommendedFoods[index]);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index != _currentIndex) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => _screens[index]),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Recommended',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: 'Non-Recommended',
          ),
        ],
      ),
    );
  }
}
