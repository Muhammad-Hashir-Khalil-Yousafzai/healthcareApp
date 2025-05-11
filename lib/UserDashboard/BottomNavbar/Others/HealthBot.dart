import 'package:flutter/material.dart';

class HealthBotScreen extends StatefulWidget {
  const HealthBotScreen({super.key});

  @override
  State<HealthBotScreen> createState() => _HealthBotScreenState();
}

class _HealthBotScreenState extends State<HealthBotScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"text": message, "isUser": true});
    });

    _controller.clear();
    _autoScroll();

    Future.delayed(Duration(milliseconds: 500), () {
      String botReply = _generateBotReply(message);
      setState(() {
        _messages.add({"text": botReply, "isUser": false});
      });
      _autoScroll();
    });
  }

  String _generateBotReply(String userMessage) {
    String msg = userMessage.toLowerCase();

    if (msg.contains("fever") || msg.contains("temperature")) {
      return "A mild fever is usually not serious. Stay hydrated, take rest, and monitor symptoms. If it persists over 3 days, consult a doctor.";
    } else if (msg.contains("headache")) {
      return "Headaches can result from dehydration, stress, or lack of sleep. Try resting and drinking water. See a doctor if it's severe or frequent.";
    } else if (msg.contains("diabetes")) {
      return "For diabetes, maintain a low-sugar, high-fiber diet. Regular exercise and prescribed medication are essential.";
    } else if (msg.contains("covid") || msg.contains("corona")) {
      return "COVID-19 symptoms include fever, cough, and fatigue. Isolate, wear a mask, and consult a medical professional immediately.";
    } else if (msg.contains("bmi")) {
      return "BMI (Body Mass Index) = weight(kg) / [height(m)]². Normal range: 18.5–24.9. We also offer a BMI calculator on the dashboard!";
    } else if (msg.contains("thank")) {
      return "You're welcome! 😊 Stay healthy!";
    } else if (msg.contains("hi") || msg.contains("hello")) {
      return "Hello! I’m HealthBot 🤖. Ask me anything about common health problems.";
    } else {
      return "I’m still learning. Please ask a question related to common health issues like fever, headache, diabetes, etc.";
    }
  }

  void _autoScroll() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HealthBot 🤖', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessage(msg["text"], msg["isUser"]);
              },
            ),
          ),
          Divider(height: 1),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Ask something about health...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.deepPurple),
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
