import 'package:flutter/material.dart';

class DoctorDiaries extends StatefulWidget {
  const DoctorDiaries({super.key});

  @override
  State<DoctorDiaries> createState() => _DoctorDiariesState();
}

class _DoctorDiariesState extends State<DoctorDiaries> {
  final List<Map<String, dynamic>> diaries = [
    {
      'doctorName': 'Dr. Ayesha Siddiqui',
      'doctorImage': 'https://i.pravatar.cc/150?img=12',
      'specialization': 'Cardiologist',
      'diaryTitle': 'Heart Transplant Case',
      'summary': 'Successfully handled a rare heart transplant case...',
      'fullDiary': 'Successfully handled a rare heart transplant case involving a 45-year-old patient. The surgery took over 9 hours and included a multidisciplinary team. Post-op recovery was phenomenal, and the patient is now leading a healthy life.',
      'date': 'May 10, 2025',
      'likes': 56,
      'comments': [],
      'isLiked': false,
    },
    {
      'doctorName': 'Dr. Kamran Malik',
      'doctorImage': 'https://i.pravatar.cc/150?img=18',
      'specialization': 'Psychiatrist',
      'diaryTitle': 'Mental Health Success',
      'summary': 'Helped a patient overcome chronic depression...',
      'fullDiary': 'Helped a patient overcome chronic depression through CBT and lifestyle changes. The patient is now medication-free, employed again, and leads support groups. Mental health is as crucial as physical health!',
      'date': 'April 20, 2025',
      'likes': 74,
      'comments': [],
      'isLiked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Diaries', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: diaries.length,
        itemBuilder: (context, index) {
          final diary = diaries[index];
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
                    leading: Hero(
                      tag: 'doctorImage_$index',
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(diary['doctorImage']),
                        radius: 25,
                      ),
                    ),
                    title: Text(
                      diary['doctorName'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('${diary['specialization']} • ${diary['date']}'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    diary['diaryTitle'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(diary['summary']),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          diary['isLiked'] ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            diary['isLiked'] = !diary['isLiked'];
                            diary['likes'] += diary['isLiked'] ? 1 : -1;
                          });
                        },
                      ),
                      Text('${diary['likes']}'),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorDiaryDetailPage(
                                diary: diary,
                                index: index,
                                onUpdate: (updatedComments) {
                                  setState(() {
                                    diary['comments'] = updatedComments;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Text('${diary['comments'].length}'),
                      const Spacer(),
                      TextButton(
                        child: const Text('Read More'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorDiaryDetailPage(
                                diary: diary,
                                index: index,
                                onUpdate: (updatedComments) {
                                  setState(() {
                                    diary['comments'] = updatedComments;
                                  });
                                },
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
      ),
    );
  }
}

class DoctorDiaryDetailPage extends StatefulWidget {
  final Map<String, dynamic> diary;
  final int index;
  final Function(List<String>) onUpdate;

  const DoctorDiaryDetailPage({
    super.key,
    required this.diary,
    required this.index,
    required this.onUpdate,
  });

  @override
  State<DoctorDiaryDetailPage> createState() => _DoctorDiaryDetailPageState();
}

class _DoctorDiaryDetailPageState extends State<DoctorDiaryDetailPage> {
  final TextEditingController commentController = TextEditingController();

  final List<Map<String, dynamic>> comments = [];

  void addComment(String commentText) {
    if (commentText.trim().isEmpty) return;
    setState(() {
      comments.insert(0, {
        'text': commentText.trim(),
        'timestamp': DateTime.now(),
        'likes': 0,
        'isLiked': false,
        'replies': []
      });
    });
    widget.onUpdate(comments.map((e) => e['text'] as String).toList());
    commentController.clear();
  }

  void deleteComment(int index) {
    setState(() {
      comments.removeAt(index);
    });
    widget.onUpdate(comments.map((e) => e['text'] as String).toList());
  }

  String timeAgo(DateTime time) {
    final Duration diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  @override
  void initState() {
    super.initState();
    comments.addAll(widget.diary['comments'].map<Map<String, dynamic>>((c) => {
      'text': c,
      'timestamp': DateTime.now(),
      'likes': 0,
      'isLiked': false,
      'replies': []
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Hero(
                tag: 'doctorImage_${widget.index}',
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.diary['doctorImage']),
                  radius: 28,
                ),
              ),
              title: Text(widget.diary['doctorName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('${widget.diary['specialization']} • ${widget.diary['date']}'),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Text(widget.diary['diaryTitle'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
                      child: Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    ...comments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final comment = entry.value;
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(comment['text'][0].toUpperCase()),
                            backgroundColor: Colors.deepPurple.shade200,
                          ),
                          title: Text(comment['text']),
                          subtitle: Text(timeAgo(comment['timestamp'])),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  comment['isLiked'] ? Icons.favorite : Icons.favorite_border,
                                  color: comment['isLiked'] ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    comment['isLiked'] = !comment['isLiked'];
                                    comment['likes'] += comment['isLiked'] ? 1 : -1;
                                  });
                                },
                              ),
                              Text('${comment['likes']}'),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => deleteComment(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              prefixIcon: const Icon(Icons.comment, color: Colors.deepPurple),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => addComment(commentController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

