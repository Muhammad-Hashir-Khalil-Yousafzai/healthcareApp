import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithName;
  final String chatDocId;

  const ChatScreen({
    super.key,
    required this.chatWithName,
    required this.chatDocId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedMessageIds = {};
  Map<String, dynamic>? _replyToMessage;

  // Color Scheme
  final Color _primaryColor = Colors.deepPurple;
  final Color _accentColor = Colors.deepPurpleAccent;
  final Color _userMessageColor = Colors.deepPurple.shade100;
  final Color _otherMessageColor = Colors.grey.shade100;
  final Color _selectedMessageColor = Colors.blue.shade100;
  final Color _timeTextColor = Colors.grey.shade600;

  void _onLongPressMessage(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  void _onTapMessage(String messageId) {
    if (_selectedMessageIds.isNotEmpty) {
      setState(() {
        if (_selectedMessageIds.contains(messageId)) {
          _selectedMessageIds.remove(messageId);
        } else {
          _selectedMessageIds.add(messageId);
        }
      });
    }
  }

  void _deleteSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final id in _selectedMessageIds) {
      final ref = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatDocId)
          .collection('messages')
          .doc(id);
      batch.delete(ref);
    }
    await batch.commit();
    setState(() {
      _selectedMessageIds.clear();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMessageIds.clear();
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final messageData = {
      'senderId': user.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
      if (_replyToMessage != null)
        'replyTo': {
          'text': _replyToMessage!['text'],
          'senderId': _replyToMessage!['senderId'],
          'id': _replyToMessage!['id'],
        },
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatDocId)
        .collection('messages')
        .add(messageData);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatDocId)
        .update({
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _replyToMessage = null;
      _messageController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 4,
        leading: _selectedMessageIds.isEmpty
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: _clearSelection,
        ),
        title: _selectedMessageIds.isEmpty
            ? Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.chatWithName[0].toUpperCase(),
                style: TextStyle(color: _primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.chatWithName,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        )
            : Text(
          '${_selectedMessageIds.length} selected',
          style: const TextStyle(fontSize: 18),
        ),
        actions: _selectedMessageIds.isEmpty
            ? [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          )
        ]
            : [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelectedMessages,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _primaryColor.withOpacity(0.05),
                    _primaryColor.withOpacity(0.02),
                  ],
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatDocId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: _primaryColor),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final message = doc.data() as Map<String, dynamic>;
                      final isUserMessage =
                          message['senderId'] == currentUser?.uid;
                      final isSelected = _selectedMessageIds.contains(doc.id);
                      final timestamp = message['timestamp'] as Timestamp?;
                      String timeString = '';
                      if (timestamp != null) {
                        final dt = timestamp.toDate();
                        timeString = TimeOfDay.fromDateTime(dt).format(context);
                      }

                      return Slidable(
                        key: ValueKey(doc.id),
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                setState(() {
                                  _replyToMessage = {
                                    'text': message['text'] ?? '',
                                    'senderId': message['senderId'],
                                    'id': doc.id,
                                  };
                                });
                              },
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              icon: Icons.reply,
                              label: 'Reply',
                            )
                          ],
                        ),
                        child: GestureDetector(
                          onLongPress: () => _onLongPressMessage(doc.id),
                          onTap: () => _onTapMessage(doc.id),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Align(
                              alignment: isUserMessage
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                    MediaQuery.of(context).size.width *
                                        0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _selectedMessageColor
                                        : isUserMessage
                                        ? _userMessageColor
                                        : _otherMessageColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12),
                                      topRight: const Radius.circular(12),
                                      bottomLeft: isUserMessage
                                          ? const Radius.circular(12)
                                          : const Radius.circular(4),
                                      bottomRight: isUserMessage
                                          ? const Radius.circular(4)
                                          : const Radius.circular(12),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      if (!isUserMessage)
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            widget.chatWithName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _primaryColor,
                                            ),
                                          ),
                                        ),
                                      if (message['replyTo'] != null)
                                        Container(
                                          margin:
                                          const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                            _primaryColor.withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _primaryColor
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            'Replying to: ${message['replyTo']['text']}',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: _primaryColor,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        message['text'] ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          timeString,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _timeTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          if (_replyToMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: _primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply, color: _primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to: ${_replyToMessage!['text']}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: _primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _replyToMessage = null),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.attach_file,
                              color: Colors.grey.shade600),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _primaryColor,
                        _accentColor,
                      ],
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
