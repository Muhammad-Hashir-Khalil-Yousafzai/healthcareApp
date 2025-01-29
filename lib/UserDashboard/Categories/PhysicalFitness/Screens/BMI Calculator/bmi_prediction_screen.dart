import 'package:flutter/material.dart';
import 'dart:math';

class BMICalculatorScreen extends StatefulWidget {
  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _isLoading = false;
  double? _bmi;
  Color _progressColor = Colors.deepPurple;
  String _bmiCategory = "";
  String _bmiInstruction = "";
  double _progressValue = 0.0;

  void calculateBMI() async {
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);

    if (weight == null || height == null || height <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Invalid Input"),
          content: Text("Please enter valid height and weight values."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            )
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _progressValue = 0.0;
    });

    await Future.delayed(Duration(seconds: 1));

    final double bmi = weight / pow(height / 100, 2);
    String category;
    String instruction;
    Color progressColor;
    double progressValue;

    if (bmi < 18.5) {
      category = "Underweight";
      instruction = "You should eat more nutritious food and maintain a healthy diet.";
      progressColor = Colors.blueGrey;
      progressValue = 0.3;
    } else if (bmi < 24.9) {
      category = "Healthy Weight";
      instruction = "Great job! Keep maintaining your healthy lifestyle.";
      progressColor = Colors.green;
      progressValue = 0.6;
    } else if (bmi < 29.9) {
      category = "Overweight";
      instruction = "Try to incorporate regular exercise and a balanced diet.";
      progressColor = Colors.orangeAccent;
      progressValue = 0.8;
    } else {
      category = "Obesity";
      instruction = "Consult a healthcare provider for personalized advice.";
      progressColor = Colors.redAccent;
      progressValue = 0.9;
    }

    setState(() {
      _isLoading = false;
      _bmi = bmi;
      _bmiCategory = category;
      _bmiInstruction = instruction;
      _progressColor = progressColor;
      _progressValue = progressValue;
    });
  }

  Widget _buildCircularProgress(String label, double percentage, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress Indicator Background
            SizedBox(
              height: 140,
              width: 140,
              child: CircularProgressIndicator(
                value: 1.0, // Full circle for background
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            // Animated Circular Progress Indicator with Text
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: percentage),
              duration: Duration(seconds: 3),
              builder: (context, value, child) {
                return SizedBox(
                  height: 140,
                  width: 140,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                );
              },
            ),
            // Percentage Text in the Center of the Loader
            Positioned(
              child: Text(
                _bmi != null ? _bmi!.toStringAsFixed(1) : '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI Predictor", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Calculate Your BMI",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Weight (kg)",
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Height (cm)",
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateBMI,
              child: Text("Calculate BMI", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            if (_isLoading || _bmi != null)
              Center(
                child: _buildCircularProgress(
                  _bmiCategory,
                  _isLoading ? _progressValue : _progressValue,
                  _progressColor,
                ),
              ),
            if (!_isLoading && _bmi != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _bmiInstruction,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.deepPurple),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
