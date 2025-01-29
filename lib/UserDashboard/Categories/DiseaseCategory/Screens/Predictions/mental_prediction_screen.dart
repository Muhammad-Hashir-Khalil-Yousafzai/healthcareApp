import 'package:flutter/material.dart';

class MentalHealthPredictionScreen extends StatefulWidget {
  @override
  _MentalHealthPredictionScreenState createState() => _MentalHealthPredictionScreenState();
}

class _MentalHealthPredictionScreenState extends State<MentalHealthPredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  double age = 25;
  double sleepHours = 6; // Average sleep per night in hours
  double screenTime = 4; // Daily screen time in hours
  int physicalActivity = 2; // Hours of exercise per week
  int socialInteraction = 3; // Hours of social interaction per week
  bool feelsStressed = false;
  bool feelsAnxious = false;
  bool experiencesMoodSwings = false;
  bool hasFamilyHistoryOfMentalHealthIssues = false;

  double? predictionPercentage;
  String riskCategory = '';
  Color loaderColor = Colors.green;

  double predictMentalHealthRisk({
    required double age,
    required double sleepHours,
    required double screenTime,
    required int physicalActivity,
    required int socialInteraction,
    required bool feelsStressed,
    required bool feelsAnxious,
    required bool experiencesMoodSwings,
    required bool hasFamilyHistoryOfMentalHealthIssues,
  }) {
    double riskScore = 0;

    // Basic factors affecting mental health
    riskScore += (8 - sleepHours) * 10; // Less sleep increases risk
    riskScore += screenTime * 5; // High screen time contributes to risk
    riskScore += (2 - physicalActivity) * 10; // Lack of exercise increases risk
    riskScore += (2 - socialInteraction) * 10; // Less social interaction increases risk

    if (feelsStressed) riskScore += 15;
    if (feelsAnxious) riskScore += 15;
    if (experiencesMoodSwings) riskScore += 20;
    if (hasFamilyHistoryOfMentalHealthIssues) riskScore += 10;

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
        title: Text('Mental Health Prediction'),
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
                decoration: InputDecoration(labelText: 'Average Sleep (hours/night)'),
                keyboardType: TextInputType.number,
                initialValue: sleepHours.toString(),
                onSaved: (value) => sleepHours = double.tryParse(value ?? '') ?? sleepHours,
                validator: (value) => value!.isEmpty ? 'Enter sleep hours' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Screen Time (hours/day)'),
                keyboardType: TextInputType.number,
                initialValue: screenTime.toString(),
                onSaved: (value) => screenTime = double.tryParse(value ?? '') ?? screenTime,
                validator: (value) => value!.isEmpty ? 'Enter screen time' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Physical Activity (hours/week)'),
                keyboardType: TextInputType.number,
                initialValue: physicalActivity.toString(),
                onSaved: (value) => physicalActivity = int.tryParse(value ?? '') ?? physicalActivity,
                validator: (value) => value!.isEmpty ? 'Enter physical activity hours' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Social Interaction (hours/week)'),
                keyboardType: TextInputType.number,
                initialValue: socialInteraction.toString(),
                onSaved: (value) => socialInteraction = int.tryParse(value ?? '') ?? socialInteraction,
                validator: (value) => value!.isEmpty ? 'Enter social interaction hours' : null,
              ),
              SwitchListTile(
                title: Text('Feeling Stressed'),
                value: feelsStressed,
                onChanged: (value) => setState(() => feelsStressed = value),
              ),
              SwitchListTile(
                title: Text('Feeling Anxious'),
                value: feelsAnxious,
                onChanged: (value) => setState(() => feelsAnxious = value),
              ),
              SwitchListTile(
                title: Text('Experiencing Mood Swings'),
                value: experiencesMoodSwings,
                onChanged: (value) => setState(() => experiencesMoodSwings = value),
              ),
              SwitchListTile(
                title: Text('Family History of Mental Health Issues'),
                value: hasFamilyHistoryOfMentalHealthIssues,
                onChanged: (value) => setState(() => hasFamilyHistoryOfMentalHealthIssues = value),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      double result = predictMentalHealthRisk(
                        age: age,
                        sleepHours: sleepHours,
                        screenTime: screenTime,
                        physicalActivity: physicalActivity,
                        socialInteraction: socialInteraction,
                        feelsStressed: feelsStressed,
                        feelsAnxious: feelsAnxious,
                        experiencesMoodSwings: experiencesMoodSwings,
                        hasFamilyHistoryOfMentalHealthIssues: hasFamilyHistoryOfMentalHealthIssues,
                      );
                      setState(() {
                        predictionPercentage = result;
                        determineRiskCategory(result);
                      });
                    }
                  },
                  child: Text(
                    'Predict',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
