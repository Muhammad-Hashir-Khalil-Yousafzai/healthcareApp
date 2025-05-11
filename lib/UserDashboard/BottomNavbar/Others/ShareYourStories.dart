import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'MyPostedCasesPage.dart';

class ShareYourStoriesPage extends StatefulWidget {
  const ShareYourStoriesPage({super.key});

  @override
  State<ShareYourStoriesPage> createState() => _ShareYourStoriesPageState();
}

class _ShareYourStoriesPageState extends State<ShareYourStoriesPage> {
  final TextEditingController _storyController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['General', 'Surgery', 'Mental Health', 'Recovery', 'Other'];
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _submitStory() {
    if (_storyController.text.trim().isEmpty || _selectedCategory == null || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields and attach a report')),
      );
      return;
    }

    // Submit logic here (send to Firebase/local DB)

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Story submitted successfully!')),
    );

    // Clear form
    setState(() {
      _storyController.clear();
      _selectedCategory = null;
      _selectedImage = null;
    });
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPostedCasesPage()),
              );
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
            SizedBox(height: 16),
            Text('Attach Reports or Test Results'),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Center(child: Icon(Icons.add_a_photo, color: Colors.deepPurple)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.send ,color: Colors.white),
              label: Text('Submit Story',style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: _submitStory,
            ),
          ],
        ),
      ),
    );
  }
}
