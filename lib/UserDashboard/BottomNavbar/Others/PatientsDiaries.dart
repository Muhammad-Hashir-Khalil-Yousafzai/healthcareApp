import 'package:flutter/material.dart';

class PatientDiaries extends StatelessWidget {
  const PatientDiaries({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> diaries = [
      {
        'userName': 'Ali Khan',
        'userImage': 'https://i.pravatar.cc/150?img=3',
        'category': 'Recovery',
        'story':
        'After a long battle with spinal injury, here’s how I got back on my feet...',
        'fullStory': 'After a long battle with spinal injury, here’s how I got back on my feet. I went through intense physiotherapy, daily motivation, and mental resilience. I learned how to walk again step by step and I want to thank Dr. Hussain for guiding me. Never lose hope!',
        'date': 'May 5, 2025',
        'likes': 23,
        'comments': 5,
      },
      {
        'userName': 'Fatima Noor',
        'userImage': 'https://i.pravatar.cc/150?img=5',
        'category': 'Mental Health',
        'story':
        'I struggled with anxiety for years. Talking about it helped me heal...',
        'fullStory':
        'I struggled with anxiety for years. Talking about it helped me heal. I joined group therapy, changed my diet, and started yoga. Slowly, the panic attacks faded. Sharing my journey might help someone else feel they are not alone.',
        'date': 'April 30, 2025',
        'likes': 41,
        'comments': 10,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Diaries', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: diaries.length,
        padding: EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final diary = diaries[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(diary['userImage']),
                    ),
                    title: Text(diary['userName'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${diary['category']} • ${diary['date']}'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    diary['story'],
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, color: Colors.red),
                      SizedBox(width: 4),
                      Text('${diary['likes']}'),
                      SizedBox(width: 16),
                      Icon(Icons.comment_outlined, color: Colors.blue),
                      SizedBox(width: 4),
                      Text('${diary['comments']}'),
                      Spacer(),
                      TextButton(
                        child: Text('Read More'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DiaryDetailPage(
                                userName: diary['userName'],
                                userImage: diary['userImage'],
                                category: diary['category'],
                                date: diary['date'],
                                fullStory: diary['fullStory'],
                              ),
                            ),
                          );
                        },
                      )
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

class DiaryDetailPage extends StatelessWidget {
  final String userName;
  final String userImage;
  final String category;
  final String date;
  final String fullStory;

  const DiaryDetailPage({
    super.key,
    required this.userName,
    required this.userImage,
    required this.category,
    required this.date,
    required this.fullStory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundImage: NetworkImage(userImage)),
              title: Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$category • $date'),
            ),
            Divider(),
            SizedBox(height: 10),
            Text(fullStory, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
