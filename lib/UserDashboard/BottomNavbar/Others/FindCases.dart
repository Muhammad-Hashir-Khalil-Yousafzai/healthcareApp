import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'MyPostedCases.dart';

class FindCasesPage extends StatefulWidget {
  const FindCasesPage({super.key});

  @override
  State<FindCasesPage> createState() => _FindCasesPageState();
}

class _FindCasesPageState extends State<FindCasesPage> {
  final TextEditingController _problemTitleController = TextEditingController();
  final TextEditingController _problemDetailController = TextEditingController();
  String? _selectedCategory;
  File? _selectedImage;
  String? _currentUserId;
  String? _currentUserName;

  final List<String> _categories = [
    'Heart',
    'Lungs',
    'Mental',
    'Diabetes',
    'Surgery',
    'BP',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
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
          _currentUserName = userDoc.data()['name'] ?? 'Unknown';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found in users collection.')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<String?> _convertImageToBase64(File? image) async {
    if (image == null) return null;
    List<int> imageBytes = await image.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> _submitCase() async {
    if (_problemTitleController.text.trim().isEmpty ||
        _problemDetailController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _currentUserId == null ||
        _currentUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    try {
      String? base64Image = await _convertImageToBase64(_selectedImage);

      await FirebaseFirestore.instance.collection('Findcases').add({
        'title': _problemTitleController.text.trim(),
        'details': _problemDetailController.text.trim(),
        'category': _selectedCategory,
        'imageBase64': base64Image ?? '', // Store empty string if no image
        'timestamp': Timestamp.now(),
        'userId': _currentUserId,
        'userName': _currentUserName,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case submitted successfully!')),
      );

      // Clear form
      setState(() {
        _problemTitleController.clear();
        _problemDetailController.clear();
        _selectedCategory = null;
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting case: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Me A Doctor', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_shared),
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyPostedCasesPage(userId: _currentUserId!),
              ),
            );

            },
            tooltip: 'My Cases',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe the issue you’re facing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Title
            TextField(
              controller: _problemTitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Problem Detail
            TextField(
              controller: _problemDetailController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Problem in Detail',
                hintText: 'Explain your symptoms and medical history in detail...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 16),

            const Text('Attach Medical Report / Test Result (Optional)'),
            const SizedBox(height: 8),

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
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : const Center(
                  child: Icon(Icons.add_photo_alternate_outlined, color: Colors.deepPurple),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('Submit Case', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitCase,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
