import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  List<String> allSymptoms = [
    "abdominal_pain",
    "abnormal_menstruation",
    "acidity",
    "acute_liver_failure",
    "altered_sensorium",
    "anxiety",
    "back_pain",
    "belly_pain",
    "blackheads",
    "bladder_discomfort",
    "blister",
    "blood_in_sputum",
    "bloody_stool",
    "blurred_and_distorted_vision",
    "breathlessness",
    "brittle_nails",
    "bruising",
    "burning_micturition",
    "chest_pain",
    "chills",
    "cold_hands_and_feets",
    "coma",
    "congestion",
    "constipation",
    "continuous_feel_of_urine",
    "continuous_sneezing",
    "cough",
    "cramps",
    "dark_urine",
    "dehydration",
    "depression",
    "diarrhoea",
    "dischromic _patches",
    "distention_of_abdomen",
    "dizziness",
    "drying_and_tingling_lips",
    "enlarged_thyroid",
    "excessive_hunger",
    "extra_marital_contacts",
    "family_history",
    "fast_heart_rate",
    "fatigue",
    "fluid_overload",
    "foul_smell_of urine",
    "headache",
    "high_fever",
    "hip_joint_pain",
    "history_of_alcohol_consumption",
    "increased_appetite",
    "indigestion",
    "inflammatory_nails",
    "internal_itching",
    "irregular_sugar_level",
    "irritability",
    "irritation_in_anus",
    "itching",
    "joint_pain",
    "knee_pain",
    "lack_of_concentration",
    "lethargy",
    "loss_of_appetite",
    "loss_of_balance",
    "loss_of_smell",
    "malaise",
    "mild_fever",
    "mood_swings",
    "movement_stiffness",
    "mucoid_sputum",
    "muscle_pain",
    "muscle_wasting",
    "muscle_weakness",
    "nausea",
    "neck_pain",
    "nodal_skin_eruptions",
    "obesity",
    "pain_behind_the_eyes",
    "pain_during_bowel_movements",
    "pain_in_anal_region",
    "painful_walking",
    "palpitations",
    "passage_of_gases",
    "patches_in_throat",
    "phlegm",
    "polyuria",
    "prominent_veins_on_calf",
    "puffy_face_and_eyes",
    "pus_filled_pimples",
    "receiving_blood_transfusion",
    "receiving_unsterile_injections",
    "red_sore_around_nose",
    "red_spots_over_body",
    "redness_of_eyes",
    "restlessness",
    "runny_nose",
    "rusty_sputum",
    "scurring",
    "shivering",
    "silver_like_dusting",
    "sinus_pressure",
    "skin_peeling",
    "skin_rash",
    "slurred_speech",
    "small_dents_in_nails",
    "spinning_movements",
    "spotting_ urination",
    "stiff_neck",
    "stomach_bleeding",
    "stomach_pain",
    "sunken_eyes",
    "sweating",
    "swelled_lymph_nodes",
    "swelling_joints",
    "swelling_of_stomach",
    "swollen_blood_vessels",
    "swollen_extremeties",
    "swollen_legs",
    "throat_irritation",
    "toxic_look_(typhos)",
    "ulcers_on_tongue",
    "unsteadiness",
    "visual_disturbances",
    "vomiting",
    "watering_from_eyes",
    "weakness_in_limbs",
    "weakness_of_one_body_side",
    "weight_gain",
    "weight_loss",
    "yellow_crust_ooze",
    "yellow_urine",
    "yellowing_of_eyes",
    "yellowish_skin"
  ];
  List<String> selectedSymptoms = [];
  List<String> filteredSymptoms = [];
  bool isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredSymptoms = allSymptoms;
  }

  void filterSymptoms(String query) {
    setState(() {
      searchQuery = query;
      filteredSymptoms = allSymptoms
          .where((symptom) =>
          symptom.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> predictDisease() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse('http://192.168.43.209:5000/predict');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'symptoms': selectedSymptoms}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result.containsKey('predicted_disease')) {
          final prediction = result['predicted_disease'];
          final confidence = result['confidence'];
          final topPredictions = result['top_predictions'];

          String message =
              'Most likely: $prediction\nConfidence: $confidence%\n\n';
          message += 'Top Predictions:\n';
          for (var pred in topPredictions) {
            message += '• ${pred["disease"]}: ${pred["probability"]}%\n';
          }

          _showResultDialog('Prediction Result', message);
        } else if (result.containsKey('error')) {
          _showResultDialog("Error", result['error']);
        } else {
          throw Exception("Invalid response format.");
        }
      } else {
        _showResultDialog("Server Error", "Status Code: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        _showResultDialog("Network Error", "No internet connection.");
      } else {
        _showResultDialog("Error", e.toString());
      }
    }

    setState(() => isLoading = false);
  }

  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.health_and_safety, color: Colors.deepPurple),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              children: [
                ...message.split('\n').map((line) {
                  if (line.trim() == "Top Predictions:") {
                    return const TextSpan(
                      text: "Top Predictions:\n",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    return TextSpan(text: "$line\n");
                  }
                }),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle, color: Colors.deepPurple),
                label: const Text(
                  'OK',
                  style: TextStyle(color: Colors.deepPurple),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSymptomTile(String symptom) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: CheckboxListTile(
        title: Text(
          symptom.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        value: selectedSymptoms.contains(symptom),
        onChanged: (bool? selected) {
          setState(() {
            if (selected == true) {
              selectedSymptoms.add(symptom);
            } else {
              selectedSymptoms.remove(symptom);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Predictor'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: filterSymptoms,
              decoration: InputDecoration(
                hintText: 'Search symptoms...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSymptoms.length,
              itemBuilder: (context, index) =>
                  buildSymptomTile(filteredSymptoms[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSymptoms.isEmpty || isLoading
                    ? Colors.grey
                    : Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.analytics),
              label: Text(
                isLoading ? 'Predicting...' : 'Predict Disease',
                style: const TextStyle(fontSize: 16),
              ),
              onPressed: selectedSymptoms.isEmpty || isLoading
                  ? null
                  : predictDisease,
            ),
          ),
        ],
      ),
    );
  }
}
