import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyGuidanceScreen extends StatelessWidget {
   EmergencyGuidanceScreen({super.key});

  void _callNumber(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not call $number';
    }
  }

  final List<Map<String, dynamic>> _emergencyData = [
    {
      "title": "Heart Attack",
      "steps": [
        "Call emergency immediately (e.g., 1122).",
        "Make the person sit, keep them calm and loosen tight clothes.",
        "If conscious, give aspirin if available.",
        "Start CPR if the person becomes unconscious and stops breathing."
      ],
      "icon": Icons.favorite,
    },
    {
      "title": "Severe Bleeding",
      "steps": [
        "Apply direct pressure on the wound using clean cloth.",
        "Do not remove objects embedded in the wound.",
        "Elevate the injured part if possible.",
        "Call emergency immediately."
      ],
      "icon": Icons.healing,
    },
    {
      "title": "Stroke",
      "steps": [
        "Use the FAST test (Face, Arms, Speech, Time).",
        "If any signs are positive, call emergency immediately.",
        "Keep the patient in a comfortable position.",
        "Do not give anything to eat or drink."
      ],
      "icon": Icons.grain,
    },
    {
      "title": "Burn Injuries",
      "steps": [
        "Cool the burn under cool running water for 20 minutes.",
        "Do not apply oils or creams.",
        "Cover with clean, non-fluffy cloth or film.",
        "Seek medical help if burn is severe or involves face/hands/genitals."
      ],
      "icon": Icons.local_fire_department,
    },
    {
      "title": "Choking",
      "steps": [
        "Ask if the person can speak or cough.",
        "Perform 5 back blows followed by 5 abdominal thrusts.",
        "Repeat until the object is cleared or help arrives.",
        "Call emergency if unresponsive."
      ],
      "icon": Icons.warning,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Guidance', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_in_talk, color: Colors.deepPurple, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "For emergencies, call Rescue 1122 or your nearest emergency number.",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.call, color: Colors.green),
                  onPressed: () => _callNumber("1122"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._emergencyData.map((emergency) => ExpansionTile(
            leading: Icon(emergency["icon"], color: Colors.deepPurple),
            title: Text(
              emergency["title"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: List.generate(emergency["steps"].length, (index) {
              return ListTile(
                leading: const Icon(Icons.arrow_right, color: Colors.grey),
                title: Text(emergency["steps"][index]),
              );
            }),
          )),
        ],
      ),
    );
  }
}
