import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/UserDashboard/Login_Signup/wrapper.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:healthcare/UserDashboard/Home/home.dart';
import 'consts.dart';

void main() async {
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HealthcareApp());
}

class HealthcareApp extends StatelessWidget {
  const HealthcareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple, // Deep purple background color
          titleTextStyle:
              TextStyle(color: Colors.white, fontSize: 22), // White text color
          iconTheme: IconThemeData(color: Colors.white), // White icons
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
