import 'package:flutter/material.dart';
import 'workout.dart'; // Make sure this path is correct

class GymScreen extends StatelessWidget {
  final List<Map<String, String>> gymItems = [
    {'title': 'Shoulders', 'image': 'assets/images/shoulder.png'},
    {'title': 'Chest', 'image': 'assets/images/chest.png'},
    {'title': 'Biceps', 'image': 'assets/images/biceps.png'},
    {'title': 'Triceps', 'image': 'assets/images/triceps.png'},
    {'title': 'Core', 'image': 'assets/images/core.png'},
    {'title': 'Thighs', 'image': 'assets/images/thighs.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Gym Workouts',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: gymItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = gymItems[index];
            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutScreen(category: item['title']!),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      item['image']!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 10),
                    Text(
                      item['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
