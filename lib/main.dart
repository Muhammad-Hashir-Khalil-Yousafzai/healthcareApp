import 'package:firebase_core/firebase_core.dart';
import 'package:healthcare/UserDashboard/Login_Signup/authgate.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'consts.dart';

void main() async {
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );
  await Hive.initFlutter();
  await Hive.openBox('doctors_cache');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Must be correct for Web
  );
  runApp(const HealthcareApp());
}

class HealthcareApp extends StatelessWidget {
  const HealthcareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Authgate(),
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