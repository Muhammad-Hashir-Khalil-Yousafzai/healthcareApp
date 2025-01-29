import 'package:flutter/material.dart';

class LungsPredictionScreen extends StatefulWidget {
  @override
  _LungsPredictionScreenState createState() => _LungsPredictionScreenState();
}

class _LungsPredictionScreenState extends State<LungsPredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  double age = 30;
  double weight = 70; // Weight in kg
  double height = 170; // Height in cm
  double smokingDuration = 5; // Duration of smoking in years
  double smokingQuantity = 10; // Packs of cigarettes per day
  double coughDuration = 3; // Cough duration in months
  bool isExposedToPollution = false;
  bool hasChronicCough = false;
  bool experiencesShortnessOfBreath = false;
  bool hasFamilyHistoryOfLungDisease = false;

  double? predictionPercentage;
  String riskCategory = '';
  Color loaderColor = Colors.green;

  double predictLungDiseaseRisk({
    required double age,
    required double weight,
    required double height,
    required double smokingDuration,
    required double smokingQuantity,
    required double coughDuration,
    required bool isExposedToPollution,
    required bool hasChronicCough,
    required bool experiencesShortnessOfBreath,
    required bool hasFamilyHistoryOfLungDisease,
  }) {
    double riskScore = 0;

    // Basic calculations for weight and height (BMI)
    double calculatedBmi = weight / ((height / 100) * (height / 100));

    // Risk factors based on smoking, cough, pollution exposure, etc.
    riskScore += (age / 100) * 10;
    riskScore += (smokingDuration * smokingQuantity) / 100;
    riskScore += (coughDuration / 6) * 20; // Prolonged cough increases risk
    riskScore += (calculatedBmi / 40) * 10;
    if (isExposedToPollution) riskScore += 10;
    if (hasChronicCough) riskScore += 15;
    if (experiencesShortnessOfBreath) riskScore += 15;
    if (hasFamilyHistoryOfLungDisease) riskScore += 20;

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
        title: Text('Lung Disease Prediction'),
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
                decoration: InputDecoration(labelText: 'Smoking Duration (years)'),
                keyboardType: TextInputType.number,
                initialValue: smokingDuration.toString(),
                onSaved: (value) => smokingDuration = double.tryParse(value ?? '') ?? smokingDuration,
                validator: (value) => value!.isEmpty ? 'Enter smoking duration' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cigarettes per day (packs)'),
                keyboardType: TextInputType.number,
                initialValue: smokingQuantity.toString(),
                onSaved: (value) => smokingQuantity = double.tryParse(value ?? '') ?? smokingQuantity,
                validator: (value) => value!.isEmpty ? 'Enter quantity of cigarettes smoked' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cough Duration (months)'),
                keyboardType: TextInputType.number,
                initialValue: coughDuration.toString(),
                onSaved: (value) => coughDuration = double.tryParse(value ?? '') ?? coughDuration,
                validator: (value) => value!.isEmpty ? 'Enter cough duration' : null,
              ),
              SwitchListTile(
                title: Text('Exposed to Air Pollution'),
                value: isExposedToPollution,
                onChanged: (value) => setState(() => isExposedToPollution = value),
              ),
              SwitchListTile(
                title: Text('Chronic Cough'),
                value: hasChronicCough,
                onChanged: (value) => setState(() => hasChronicCough = value),
              ),
              SwitchListTile(
                title: Text('Shortness of Breath'),
                value: experiencesShortnessOfBreath,
                onChanged: (value) => setState(() => experiencesShortnessOfBreath = value),
              ),
              SwitchListTile(
                title: Text('Family History of Lung Disease'),
                value: hasFamilyHistoryOfLungDisease,
                onChanged: (value) => setState(() => hasFamilyHistoryOfLungDisease = value),
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
                      double result = predictLungDiseaseRisk(
                        age: age,
                        weight: weight,
                        height: height,
                        smokingDuration: smokingDuration,
                        smokingQuantity: smokingQuantity,
                        coughDuration: coughDuration,
                        isExposedToPollution: isExposedToPollution,
                        hasChronicCough: hasChronicCough,
                        experiencesShortnessOfBreath: experiencesShortnessOfBreath,
                        hasFamilyHistoryOfLungDisease: hasFamilyHistoryOfLungDisease,
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
