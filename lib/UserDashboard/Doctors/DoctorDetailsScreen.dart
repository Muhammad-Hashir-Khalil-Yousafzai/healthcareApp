import 'package:flutter/material.dart';
import 'appointment_calendar.dart';


class DoctorDetailsScreen extends StatelessWidget {
  final String doctorName;
  final String doctorSpeciality;
  final String doctorImage;

  // Sample percentage values (you can modify these to dynamically fetch from a database or API)
  final double patientSatisfaction = 80.0;  // Example value
  final double goodReviews = 85.0;  // Example value
  final double totalScore = 88.0;  // Example value

  const DoctorDetailsScreen({
    required this.doctorName,
    required this.doctorSpeciality,
    required this.doctorImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctorName ,style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          // Doctor Image
          Positioned.fill(
            child: Image.asset(
              doctorImage,
              fit: BoxFit.cover,
            ),
          ),
          // Scrollable content over the image
          SingleChildScrollView(
            child: Column(
              children: [
                // Space for the fixed image (to allow scrolling)
                SizedBox(height: 310),  // Same height as the image

                // Doctor Info with rounded corners and full width
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    width: double.infinity, // Full width
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, // White background
                      borderRadius: BorderRadius.circular(16), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 4,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctorSpeciality,
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),

                        const SizedBox(height: 16),

                        // Circular Progress Indicators for Satisfaction, Reviews, and Total Score
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCircularProgress('Satisfaction', patientSatisfaction),
                            _buildCircularProgress('GoodReviews', goodReviews),
                            _buildCircularProgress('TotalScore', totalScore),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'Dr. $doctorName is a highly skilled $doctorSpeciality with years of experience. You can book an appointment with them for expert medical advice.',
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentCalendar(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Button color changed to white
                            side: BorderSide(color: Colors.deepPurple, width: 2), // Border color to deep purple
                          ),
                          child: const Text(
                            'Book Appointment',
                            style: TextStyle(
                              color: Colors.deepPurple, // Text color changed to deep purple
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fixed information floating over the image
        ],
      ),
    );
  }

  // Method to build circular progress indicators with animation
  Widget _buildCircularProgress(String label, double percentage) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress Indicator Background
            SizedBox(
              height: 70,
              width: 70,
              child: CircularProgressIndicator(
                value: 1.0, // Full circle for background
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            // Animated Circular Progress Indicator with Text
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: percentage / 100),
              duration: Duration(seconds: 2),
              builder: (context, value, child) {
                return SizedBox(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                );
              },
            ),
            // Percentage Text in the Center of the Loader
            Positioned(
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

