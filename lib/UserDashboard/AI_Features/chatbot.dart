import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/chat_message_extension.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final Gemini gemini = Gemini.instance;
  final String _systemPrompt = """
You are HealthGuard AI, a virtual healthcare assistant designed to:
- Provide general health information (not diagnosis)
- Offer first aid guidance
- Help users assess emergency situations
- Explain medical terms in simple language
- Provide the simple medicines name according to the condition

IDENTITY: 
"I am HealthGuard AI, your virtual healthcare assistant. I'm here to provide general health information and emergency guidance, but I'm not a substitute for professional medical care."

RULES:
1. Never claim to be a human doctor/nurse
2. Always clarify "I'm an AI assistant"
3. For emergencies: "This sounds serious. Please call emergency services or go to the nearest hospital immediately"
4. Never prescribe medications
5. Suggests the medicines according to the conditions
""";

  List<ChatMessage> messages = [];
  bool _isTyping = false;
  ChatUser currentUser = ChatUser(id: "0", firstName: "Patient");
  ChatUser doctorAI = ChatUser(
    id: "1",
    firstName: "HealthGuard",
    lastName: "AI",
    profileImage: "assets/images/Assistant.png",
  );

  final List<ChatSession> _allSessions = [];
  ChatSession _currentSession =
  ChatSession(id: DateTime.now().toString(), title: "New Chat");

  @override
  void initState() {
    super.initState();
    _startNewChat(); // Always start with a new session
    _sendSystemPrompt();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('chat_sessions');

    if (sessionsJson != null) {
      final List<dynamic> decoded = jsonDecode(sessionsJson);

      setState(() {
        _allSessions.addAll(decoded.map((json) {
          return ChatSession(
            id: json['id'],
            title: json['title'],
            messages: (json['messages'] as List)
                .map((m) => ChatMessageJson.fromJsonFull(m))
                .toList(),
          );
        }).toList());
      });

      if (_allSessions.isNotEmpty) {
        _currentSession = _allSessions.last;
        messages = _currentSession.messages;
      }
    }
  }

  Future<void> _saveChatHistory() async {
    // Clone messages list to ensure latest state is captured
    List<ChatMessage> currentMessages = List.from(messages);

    // Update the current session with a suitable title and current messages
    _currentSession = ChatSession(
      id: _currentSession.id,
      title: currentMessages.isNotEmpty
          ? currentMessages.last.text.length > 20
          ? '${currentMessages.last.text.substring(0, 20)}...'
          : currentMessages.last.text
          : "Empty Chat",
      messages: currentMessages,
    );

    // Replace or add the current session
    final index = _allSessions.indexWhere((s) => s.id == _currentSession.id);
    if (index >= 0) {
      _allSessions[index] = _currentSession;
    } else {
      _allSessions.add(_currentSession);
    }

    // Wait for frame to finish to ensure latest UI state is captured
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'chat_sessions',
        jsonEncode(_allSessions.map((s) => s.toJson()).toList()),
      );
    });
  }



  void _startNewChat() {
    setState(() {
      _currentSession = ChatSession(
        id: DateTime.now().toString(),
        title: "New Chat",
      );
      messages = [];
    });
  }

  void _switchChat(String sessionId) {
    final session = _allSessions.firstWhere((s) => s.id == sessionId);
    setState(() {
      _currentSession = session;
      messages = session.messages;
    });
  }

  void _sendSystemPrompt() async {
    await gemini.text(_systemPrompt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FB),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Virtual Doctor Consultation"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            tooltip: 'Medical disclaimer',
            onPressed: _showDisclaimer,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
        ],
      ),
      drawer: _buildChatHistoryDrawer(),
      body: Column(
        children: [
          _buildDisclaimerBanner(),
          Expanded(child: _buildChatUI()),
          if (_isTyping) _buildTypingIndicator(),
        ],
      ),
    );
  }

  Widget _buildChatHistoryDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: const Center(
              child: Text(
                'Your Chats',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allSessions.length,
              itemBuilder: (ctx, index) {
                final session = _allSessions[index];
                return ListTile(
                  title: Text(session.title),
                  subtitle: Text(
                    '${session.messages.length} messages',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteChat(session.id),
                  ),
                  onTap: () {
                    _switchChat(session.id);
                    Navigator.pop(context);
                  },
                  tileColor: session.id == _currentSession.id
                      ? Colors.deepPurple
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChat(String sessionId) async {
    setState(() {
      _allSessions.removeWhere((s) => s.id == sessionId);
      if (_currentSession.id == sessionId) {
        _startNewChat();
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'chat_sessions',
      jsonEncode(_allSessions.map((s) => s.toJson()).toList()),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.deepPurple,
      child: const Text(
        'Note: This AI provides general health information only. Always consult a real doctor for medical advice.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _buildChatUI() {
    return DashChat(
      inputOptions: InputOptions(
        trailing: [
          IconButton(
            icon: const Icon(Icons.medical_information),
            onPressed: _showHealthTips,
          ),
          IconButton(
            onPressed: _sendMediaMessage,
            icon: const Icon(Icons.image),
          ),
        ],
        inputTextStyle: const TextStyle(color: Colors.deepPurple),
      ),
      currentUser: currentUser,
      onSend: (msg) {
        _sendMessage(msg);
      },
      messages: messages,
      messageOptions: MessageOptions(
        currentUserContainerColor: Colors.deepPurple,
        containerColor: Colors.white,
        textColor: Colors.black,
        messageTextBuilder: (message, previousMessage, nextMessage) {
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: message.user == currentUser
                  ? Colors.white
                  : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.user != currentUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                  ),
                MarkdownBody(
                  data: message.text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    strong: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Dr. AI is typing..."),
          SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
      _isTyping = true;
    });

    try {
      String prompt = "Patient asks: ${chatMessage.text}\n\n"
          "Remember: ${chatMessage.medias?.isNotEmpty ?? false ? "This message includes a medical image. Describe generally what you see but remind you can't diagnose." : "Respond as a medical professional following all guidelines."}";

      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }

      ChatMessage aiMessage = ChatMessage(
        user: doctorAI,
        createdAt: DateTime.now(),
        text: '',
      );

      setState(() {
        messages = [aiMessage, ...messages];
      });

      gemini.streamGenerateContent(prompt, images: images).listen((event) {
        String chunk = _extractResponse(event);
        setState(() {
          messages[0] = messages[0].copyWith(
            text: messages[0].text + chunk,
          );
        });
      }, onDone: () async {
        setState(() {
          _isTyping = false;
        });
        await _saveChatHistory(); // Save after AI finishes responding
      }, onError: (e) {
        setState(() {
          _isTyping = false;
        });
        debugPrint("Error generating AI response: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      debugPrint("Exception while sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message. Please try again.")),
      );
    }
  }







  String _extractResponse(dynamic event) {
    String response = event.content?.parts?.fold(
        "",
            (previous, current) =>
        "$previous ${current is TextPart ? current.text : ''}") ??
        "";

    if (response.contains("Your Name") ||
        response.contains("[Your title]") ||
        response.contains("physician") ||
        response.contains("nurse")) {
      response =
      "I'm HealthGuard AI, your virtual healthcare assistant. $response";
    }

    return response;
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Can you review this medical image?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }

  void _showDisclaimer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Medical Disclaimer"),
        content: const Text(
          "This AI assistant provides general health information only and cannot:\n\n"
              "• Diagnose medical conditions\n"
              "• Replace professional medical advice\n"
              "• Prescribe treatments\n\n"
              "For emergencies, call your local emergency number immediately.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("I Understand"),
          ),
        ],
      ),
    );
  }

  void _showHealthTips() {
    _sendMessage(ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: "Please share general health tips",
    ));
  }
}

class ChatSession {
  final String id;
  final String title;
  List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    this.messages = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => ChatMessageJson(m).toJsonFull()).toList(),
  };


  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      messages:
      (json['messages'] as List).map((m) => ChatMessageJson.fromJsonFull(m)).toList(),
    );
  }
}

extension ChatMessageCopyWith on ChatMessage {
  ChatMessage copyWith({
    String? text,
    DateTime? createdAt,
    ChatUser? user,
    List<ChatMedia>? medias,
  }) {
    return ChatMessage(
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      text: text ?? this.text,
      medias: medias ?? this.medias,
    );
  }
}
