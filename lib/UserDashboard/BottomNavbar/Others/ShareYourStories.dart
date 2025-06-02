import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'MyPostedStoriesPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: ShareYourStoriesPage()));
}

class ShareYourStoriesPage extends StatefulWidget {
  const ShareYourStoriesPage({super.key});

  @override
  State<ShareYourStoriesPage> createState() => _ShareYourStoriesPageState();
}

class _ShareYourStoriesPageState extends State<ShareYourStoriesPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['General', 'Surgery', 'Mental Health', 'Recovery', 'Other'];
  bool _isSubmitting = false;
  String? _currentUserId;
  String? _currentUserName; // Store user's name here

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  void _fetchCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        final userDoc = usersSnapshot.docs.first;
        setState(() {
          _currentUserId = userDoc.id;
          _currentUserName = userDoc.data()['name'] ?? 'Unknown'; // get name field
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found in users collection.')),
        );
      }
    }
  }

  void _submitStory() async {
    if (_titleController.text.trim().isEmpty ||
        _storyController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _currentUserId == null ||
        _currentUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('patient_stories').add({
        'title': _titleController.text.trim(),
        'story': _storyController.text.trim(),
        'category': _selectedCategory,
        'timestamp': Timestamp.now(),
        'userId': _currentUserId,
        'userName': _currentUserName, // save userName here
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Story submitted successfully!')),
      );

      _titleController.clear();
      _storyController.clear();
      setState(() {
        _selectedCategory = null;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting story: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Your Story', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_shared),
            onPressed: () {
              if (_currentUserId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPostedstoriesPage(userId: _currentUserId!)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User not loaded yet.')),
                );
              }
            },
            tooltip: 'My Cases',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tell us your health journey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter story title...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _storyController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Write your story...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.send, color: Colors.white),
              label: Text(
                _isSubmitting ? 'Submitting...' : 'Submit Story',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: _isSubmitting ? null : _submitStory,
            ),
          ],
        ),
      ),
    );
  }
}

