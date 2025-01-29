import 'package:flutter/material.dart';

class DiabetesPredictionScreen extends StatefulWidget {
  @override
  _DiabetesPredictionScreenState createState() => _DiabetesPredictionScreenState();
}

class _DiabetesPredictionScreenState extends State<DiabetesPredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  double age = 30;
  double weight = 70; // Weight in kg
  double height = 170; // Height in cm
  double bloodSugarLevel = 100; // Blood Sugar Level (mg/dL)
  double cholesterolLevel = 180; // Cholesterol Level (mg/dL)
  double bmi = 25; // Body Mass Index
  double familyHistoryRisk = 0; // Family History Risk (0 or 1)
  bool isSmoker = false;
  bool hasHypertension = false;
  bool exercisesRegularly = true;

  double? predictionPercentage;
  String riskCategory = '';
  Color loaderColor = Colors.green;

  double predictDiabetesRisk({
    required double age,
    required double weight,
    required double height,
    required double bloodSugarLevel,
    required double cholesterolLevel,
    required double bmi,
    required double familyHistoryRisk,
    required bool isSmoker,
    required bool hasHypertension,
    required bool exercisesRegularly,
  }) {
    double riskScore = 0;

    // BMI calculation
    double calculatedBmi = weight / ((height / 100) * (height / 100));

    riskScore += (age / 100) * 10;
    riskScore += (bloodSugarLevel / 200) * 20;
    riskScore += (cholesterolLevel / 300) * 15;
    riskScore += (calculatedBmi / 40) * 10;
    riskScore += (familyHistoryRisk) * 20;
    if (isSmoker) riskScore += 10;
    if (hasHypertension) riskScore += 15;
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
        title: Text('Diabetes Prediction'),
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
                decoration: InputDecoration(labelText: 'Blood Sugar Level (mg/dL)'),
                keyboardType: TextInputType.number,
                initialValue: bloodSugarLevel.toString(),
                onSaved: (value) => bloodSugarLevel = double.tryParse(value ?? '') ?? bloodSugarLevel,
                validator: (value) => value!.isEmpty ? 'Enter blood sugar level' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cholesterol Level (mg/dL)'),
                keyboardType: TextInputType.number,
                initialValue: cholesterolLevel.toString(),
                onSaved: (value) => cholesterolLevel = double.tryParse(value ?? '') ?? cholesterolLevel,
                validator: (value) => value!.isEmpty ? 'Enter cholesterol level' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'BMI (Body Mass Index)'),
                keyboardType: TextInputType.number,
                initialValue: bmi.toString(),
                onSaved: (value) => bmi = double.tryParse(value ?? '') ?? bmi,
                validator: (value) => value!.isEmpty ? 'Enter BMI' : null,
              ),
              SwitchListTile(
                title: Text('Family History of Diabetes'),
                value: familyHistoryRisk == 1,
                onChanged: (value) => setState(() => familyHistoryRisk = value ? 1 : 0),
              ),
              SwitchListTile(
                title: Text('Smoker'),
                value: isSmoker,
                onChanged: (value) => setState(() => isSmoker = value),
              ),
              SwitchListTile(
                title: Text('Hypertension (High Blood Pressure)'),
                value: hasHypertension,
                onChanged: (value) => setState(() => hasHypertension = value),
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
                      double result = predictDiabetesRisk(
                        age: age,
                        weight: weight,
                        height: height,
                        bloodSugarLevel: bloodSugarLevel,
                        cholesterolLevel: cholesterolLevel,
                        bmi: bmi,
                        familyHistoryRisk: familyHistoryRisk,
                        isSmoker: isSmoker,
                        hasHypertension: hasHypertension,
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
