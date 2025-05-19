import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare/Doctor%20Dashboard/Home/dr_home.dart';
import 'package:healthcare/UserDashboard/Home/home.dart';

import 'login_screen.dart';

class Authgate extends StatefulWidget {
  const Authgate({super.key});

  @override
  _AuthgateState createState() => _AuthgateState();
}

class _AuthgateState extends State<Authgate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => checkLoginStatus());
  }

  Future<void> checkLoginStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('Current User: $user');

      if (user == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role'] ?? 'patient';
          print('User role: $role');

          if (!mounted) return;
          if (role == 'doctor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DrHome()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          }
        } else {
          print('User doc not found');
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      }
    } catch (e) {
      print('Error during auth check: $e');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
