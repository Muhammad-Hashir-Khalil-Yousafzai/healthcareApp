import 'package:flutter/material.dart';

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  double age = 30;
  double cholesterol = 180;
  double bloodPressure = 120;
  double bmi = 22;
  double heartRate = 70;
  bool isSmoker = false;
  bool hasDiabetes = false;
  bool hasFamilyHistory = false;
  bool exercisesRegularly = true;

  double? predictionPercentage;
  String riskCategory = '';
  Color loaderColor = Colors.green;

  double predictHeartAttackRisk({
    required double age,
    required double cholesterol,
    required double bloodPressure,
    required double bmi,
    required double heartRate,
    required bool isSmoker,
    required bool hasDiabetes,
    required bool hasFamilyHistory,
    required bool exercisesRegularly,
  }) {
    double riskScore = 0;

    riskScore += (age / 100) * 20;
    riskScore += (cholesterol / 300) * 20;
    riskScore += (bloodPressure / 200) * 20;
    riskScore += (bmi / 40) * 10;
    riskScore += (heartRate / 150) * 10;
    if (isSmoker) riskScore += 15;
    if (hasDiabetes) riskScore += 20;
    if (hasFamilyHistory) riskScore += 10;
    if (!exercisesRegularly) riskScore += 5;

    return riskScore.clamp(0, 100);
  }

  void determineRiskCategory(double percentage) {
    if (percentage <= 10) {
      riskCategory = 'No Risk';
      loaderColor = Colors.green;
    } else if (percentage <= 30) {
      riskCategory = 'Little Risk';
      loaderColor = Colors.yellow;
    } else if (percentage <= 50) {
      riskCategory = 'Medium Risk';
      loaderColor = Colors.orange;
    } else if (percentage <= 80) {
      riskCategory = 'High Risk';
      loaderColor = Colors.redAccent;
    } else {
      riskCategory = 'For Sure';
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
        title: Text('Heart Attack Prediction'),
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
                decoration: InputDecoration(labelText: 'Cholesterol Level (mg/dL)'),
                keyboardType: TextInputType.number,
                initialValue: cholesterol.toString(),
                onSaved: (value) => cholesterol = double.tryParse(value ?? '') ?? cholesterol,
                validator: (value) => value!.isEmpty ? 'Enter cholesterol level' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Blood Pressure (mmHg)'),
                keyboardType: TextInputType.number,
                initialValue: bloodPressure.toString(),
                onSaved: (value) => bloodPressure = double.tryParse(value ?? '') ?? bloodPressure,
                validator: (value) => value!.isEmpty ? 'Enter blood pressure' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'BMI (kg/m²)'),
                keyboardType: TextInputType.number,
                initialValue: bmi.toString(),
                onSaved: (value) => bmi = double.tryParse(value ?? '') ?? bmi,
                validator: (value) => value!.isEmpty ? 'Enter BMI' : null,
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
                      double result = predictHeartAttackRisk(
                        age: age,
                        cholesterol: cholesterol,
                        bloodPressure: bloodPressure,
                        bmi: bmi,
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
