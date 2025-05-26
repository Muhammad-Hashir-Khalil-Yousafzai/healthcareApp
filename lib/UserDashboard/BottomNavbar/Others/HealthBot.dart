import 'package:flutter/material.dart';

class HealthBotScreen extends StatefulWidget {
  const HealthBotScreen({super.key});

  @override
  State<HealthBotScreen> createState() => _HealthBotScreenState();
}

class _HealthBotScreenState extends State<HealthBotScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Hi there! I'm trained on the most frequently asked health questions. You can try asking something like:",
      "isUser": false
    }
  ];

  final List<String> _suggestedQuestions = [
    "What are the symptoms of COVID-19?",
    "How to lower high blood pressure?",
    "What’s the normal BMI range?",
    "How to manage diabetes naturally?",
    "What are signs of depression?",
    "Best remedies for cold and cough?",
    "Is a fever of 101 dangerous?",
    "What causes chest pain?",
    "When to see a doctor for back pain?",
    "How much water should I drink daily?",
    "What are common allergy symptoms?",
    "How to boost immunity?",
    "Is walking enough for fitness?",
    "How to lose weight fast?",
    "Why am I always tired?",
    "What causes hair loss?",
    "How to sleep better at night?",
    "Can stress cause headaches?",
    "What is a healthy diet?",
    "How to control cholesterol?",
    "Why do I get stomach aches?",
    "What are signs of a stroke?",
    "How do I check for dehydration?",
    "What is anxiety?",
    "How much sugar is too much?",
    "Is intermittent fasting safe?",
    "Can I treat a sprain at home?",
    "Are vitamins necessary daily?",
    "How to prevent the flu?",
    "What are side effects of antibiotics?",
    "How to deal with burnout?",
    "Can diet affect mental health?",
    "What’s the best exercise for heart health?",
    "Why do I feel dizzy?",
    "How to reduce bloating?",
    "What’s a healthy heart rate?",
    "Why do I get frequent colds?",
    "Can lack of sleep cause weight gain?",
    "How do I deal with anxiety attacks?",
    "Is it okay to skip breakfast?",
    "How to treat mild COVID at home?",
    "How can I strengthen my lungs?",
    "What are the types of diabetes?",
    "How to cure sore throat quickly?",
    "What causes skin rashes?",
    "Can hydration help with headaches?",
    "How do I manage seasonal allergies?",
    "What is PCOS?",
    "Can exercise improve mental health?",
    "When should I get a health checkup?"
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"text": message, "isUser": true});
    });

    _controller.clear();
    _autoScroll();

    Future.delayed(const Duration(milliseconds: 500), () {
      String botReply = _generateBotReply(message);
      setState(() {
        _messages.add({"text": botReply, "isUser": false});
      });
      _autoScroll();
    });
  }

  String _generateBotReply(String msg) {
    msg = msg.toLowerCase();

    if (msg.contains("covid")) return "COVID-19 symptoms include fever, cough, and fatigue. Isolate, wear a mask, and consult a doctor.";
    if (msg.contains("blood pressure")) return "To lower high blood pressure, reduce salt intake, exercise regularly, manage stress, and follow medications.";
    if (msg.contains("bmi")) return "Normal BMI range is 18.5–24.9. Calculate BMI = weight(kg) / [height(m)]².";
    if (msg.contains("diabetes")) return "To manage diabetes naturally: exercise, follow a low-carb diet, and reduce sugar intake.";
    if (msg.contains("depression")) return "Signs of depression include persistent sadness, fatigue, loss of interest, and sleep issues.";
    if (msg.contains("cold") || msg.contains("cough")) return "Stay warm, hydrated, and rest. Try honey, ginger tea, and steam inhalation.";
    if (msg.contains("fever")) return "101°F is mild. Monitor symptoms, hydrate, and rest. Consult a doctor if it persists.";
    if (msg.contains("chest pain")) return "Chest pain can be serious. It may indicate heart issues. Seek immediate medical help.";
    if (msg.contains("back pain")) return "See a doctor if back pain lasts over a week or causes numbness or weakness.";
    if (msg.contains("water")) return "Adults should drink about 2.7–3.7 liters of water daily. Adjust for activity and climate.";
    if (msg.contains("allergy")) return "Common symptoms: sneezing, runny nose, itchy eyes, rash. Avoid triggers and take antihistamines.";
    if (msg.contains("immunity")) return "Boost immunity with a healthy diet, regular exercise, adequate sleep, and stress management.";
    if (msg.contains("walking")) return "Yes, 30 mins of brisk walking daily improves cardiovascular health and fitness.";
    if (msg.contains("lose weight")) return "Combine calorie control, regular exercise, sleep, and hydration. Avoid crash diets.";
    if (msg.contains("tired")) return "Chronic fatigue could be due to poor sleep, stress, or medical issues. Consider a health checkup.";
    if (msg.contains("hair loss")) return "Hair loss can result from stress, poor diet, genetics, or medical conditions like thyroid.";
    if (msg.contains("sleep")) return "Stick to a schedule, avoid screens before bed, and ensure a cool, quiet sleeping environment.";
    if (msg.contains("stress") && msg.contains("headache")) return "Yes, stress often causes tension headaches. Practice relaxation techniques.";
    if (msg.contains("healthy diet")) return "A healthy diet includes fruits, vegetables, whole grains, lean proteins, and healthy fats.";
    if (msg.contains("cholesterol")) return "Eat fiber-rich foods, reduce saturated fats, and exercise regularly to lower cholesterol.";
    if (msg.contains("stomach ache")) return "Causes may include indigestion, gas, or infection. Rest, hydrate, and monitor symptoms.";
    if (msg.contains("stroke")) return "Signs include numbness, confusion, trouble speaking, and sudden dizziness. Call emergency services immediately.";
    if (msg.contains("dehydration")) return "Check for dry mouth, dark urine, and dizziness. Drink water regularly.";
    if (msg.contains("anxiety")) return "Anxiety is excessive worry or fear. Try deep breathing, CBT, and avoid caffeine.";
    if (msg.contains("sugar")) return "Limit added sugar to less than 25g/day for women and 36g/day for men.";
    if (msg.contains("intermittent fasting")) return "Intermittent fasting is generally safe for healthy people. Consult a doctor if you have medical issues.";
    if (msg.contains("sprain")) return "Yes, use R.I.C.E. method: Rest, Ice, Compression, Elevation.";
    if (msg.contains("vitamin")) return "Some vitamins are essential daily (like Vitamin C), others (like B12) are stored. Balanced diet preferred.";
    if (msg.contains("flu")) return "Get vaccinated, wash hands regularly, and avoid close contact with sick people.";
    if (msg.contains("antibiotic")) return "Side effects include nausea, diarrhea, and rashes. Avoid unnecessary use.";
    if (msg.contains("burnout")) return "Burnout symptoms: exhaustion, cynicism, reduced performance. Take breaks, sleep, and seek support.";
    if (msg.contains("mental health") && msg.contains("diet")) return "Yes, a healthy diet can support mental well-being. Omega-3s and probiotics help.";
    if (msg.contains("exercise") && msg.contains("heart")) return "Cardio exercises like brisk walking, jogging, and swimming are great for heart health.";
    if (msg.contains("dizzy")) return "Dizziness can stem from dehydration, low sugar, or ear issues. Sit down and hydrate.";
    if (msg.contains("bloating")) return "Avoid carbonated drinks and gassy foods. Try peppermint tea and walk after meals.";
    if (msg.contains("heart rate")) return "Normal resting heart rate is 60–100 bpm. Athletes may have lower.";
    if (msg.contains("frequent colds")) return "Could be weak immunity or allergies. Boost your immune system and rest.";
    if (msg.contains("sleep") && msg.contains("weight")) return "Yes, lack of sleep can affect metabolism and increase hunger hormones.";
    if (msg.contains("anxiety attack")) return "Breathe deeply, stay grounded, and seek help. CBT and mindfulness can help.";
    if (msg.contains("skip breakfast")) return "Occasionally okay, but regular breakfast helps maintain energy and metabolism.";
    if (msg.contains("treat") && msg.contains("mild covid")) return "Rest, fluids, paracetamol for fever, and isolation. Monitor oxygen levels.";
    if (msg.contains("lungs")) return "To strengthen lungs, try breathing exercises, cardio workouts, and avoid smoking.";
    if (msg.contains("types of diabetes")) return "Type 1 (autoimmune), Type 2 (lifestyle-related), Gestational (during pregnancy).";
    if (msg.contains("sore throat")) return "Gargle with salt water, stay hydrated, and try lozenges. Avoid irritants.";
    if (msg.contains("skin rash")) return "Causes include allergies, infections, or heat. Apply moisturizer and consult if persistent.";
    if (msg.contains("hydration") && msg.contains("headache")) return "Yes, dehydration is a common headache trigger. Drink more water.";
    if (msg.contains("seasonal allergy")) return "Use antihistamines, avoid triggers like pollen, and keep windows closed.";
    if (msg.contains("pcos")) return "PCOS is a hormonal disorder. Symptoms: irregular periods, acne, weight gain. Treat with lifestyle changes.";
    if (msg.contains("exercise") && msg.contains("mental health")) return "Yes, regular physical activity reduces anxiety, depression, and stress.";
    if (msg.contains("health checkup")) return "Annually for adults. More often if you have chronic conditions or symptoms.";
    if (msg.contains("hi") || msg.contains("hello")) return "Hello! I’m HealthBot 🤖. Ask me anything about common health problems.";
    if (msg.contains("thank")) return "You're welcome! 😊 Stay healthy!";
    if (msg.contains("Ibrar") || msg.contains("develop") || msg.contains("Hashir") || msg.contains("app")) {
      return "Muhammad Hashir Khalil and Muhammad Ibrar developed this app under the supervision of Sir Zulqarnain Shah";
    }

    return "I'm still learning. Please ask a question related to common health topics.";
  }

  void _autoScroll() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.health_and_safety, color: Colors.white, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Suggested Questions",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Tap a question to ask instantly",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _suggestedQuestions.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.question_answer, color: Colors.deepPurple),
                    title: Text(
                      _suggestedQuestions[index],
                      style: const TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _sendMessage(_suggestedQuestions[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthBot 🤖', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessage(msg["text"], msg["isUser"]);
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: "Ask something about health...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
