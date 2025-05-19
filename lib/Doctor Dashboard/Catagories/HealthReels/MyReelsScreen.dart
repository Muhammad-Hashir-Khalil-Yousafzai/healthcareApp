import 'package:flutter/material.dart';

class MyReelsScreen extends StatelessWidget {
  const MyReelsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('My Reels'),
      ),
      body: Center(
        child: Text(
          'No reels uploaded yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
