import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class WorkoutScreen extends StatefulWidget {
  final String category; // e.g., "chest", "shoulders"

  const WorkoutScreen({super.key, required this.category});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<dynamic> workoutList = [];

  @override
  void initState() {
    super.initState();
    loadWorkoutData();
  }

  Future<void> loadWorkoutData() async {
    final String jsonData = await rootBundle.loadString('assets/JasonFiles/workout.json');
    final Map<String, dynamic> data = json.decode(jsonData);

    setState(() {
      workoutList = data[widget.category.toLowerCase()] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: Text('${widget.category} Workouts'),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        elevation: 4,
      ),
      body: workoutList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: workoutList.length,
        itemBuilder: (context, index) {
          final workout = workoutList[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.deepPurple, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  workout['image_path'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                workout['workout_name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepPurple,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Reps: ${workout['reps']}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.open_in_new, color: Colors.deepPurple),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        backgroundColor: Colors.white,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 400),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout['workout_name'],
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    workout['image_path'],
                                    width: double.infinity,
                                    height: 190,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      workout['description'] ?? 'No description available.',
                                      style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.3),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    icon: Icon(Icons.play_circle_fill, size: 22,color: Colors.white,),
                                    label: Text(
                                      "Watch on YouTube",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    onPressed: () async {
                                      final url = workout['youtube_url'];
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),


            ),
          );
        },
      ),
    );
  }
}
