import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:healthcare/UserDashboard/BottomNavbar/chat.dart';

class DoctorMessageScreen extends StatelessWidget {
  const DoctorMessageScreen({super.key});

  String getOtherUserId(String chatId, String currentUserId) {
    final ids = chatId.split('_');
    return ids.first == currentUserId ? ids.last : ids.first;
  }

  Future<void> _deleteChat(BuildContext context, String chatId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content:
            const Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete the chat document and all its messages
        final batch = FirebaseFirestore.instance.batch();

        // Delete all messages in the chat
        final messages = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .get();

        for (final doc in messages.docs) {
          batch.delete(doc.reference);
        }

        // Delete the chat document
        batch
            .delete(FirebaseFirestore.instance.collection('chats').doc(chatId));

        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final doctorChats = snapshot.data!.docs.where((chat) {
              final data = chat.data() as Map<String, dynamic>;
              return data['doctorId'] == currentUser.uid ||
                  chat.id.contains(currentUser.uid);
            }).toList();

            if (doctorChats.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: doctorChats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final chat = doctorChats[index];
                return _buildChatListItem(context, chat, currentUser.uid);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Colors.deepPurple.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.deepPurple.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your patient conversations will appear here',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(
      BuildContext context, QueryDocumentSnapshot chat, String currentUserId) {
    final chatData = chat.data() as Map<String, dynamic>;
    final chatId = chat.id;
    final patientId =
        chatData['patientId'] ?? getOtherUserId(chatId, currentUserId);

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(patientId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const SizedBox();

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final userName = userData?['name'] ?? 'Patient';
        final lastMessage = chatData['lastMessage'] ?? 'No messages yet';
        final timestamp = chatData['lastTimestamp'] ?? chatData['createdAt'];
        final hasUnread =
            chatData['unreadCount'] != null && chatData['unreadCount'] > 0;

        return GestureDetector(
          onLongPress: () {
            _showDeleteOptions(context, chatId);
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatDocId: chatId,
                      chatWithName: userName,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildUserAvatar(userData),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (timestamp != null)
                                Text(
                                  _formatTimestamp(timestamp),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasUnread)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteOptions(BuildContext context, String chatId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Conversation',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _deleteChat(context, chatId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic>? userData) {
    final userImage = userData?['imageUrl'];
    final userName = userData?['name'] ?? 'P';

    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.deepPurple.shade100,
      foregroundImage: userImage != null ? NetworkImage(userImage) : null,
      child: userImage == null
          ? Text(
              userName[0].toUpperCase(),
              style: TextStyle(
                color: Colors.deepPurple.shade800,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(date.year, date.month, date.day);

      if (messageDate == today) {
        return DateFormat('h:mm a').format(date);
      } else if (messageDate == yesterday) {
        return 'Yesterday';
      } else {
        return DateFormat('MMM d').format(date);
      }
    }
    return '';
  }
}
