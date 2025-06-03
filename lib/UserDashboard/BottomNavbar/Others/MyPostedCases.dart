import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyPostedCasesPage extends StatelessWidget {
  final String userId;
  const MyPostedCasesPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final casesRef = FirebaseFirestore.instance
        .collection('Findcases')
        .where('userId', isEqualTo: userId);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Posted Cases', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: casesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No cases posted yet.'));
          }

          final docs = snapshot.data!.docs;

          // Sort by timestamp descending
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
                subtitle: Text('Category: ${data['category'] ?? 'N/A'}'),
                trailing: PopupMenuButton(
                  onSelected: (val) async {
                    if (val == 'delete') {
                      await FirebaseFirestore.instance
                          .collection('Findcases')
                          .doc(docId)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Case deleted.')),
                      );
                    } else if (val == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCasePage(
                            docId: docId,
                            initialData: data,
                          ),
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


class EditCasePage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditCasePage({super.key, required this.docId, required this.initialData});

  @override
  State<EditCasePage> createState() => _EditCasePageState();
}

class _EditCasePageState extends State<EditCasePage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String? _selectedCategory;

  final List<String> _categories = [
    "All", "Heart", "Diabetes", "Lungs", "Kidney", "Mental", "Surgery", "BP", "Other"
  ];

  @override
  void initState() {
    super.initState();

    // Provide default empty strings if null to avoid issues
    _titleController = TextEditingController(text: widget.initialData['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.initialData['details'] ?? '');
    _selectedCategory = widget.initialData['category'] != null && _categories.contains(widget.initialData['category'])
        ? widget.initialData['category']
        : null;
  }

  void _updateCase() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Findcases')
          .doc(widget.docId)
          .update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Case updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update case: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Case'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Case Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.save, color: Colors.white),
              label: Text('Update', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: _updateCase,
            )
          ],
        ),
      ),
    );
  }
}
