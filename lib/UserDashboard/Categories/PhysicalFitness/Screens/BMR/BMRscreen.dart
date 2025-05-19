import 'package:flutter/material.dart';
import 'dart:math';

class BMRScreen extends StatefulWidget {
  @override
  _BMRScreenState createState() => _BMRScreenState();
}

class _BMRScreenState extends State<BMRScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = 'Male';
  double? _bmr;
  String _bmrInstruction = "";
  Color _bmrColor = Colors.deepPurple;

  void calculateBMR() {
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);
    final int? age = int.tryParse(_ageController.text);

    if (weight == null || height == null || age == null || height <= 0 || age <= 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Invalid Input"),
          content: Text("Please enter valid weight, height, and age."),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK"))
          ],
        ),
      );
      return;
    }

    double bmr;
    if (_selectedGender == 'Male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    String instruction;
    Color color;

    if (bmr < 1300) {
      instruction = "Your BMR is low. Consider consulting a health expert for a tailored plan.";
      color = Colors.blueGrey;
    } else if (bmr < 1600) {
      instruction = "Moderate BMR. Maintain a healthy diet and regular exercise.";
      color = Colors.green;
    } else {
      instruction = "High BMR. Ensure your diet aligns with your energy needs.";
      color = Colors.deepPurple;
    }

    setState(() {
      _bmr = bmr;
      _bmrInstruction = instruction;
      _bmrColor = color;
    });
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        labelStyle: TextStyle(color: Colors.deepPurple),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(top: 30),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Your BMR",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _bmrColor),
            ),
            SizedBox(height: 12),
            Text(
              "${_bmr!.toStringAsFixed(0)} kcal/day",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _bmrColor),
            ),
            SizedBox(height: 16),
            Text(
              _bmrInstruction,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMR Calculator", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Calculate Your BMR",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: ['Male', 'Female'].map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) => setState(() => _selectedGender = value!),
              decoration: InputDecoration(
                labelText: "Gender",
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            _buildInputField(label: "Weight", controller: _weightController, suffix: "kg"),
            SizedBox(height: 16),
            _buildInputField(label: "Height", controller: _heightController, suffix: "cm"),
            SizedBox(height: 16),
            _buildInputField(label: "Age", controller: _ageController, suffix: "years"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateBMR,
              child: Text("Calculate BMR", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_bmr != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }
}
