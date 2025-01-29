import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String doctorName;

  const ChatScreen({super.key, required this.doctorName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Added scroll controller

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Load messages from SharedPreferences
  }

  // Function to load messages from SharedPreferences
  void _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      String? storedMessages = prefs.getString('messages');
      if (storedMessages != null) {
        List<dynamic> decodedMessages = jsonDecode(storedMessages);
        messages = decodedMessages.map<Map<String, String>>((msg) {
          if (msg is Map) {
            return msg.map((key, value) => MapEntry(key.toString(), value.toString()));
          } else {
            return {'sender': '', 'message': ''}; // Handle invalid entries
          }
        }).toList();
      }
    });

    // Scroll to the bottom after loading messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // Function to save messages to SharedPreferences
  void _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedMessages = jsonEncode(messages);
    await prefs.setString('messages', encodedMessages);
  }

  // Function to send a message
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      messages.add({'sender': 'You', 'message': _messageController.text.trim()});
      _messageController.clear();
    });

    _saveMessages(); // Save messages after adding a new one

    // Scroll to the bottom after sending a message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.doctorName}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // Reverse the list
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index]; // Adjust index due to reverse
                final isUserMessage = message['sender'] == 'You';

                return Align(
                  alignment:
                  isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.deepPurple.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send, color: Colors.deepPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
