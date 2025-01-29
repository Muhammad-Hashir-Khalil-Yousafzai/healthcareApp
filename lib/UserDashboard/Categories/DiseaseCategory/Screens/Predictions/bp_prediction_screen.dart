import 'package:flutter/material.dart';

class BPPredictionScreen extends StatefulWidget {
  @override
  _BPPredictionScreenState createState() => _BPPredictionScreenState();
}

class _BPPredictionScreenState extends State<BPPredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  double age = 30;
  double weight = 70; // Weight in kg
  double height = 170; // Height in cm
  double systolicBP = 120; // Systolic BP in mmHg
  double diastolicBP = 80; // Diastolic BP in mmHg
  double cholesterol = 180;
  double heartRate = 70;
  bool isSmoker = false;
  bool hasDiabetes = false;
  bool hasFamilyHistory = false;
  bool exercisesRegularly = true;

  double? predictionPercentage;
  String riskCategory = '';
  Color loaderColor = Colors.green;

  double predictBPRisk({
    required double age,
    required double weight,
    required double height,
    required double systolicBP,
    required double diastolicBP,
    required double cholesterol,
    required double heartRate,
    required bool isSmoker,
    required bool hasDiabetes,
    required bool hasFamilyHistory,
    required bool exercisesRegularly,
  }) {
    double riskScore = 0;

    // BMI calculation
    double bmi = weight / ((height / 100) * (height / 100));

    riskScore += (age / 100) * 10;
    riskScore += (systolicBP / 200) * 25;
    riskScore += (diastolicBP / 120) * 20;
    riskScore += (cholesterol / 300) * 15;
    riskScore += (heartRate / 150) * 10;
    riskScore += (bmi / 40) * 10;
    if (isSmoker) riskScore += 15;
    if (hasDiabetes) riskScore += 15;
    if (hasFamilyHistory) riskScore += 10;
    if (!exercisesRegularly) riskScore += 5;

    return riskScore.clamp(0, 100);
  }

  void determineRiskCategory(double percentage) {
    if (percentage <= 10) {
      riskCategory = 'Normal';
      loaderColor = Colors.green;
    } else if (percentage <= 30) {
      riskCategory = 'Low Risk';
      loaderColor = Colors.yellow;
    } else if (percentage <= 50) {
      riskCategory = 'Moderate Risk';
      loaderColor = Colors.orange;
    } else if (percentage <= 80) {
      riskCategory = 'High Risk';
      loaderColor = Colors.redAccent;
    } else {
      riskCategory = 'Very High Risk';
      loaderColor = Colors.red;
    }
  }

  Widget buildAnimatedLoader(double percentage, String label, Color color) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percentage),
          duration: Duration(seconds: 2),
          builder: (context, value, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: value / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 16),
        Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Blood Pressure Prediction'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Age (years)'),
                keyboardType: TextInputType.number,
                initialValue: age.toString(),
                onSaved: (value) => age = double.tryParse(value ?? '') ?? age,
                validator: (value) => value!.isEmpty ? 'Enter age' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                initialValue: weight.toString(),
                onSaved: (value) => weight = double.tryParse(value ?? '') ?? weight,
                validator: (value) => value!.isEmpty ? 'Enter weight' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                initialValue: height.toString(),
                onSaved: (value) => height = double.tryParse(value ?? '') ?? height,
                validator: (value) => value!.isEmpty ? 'Enter height' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Systolic BP (mmHg)'),
                keyboardType: TextInputType.number,
                initialValue: systolicBP.toString(),
                onSaved: (value) => systolicBP = double.tryParse(value ?? '') ?? systolicBP,
                validator: (value) => value!.isEmpty ? 'Enter systolic BP' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Diastolic BP (mmHg)'),
                keyboardType: TextInputType.number,
                initialValue: diastolicBP.toString(),
                onSaved: (value) => diastolicBP = double.tryParse(value ?? '') ?? diastolicBP,
                validator: (value) => value!.isEmpty ? 'Enter diastolic BP' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cholesterol Level (mg/dL)'),
                keyboardType: TextInputType.number,
                initialValue: cholesterol.toString(),
                onSaved: (value) => cholesterol = double.tryParse(value ?? '') ?? cholesterol,
                validator: (value) => value!.isEmpty ? 'Enter cholesterol level' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Resting Heart Rate (bpm)'),
                keyboardType: TextInputType.number,
                initialValue: heartRate.toString(),
                onSaved: (value) => heartRate = double.tryParse(value ?? '') ?? heartRate,
                validator: (value) => value!.isEmpty ? 'Enter heart rate' : null,
              ),
              SwitchListTile(
                title: Text('Smoker'),
                value: isSmoker,
                onChanged: (value) => setState(() => isSmoker = value),
              ),
              SwitchListTile(
                title: Text('Diabetes'),
                value: hasDiabetes,
                onChanged: (value) => setState(() => hasDiabetes = value),
              ),
              SwitchListTile(
                title: Text('Family History of Heart Disease'),
                value: hasFamilyHistory,
                onChanged: (value) => setState(() => hasFamilyHistory = value),
              ),
              SwitchListTile(
                title: Text('Exercises Regularly'),
                value: exercisesRegularly,
                onChanged: (value) => setState(() => exercisesRegularly = value),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // Button width is 80% of screen width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12), // Reduced height
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      double result = predictBPRisk(
                        age: age,
                        weight: weight,
                        height: height,
                        systolicBP: systolicBP,
                        diastolicBP: diastolicBP,
                        cholesterol: cholesterol,
                        heartRate: heartRate,
                        isSmoker: isSmoker,
                        hasDiabetes: hasDiabetes,
                        hasFamilyHistory: hasFamilyHistory,
                        exercisesRegularly: exercisesRegularly,
                      );
                      setState(() {
                        predictionPercentage = result;
                        determineRiskCategory(result);
                      });
                    }
                  },
                  child: Text(
                    'Predict',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color set to white
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              if (predictionPercentage != null)
                buildAnimatedLoader(predictionPercentage!, riskCategory, loaderColor),
            ],
          ),
        ),
      ),
    );
  }
}
