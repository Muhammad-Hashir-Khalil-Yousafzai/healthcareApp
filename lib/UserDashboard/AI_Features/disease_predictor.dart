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
    "abdominal_pain", "abnormal_menstruation", "acidity", "acute_liver_failure",
    "altered_sensorium", "anxiety", "back_pain", "belly_pain", "blackheads",
    "bladder_discomfort", "blister", "blood_in_sputum", "bloody_stool",
    "blurred_and_distorted_vision", "breathlessness", "brittle_nails", "bruising",
    "burning_micturition", "chest_pain", "chills", "cold_hands_and_feets", "coma",
    "congestion", "constipation", "continuous_feel_of_urine", "continuous_sneezing",
    "cough", "cramps", "dark_urine", "dehydration", "depression", "diarrhoea",
    "dischromic_patches", "distention_of_abdomen", "dizziness", "drying_and_tingling_lips",
    "enlarged_thyroid", "excessive_hunger", "extra_marital_contacts", "family_history",
    "fast_heart_rate", "fatigue", "fluid_overload", "foul_smell_of_urine", "headache",
    "high_fever", "hip_joint_pain", "history_of_alcohol_consumption", "increased_appetite",
    "indigestion", "inflammatory_nails", "internal_itching", "irregular_sugar_level",
    "irritability", "irritation_in_anus", "joint_pain", "knee_pain", "lack_of_concentration",
    "lethargy", "loss_of_appetite", "loss_of_balance", "loss_of_smell", "malaise",
    "mild_fever", "mood_swings", "movement_stiffness", "mucoid_sputum", "muscle_pain",
    "muscle_wasting", "muscle_weakness", "nausea", "neck_pain", "nodal_skin_eruptions",
    "obesity", "pain_behind_the_eyes", "pain_during_bowel_movements", "pain_in_anal_region",
    "painful_walking", "palpitations", "passage_of_gases", "patches_in_throat", "phlegm",
    "polyuria", "prominent_veins_on_calf", "puffy_face_and_eyes", "pus_filled_pimples",
    "receiving_blood_transfusion", "receiving_unsterile_injections", "red_sore_around_nose",
    "red_spots_over_body", "redness_of_eyes", "restlessness", "runny_nose", "rusty_sputum",
    "scurring", "shivering", "silver_like_dusting", "sinus_pressure", "skin_peeling",
    "skin_rash", "slurred_speech", "small_dents_in_nails", "spinning_movements",
    "spotting_urination", "stiff_neck", "stomach_bleeding", "stomach_pain", "sunken_eyes",
    "sweating", "swelled_lymph_nodes", "swelling_joints", "swelling_of_stomach",
    "swollen_blood_vessels", "swollen_extremeties", "swollen_legs", "throat_irritation",
    "toxic_look_(typhos)", "ulcers_on_tongue", "unsteadiness", "visual_disturbances",
    "vomiting", "watering_from_eyes", "weakness_in_limbs", "weakness_of_one_body_side",
    "weight_gain", "weight_loss", "yellow_crust_ooze", "yellow_urine", "yellowing_of_eyes",
    "yellowish_skin", "itching"
  ];

  List<String> selectedSymptoms = [];

  bool isLoading = false;

  Future<void> predictDisease() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.100.23:5000/predict');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'symptoms': selectedSymptoms}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result.containsKey('prediction')) {
          final prediction = result['prediction'];
          _showResultDialog(prediction);
        } else {
          throw Exception("No prediction found in response");
        }
      } else {
        throw Exception('Failed to predict disease.');
      }
    } catch (e) {
      _showResultDialog("Error: ${e.toString()}");
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            'Predicted Disease',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 18,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildSymptomTile(String symptom) {
    return CheckboxListTile(
      title: Text(symptom),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Predictor'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: allSymptoms.map(buildSymptomTile).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white, // button text and icon color
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.search),
              label: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Predict Disease'),
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
