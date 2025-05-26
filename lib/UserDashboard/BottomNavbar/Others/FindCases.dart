import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final List<String> _categories = [
    'Heart',
    'Lungs',
    'Mental Health',
    'Diabetes',
    'Surgery',
    'BP',
    'Other'
  ];
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _submitCase() {
    if (_problemTitleController.text.trim().isEmpty ||
        _problemDetailController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and attach a report')),
      );
      return;
    }

    // TODO: Submit logic here

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Health Cases', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_shared),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe the issue you’re facing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _problemTitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Problem Statement
            TextField(
              controller: _problemTitleController,
              decoration: const InputDecoration(
                labelText: 'Problem Statement',
                hintText: 'Describe Your problem in short words',
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

            const Text('Attach Medical Report / Test Result'),
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
