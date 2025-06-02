import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDiaries extends StatefulWidget {
  const PatientDiaries({super.key});

  @override
  State<PatientDiaries> createState() => _PatientDiariesState();
}

final currentUser = FirebaseAuth.instance.currentUser;

class _PatientDiariesState extends State<PatientDiaries> {
  Future<void> toggleArticleLike(DocumentSnapshot diaryDoc, Map<String, dynamic> data) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    List likedBy = data['likedBy'] ?? [];
    bool isLiked = likedBy.contains(uid);

    if (isLiked) {
      likedBy.remove(uid);
    } else {
      likedBy.add(uid);
    }

    await FirebaseFirestore.instance.collection('patient_stories').doc(diaryDoc.id).update({
      'likedBy': likedBy,
      'likes': likedBy.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Diaries', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patient_stories')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No patient diaries found.'));
          }

          final diaries = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: diaries.length,
            itemBuilder: (context, index) {
              final diaryDoc = diaries[index];
              final data = diaryDoc.data() as Map<String, dynamic>;

              List likedBy = data['likedBy'] ?? [];
              bool isArticleLiked = currentUser != null && likedBy.contains(currentUser!.uid);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Text(
                            data['userName'] != null && data['userName'].isNotEmpty
                                ? data['userName'][0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          data['userName'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(data['timestamp'] != null
                            ? (data['timestamp'] as Timestamp).toDate().toString().split(' ')[0]
                            : ''),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['title'] ?? 'No Title',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data['story'] != null
                            ? (data['story'].toString().length > 80
                            ? data['story'].toString().substring(0, 80) + '...'
                            : data['story'].toString())
                            : '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  await toggleArticleLike(diaryDoc, data);
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isArticleLiked ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.red.shade300,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${data['likes'] ?? 0}',
                                        style: TextStyle(color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  Icon(Icons.comment_outlined, color: Colors.blue.shade300, size: 20),
                                  const SizedBox(width: 4),
                                  Text('${(data['comments'] as List?)?.length ?? 0}',
                                      style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ],
                          ),
                          TextButton(
                            child: const Text('Read More'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientDiaryDetailPage(
                                    diaryDoc: diaryDoc,
                                    diary: {
                                      'id': diaryDoc.id,
                                      'patientName': data['userName'],
                                      'condition': data['condition'] ?? '',
                                      'diaryTitle': data['title'],
                                      'fullDiary': data['story'],
                                      'date': data['timestamp'] != null
                                          ? (data['timestamp'] as Timestamp).toDate().toString().split(' ')[0]
                                          : '',
                                      'patientImage': data['userImage'] ?? '',
                                      'comments': data['comments'] ?? [],
                                      'likes': data['likes'] ?? 0,
                                      'likedBy': likedBy,
                                    },
                                    index: index,
                                    onUpdate: (_) {},
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PatientDiaryDetailPage extends StatefulWidget {
  final DocumentSnapshot diaryDoc;
  final Map<String, dynamic> diary;
  final int index;
  final Function(List<String>) onUpdate;

  const PatientDiaryDetailPage({
    super.key,
    required this.diaryDoc,
    required this.diary,
    required this.index,
    required this.onUpdate,
  });

  @override
  State<PatientDiaryDetailPage> createState() => _PatientDiaryDetailPageState();
}

class _PatientDiaryDetailPageState extends State<PatientDiaryDetailPage> {
  final TextEditingController commentController = TextEditingController();
  final List<Map<String, dynamic>> comments = [];
  late List likedBy;
  bool isArticleLiked = false;

  @override
  void initState() {
    super.initState();

    final diaryComments = widget.diary['comments'] as List? ?? [];
    comments.addAll(diaryComments.map<Map<String, dynamic>>((c) => {
      'uid': c['uid'],
      'name': c['name'],
      'text': c['text'],
      'timestamp': (c['timestamp'] is Timestamp)
          ? (c['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      'likes': c['likes'] ?? 0,
      'isLiked': c['isLiked'] ?? false,
      'replies': c['replies'] ?? [],
      'likedBy': c['likedBy'] ?? [], // Add likedBy for comment if you want to track who liked each comment
    }));

    likedBy = List.from(widget.diary['likedBy'] ?? []);
    final uid = currentUser?.uid;
    isArticleLiked = uid != null && likedBy.contains(uid);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> toggleArticleLike() async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    setState(() {
      if (isArticleLiked) {
        likedBy.remove(uid);
      } else {
        likedBy.add(uid);
      }
      isArticleLiked = !isArticleLiked;
    });

    await FirebaseFirestore.instance.collection('patient_stories').doc(widget.diaryDoc.id).update({
      'likedBy': likedBy,
      'likes': likedBy.length,
    });
  }

  Future<void> toggleCommentLike(int index) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final comment = comments[index];
    List commentLikedBy = List.from(comment['likedBy'] ?? []);

    setState(() {
      bool commentIsLiked = commentLikedBy.contains(uid);
      if (commentIsLiked) {
        commentLikedBy.remove(uid);
        comment['likes'] = (comment['likes'] ?? 0) - 1;
      } else {
        commentLikedBy.add(uid);
        comment['likes'] = (comment['likes'] ?? 0) + 1;
      }
      comment['likedBy'] = commentLikedBy;
      comment['isLiked'] = commentLikedBy.contains(uid);
    });

    // Update Firestore with new comments list including likes and likedBy
    await FirebaseFirestore.instance.collection('patient_stories').doc(widget.diaryDoc.id).update({
      'comments': comments.map((c) {
        return {
          'uid': c['uid'],
          'name': c['name'],
          'text': c['text'],
          'timestamp': Timestamp.fromDate(c['timestamp']),
          'likes': c['likes'],
          'isLiked': c['isLiked'],
          'replies': c['replies'],
          'likedBy': c['likedBy'] ?? [],
        };
      }).toList(),
    });
  }

  void addComment(String commentText) async {
    if (commentText.trim().isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final userName = userDoc['name'] ?? 'Unknown';

      final newComment = {
        'uid': currentUser.uid,
        'name': userName,
        'text': commentText.trim(),
        'timestamp': DateTime.now(),
        'likes': 0,
        'isLiked': false,
        'replies': [],
        'likedBy': [],
      };

      setState(() {
        comments.insert(0, newComment);
      });

      widget.onUpdate(comments.map((e) => e['text'] as String).toList());
      commentController.clear();

      await FirebaseFirestore.instance
          .collection('patient_stories')
          .doc(widget.diaryDoc.id)
          .update({
        'comments': comments.map((c) {
          return {
            'uid': c['uid'],
            'name': c['name'],
            'text': c['text'],
            'timestamp': Timestamp.fromDate(c['timestamp']),
            'likes': c['likes'],
            'isLiked': c['isLiked'],
            'replies': c['replies'],
            'likedBy': c['likedBy'] ?? [],
          };
        }).toList(),
      });
    }
  }

  void deleteComment(int index) {
    setState(() {
      comments.removeAt(index);
    });

    widget.onUpdate(comments.map((e) => e['text'] as String).toList());

    FirebaseFirestore.instance.collection('patient_stories').doc(widget.diaryDoc.id).update({
      'comments': comments.map((c) {
        return {
          'uid': c['uid'],
          'name': c['name'],
          'text': c['text'],
          'timestamp': Timestamp.fromDate(c['timestamp']),
          'likes': c['likes'],
          'isLiked': c['isLiked'],
          'replies': c['replies'],
          'likedBy': c['likedBy'] ?? [],
        };
      }).toList(),
    });
  }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isArticleLiked ? Icons.favorite : Icons.favorite_border,
              color: Colors.red.shade300,
            ),
            onPressed: toggleArticleLike,
          ),
          Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text('${likedBy.length}', style: const TextStyle(fontSize: 16)),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Hero(
                tag: 'patientImage_${widget.index}',
                child: CircleAvatar(
                  backgroundImage: widget.diary['patientImage'].isNotEmpty
                      ? NetworkImage(widget.diary['patientImage'])
                      : null,
                  child: widget.diary['patientImage'].isEmpty ? const Icon(Icons.person) : null,
                  radius: 28,
                ),
              ),
              title: Text(widget.diary['patientName'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('${widget.diary['condition']} • ${widget.diary['date']}'),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Text(widget.diary['diaryTitle'],
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(widget.diary['fullDiary'], style: const TextStyle(fontSize: 16, height: 1.5)),
                    const SizedBox(height: 20),
                    const Divider(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Comments',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    ...comments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final comment = entry.value;
                      final commentLikedBy = List.from(comment['likedBy'] ?? []);
                      final uid = currentUser?.uid;
                      final commentIsLiked = uid != null && commentLikedBy.contains(uid);

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (comment['text'] is String && (comment['text'] as String).isNotEmpty)
                                  ? (comment['text'] as String)[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.deepPurple.shade100,
                          ),
                          title: Text(comment['name'] ?? 'Anonymous',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment['text']),
                              const SizedBox(height: 4),
                              Text(timeAgo(comment['timestamp']),
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => toggleCommentLike(index),
                                child: Row(
                                  children: [
                                    Icon(
                                      commentIsLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red.shade300,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${comment['likes'] ?? 0}',
                                        style: TextStyle(color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                              if (comment['uid'] == currentUser?.uid)
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                                  onPressed: () => deleteComment(index),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (comments.isEmpty)
                      const Text('No comments yet. Be the first to comment!',
                          style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      addComment(commentController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
