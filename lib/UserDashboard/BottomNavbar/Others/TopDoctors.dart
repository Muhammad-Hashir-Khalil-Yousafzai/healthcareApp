import 'package:flutter/material.dart';

class TopRatedDoctorsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> topDoctors = [
    {
      'name': 'Dr. Ayesha Khan',
      'specialty': 'Cardiologist',
      'rating': 4.9,
      'image': 'assets/images/doctor1.png',
    },
    {
      'name': 'Dr. Usman Qureshi',
      'specialty': 'Neurologist',
      'rating': 4.8,
      'image': 'assets/images/doctor2.png',
    },
    {
      'name': 'Dr. Sana Ali',
      'specialty': 'Dermatologist',
      'rating': 4.7,
      'image': 'assets/images/doctor3.png',
    },
    {
      'name': 'Dr. Imran Raza',
      'specialty': 'Pulmonologist',
      'rating': 4.7,
      'image': 'assets/images/doctor4.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Top Rated Doctors", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: topDoctors.length,
        padding: EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final doctor = topDoctors[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(doctor['image']),
              ),
              title: Text(doctor['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor['specialty']),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text('${doctor['rating']} / 5.0'),
                    ],
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.deepPurple),
              onTap: () {
                // Navigate to detailed doctor profile if needed
              },
            ),
          );
        },
      ),
    );
  }
}
