import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadDoctorProfileScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Updated doctor profile JSON data with removed fields
  final Map<String, dynamic> _doctorData = {
    'basicInfo': {
      'name': 'Dr. Sarah Johnson',
      'email': 'dr.sarah@example.com',
    },
    'professionalInfo': {
      'specialty': 'Cardiology',
      'qualifications': ['MD', 'Cardiology Board Certified'],
      'experience': 12,
      'bio':
          'Specializing in interventional cardiology with 12 years of experience in treating complex heart conditions.',
      'consultationFee': 75,
    },
    'contactInfo': {
      'phone': '+15551234567',
      'clinicAddress': '456 Heart Avenue, Medical City, NY 10001',
    },
    'availability': {
      'workingDays': ['Monday', 'Wednesday', 'Friday', 'Saturday'],
      'workingHours': {
        'start': '08:00',
        'end': '18:00',
      },
    },
    'status': false,
    'createdAt': FieldValue.serverTimestamp(),
  };

  UploadDoctorProfileScreen({super.key});

  Future<void> _uploadDoctorProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('doctors').doc(userId).set(_doctorData);
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Doctor profile uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Error uploading profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Doctor Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'One-Click Doctor Profile Upload',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
                'This will upload a complete doctor profile to Firestore'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _uploadDoctorProfile,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'UPLOAD DOCTOR PROFILE',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
