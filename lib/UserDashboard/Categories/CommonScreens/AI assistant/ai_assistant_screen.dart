import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIAssistantScreen extends StatefulWidget {
  final String categoryTitle;

  const AIAssistantScreen({super.key, required this.categoryTitle});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final Gemini gemini = Gemini.instance;

  late String _systemPrompt;

  final Map<String, String> prompts = {
    "Heart": """
You are HealthGuard AI, a virtual assistant focused on heart health:
- Provide information about heart conditions (e.g., hypertension, heart attack)
- Explain symptoms, lifestyle tips, and prevention methods
- Remind users to consult cardiologists for diagnosis and treatment
- Never prescribe medications

IDENTITY: "I'm HealthGuard AI, here to guide you on heart health."
""",
    "Lungs": """
You are HealthGuard AI, specialized in lung health:
- Educate users on conditions like asthma, bronchitis, COPD
- Explain symptoms like chest tightness, wheezing, etc.
- Suggest preventive care but NOT diagnosis or prescriptions
- Always recommend consulting a pulmonologist

IDENTITY: "I'm HealthGuard AI, your lung care assistant."
""",
    "Mental Health": """
You are HealthGuard AI, supporting mental wellness:
- Provide coping tips for stress, anxiety, and depression
- Offer motivational messages and self-care strategies
- Encourage professional therapy or counseling
- Never diagnose or recommend medications

IDENTITY: "I'm HealthGuard AI, supporting your mental wellness."
""",
    "Diabetes": """
You are HealthGuard AI, a virtual diabetes care guide:
- Explain types of diabetes, symptoms, and dietary tips
- Help monitor sugar level indicators
- Warn about hypoglycemia or hyperglycemia symptoms
- Recommend consulting an endocrinologist

IDENTITY: "I'm HealthGuard AI, your guide for diabetes awareness."
""",
    "BP": """
You are HealthGuard AI, offering insights into blood pressure management:
- Clarify the difference between high and low blood pressure
- Share symptoms, prevention, and lifestyle changes
- Never recommend medications or doses
- Refer users to healthcare professionals

IDENTITY: "I'm HealthGuard AI, helping you manage blood pressure."
""",
    "Physical Health": """
You are HealthGuard AI, your assistant for general physical wellness:
- Offer exercise tips, postural advice, injury prevention
- Respond to basic health questions
- Remind users to see a physiotherapist or general physician when needed

IDENTITY: "I'm HealthGuard AI, your physical health guide."
""",
  };

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
    _systemPrompt = prompts[widget.categoryTitle] ?? prompts["Physical Health"]!;
    _sendSystemPrompt();
    _startNewChat(); // Always start with a new session
    _loadChatHistory(); // Still load history so drawer shows old chats
  }


  void _switchChat(String sessionId) {
    final session = _allSessions.firstWhere((s) => s.id == sessionId);
    setState(() {
      _currentSession = session;
      messages = session.messages;
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

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('chat_sessions');

    if (sessionsJson != null) {
      final List<dynamic> decoded = jsonDecode(sessionsJson);
      setState(() {
        _allSessions
            .addAll(decoded.map((json) => ChatSession.fromJson(json)).toList());
      });

      if (_allSessions.isNotEmpty) {
        _currentSession = _allSessions.last;
        messages = _currentSession.messages;
      }
    }
  }

  Future<void> _saveChatHistory() async {
    _currentSession = ChatSession(
      id: _currentSession.id,
      title: messages.isNotEmpty
          ? messages.last.text.length > 20
          ? '${messages.last.text.substring(0, 20)}...'
          : messages.last.text
          : "Empty Chat",
      messages: messages,
    );

    final index = _allSessions.indexWhere((s) => s.id == _currentSession.id);
    if (index >= 0) {
      _allSessions[index] = _currentSession;
    } else {
      _allSessions.add(_currentSession);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'chat_sessions',
      jsonEncode(_allSessions.map((s) => s.toJson()).toList()),
    );
  }

  void _sendSystemPrompt() async {
    await gemini.text(_systemPrompt);
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
      _isTyping = true;
    });

    try {
      String prompt = "$_systemPrompt\n\nPatient says: ${chatMessage.text}";
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }

      gemini.streamGenerateContent(prompt, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        String response = _extractResponse(event);

        if (lastMessage != null && lastMessage.user == doctorAI) {
          lastMessage = messages.removeAt(0);
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          ChatMessage message = ChatMessage(
            user: doctorAI,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      }, onDone: () {
        setState(() => _isTyping = false);
      });
    } catch (e) {
      print(e);
      setState(() => _isTyping = false);
    }
  }

  String _extractResponse(dynamic event) {
    return event.content?.parts?.fold(
      "",
          (previous, current) =>
      "$previous ${current is TextPart ? current.text : ''}",
    ) ??
        "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FB),
      appBar: AppBar(
        centerTitle: true,
        title: Text("${widget.categoryTitle} Chat"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            tooltip: 'Medical disclaimer',
            onPressed: _showDisclaimer,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat_bubble_outline, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Your Consultations',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _startNewChat();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Start New Chat", style: TextStyle(color: Colors.white)),
              ),
            ),
            const Divider(height: 20, thickness: 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Text("Previous Sessions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _allSessions.isEmpty
                  ? const Center(child: Text("No chat history found."))
                  : ListView.separated(
                itemCount: _allSessions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final session = _allSessions[index];
                  final bool isCurrent = session.id == _currentSession.id;
                  return ListTile(
                    leading: const Icon(Icons.chat, color: Colors.deepPurple),
                    title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text("${session.messages.length} messages", style: const TextStyle(fontSize: 12)),
                    tileColor: isCurrent ? Colors.deepPurple.shade50 : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteChat(session.id),
                    ),
                    onTap: () {
                      _switchChat(session.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
      color: Colors.deepPurple[50],
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
          inputDecoration: InputDecoration(
            hintText: "Type your message...",
            hintStyle: const TextStyle(color: Colors.grey), // Hint text color
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.deepPurple),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          inputTextStyle: const TextStyle(color: Colors.black), // Text inside input
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
        ),

      currentUser: currentUser,
      onSend: (msg) {
        _sendMessage(msg);
        _saveChatHistory();
      },
      messages: messages,
      messageOptions: MessageOptions(
        currentUserContainerColor: const Color(0xFFF9F7FB),
        containerColor: Colors.white,
        textColor: Colors.black,
        messageTextBuilder: (message, previousMessage, nextMessage) {
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),

              color: message.user == currentUser
                  ? Colors.deepPurple[100]
                  : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.user != currentUser)
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 4),
                  //   child: Text(
                  //     'Dr. AI',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.deepPurple,
                  //     ),
                  //   ),
                  // ),
                MarkdownBody(
                  data: message.text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    strong: TextStyle(
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
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }
}
