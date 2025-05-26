import 'package:dash_chat_2/dash_chat_2.dart';


extension ChatMessageJson on ChatMessage {
  Map<String, dynamic> toJsonFull() {
    return {
      'user_id': user.id,
      'user_name': user.firstName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'medias': medias?.map((m) => {
        'url': m.url,
        'fileName': m.fileName,
        'type': m.type, // assuming type is String
      }).toList(),
    };
  }

  static ChatMessage fromJsonFull(Map<String, dynamic> json) {
    ChatUser user;
    if (json['user_id'] == "1") {
      user = ChatUser(
        id: "1",
        firstName: "HealthGuard",
        lastName: "AI",
        profileImage: "assets/images/ai_consultant.png",
      );
    } else {
      user = ChatUser(id: "0", firstName: "Patient");
    }

    return ChatMessage(
      user: user,
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      medias: (json['medias'] as List?)?.map((m) {
        return ChatMedia(
          url: m['url'],
          fileName: m['fileName'],
          type: m['type'],  // use string directly
        );
      }).toList(),
    );
  }
}
