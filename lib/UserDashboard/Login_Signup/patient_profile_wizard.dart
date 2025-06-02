// lib/UserDashboard/Login_Signup/patient_profile_wizard.dart
import 'package:flutter/material.dart';

class PatientProfileWizard extends StatelessWidget {
  final String userId;
  final String name;
  final String email;

  const PatientProfileWizard({
    Key? key,
    required this.userId,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Patient Profile')),
      body: Center(
        child: Text('Welcome $name! Please complete your patient profile.'),
      ),
    );
  }
}
