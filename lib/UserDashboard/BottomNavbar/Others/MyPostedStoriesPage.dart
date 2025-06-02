import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPostedstoriesPage extends StatelessWidget {
  final String userId;
  const MyPostedstoriesPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final storiesRef = FirebaseFirestore.instance
        .collection('patient_stories')
        .where('userId', isEqualTo: userId);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Posted Stories', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: storiesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No stories posted yet.'));
          }

          final docs = snapshot.data!.docs;

          // Sort by timestamp descending (newest first)
          docs.sort((a, b) {
            final aTime = a['timestamp'] as Timestamp?;
            final bTime = b['timestamp'] as Timestamp?;
            return bTime?.compareTo(aTime ?? Timestamp(0, 0)) ?? 0;
          });

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final docData = docs[index].data();
              if (docData == null || docData is! Map<String, dynamic>) {
                return SizedBox();
              }
              final data = docData as Map<String, dynamic>;
              final docId = docs[index].id;

              return ListTile(
                leading: Icon(Icons.folder_copy_outlined, color: Colors.deepPurple),
                title: Text(data['title'] ?? ''),
                subtitle: Text('Category: ${data['category']}'),
                trailing: PopupMenuButton(
                  onSelected: (val) async {
                    if (val == 'delete') {
                      await FirebaseFirestore.instance
                          .collection('patient_stories')
                          .doc(docId)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Story deleted.')),
                      );
                    } else if (val == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditStoryPage(docId: docId, initialData: data),
                        ),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditStoryPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditStoryPage({super.key, required this.docId, required this.initialData});

  @override
  State<EditStoryPage> createState() => _EditStoryPageState();
}

class _EditStoryPageState extends State<EditStoryPage> {
  late TextEditingController _titleController;
  late TextEditingController _storyController;
  late String? _selectedCategory;

  final List<String> _categories = [
    'General',
    'Surgery',
    'Mental Health',
    'Recovery',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData['title']);
    _storyController = TextEditingController(text: widget.initialData['story']);
    _selectedCategory = widget.initialData['category'];
  }

  void _updateStory() async {
    if (_titleController.text.trim().isEmpty ||
        _storyController.text.trim().isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('patient_stories')
        .doc(widget.docId)
        .update({
      'title': _titleController.text.trim(),
      'story': _storyController.text.trim(),
      'category': _selectedCategory,
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Story updated successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Story'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Edit story title...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _storyController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Edit your story...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.save, color: Colors.white),
              label: Text('Update', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: _updateStory,
            )
          ],
        ),
      ),
    );
  }
}
