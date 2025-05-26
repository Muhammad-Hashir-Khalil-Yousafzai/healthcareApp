import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostArticles extends StatefulWidget {
  const PostArticles({super.key});

  @override
  State<PostArticles> createState() => _PostArticlesState();
}

class _PostArticlesState extends State<PostArticles> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedSpecialization;
  File? _selectedImage;

  final List<String> specializations = [
    'Cardiologist',
    'Dermatologist',
    'Psychiatrist',
    'Orthopedic',
    'General Physician',
    'Pediatrician',
    'Oncologist',
    'Neurologist',
    'Gynecologist',
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitArticle() {
    if (_formKey.currentState!.validate() && _selectedSpecialization != null) {
      // You can send data to Firebase or any backend here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article Submitted Successfully!')),
      );
      // Clear form
      _formKey.currentState!.reset();
      setState(() {
        _selectedSpecialization = null;
        _selectedImage = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Share Your Medical Insight',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Article Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'Enter article title' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Specialization',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedSpecialization,
                items: specializations.map((spec) {
                  return DropdownMenuItem<String>(
                    value: spec,
                    child: Text(spec),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialization = value;
                  });
                },
                validator: (value) => value == null ? 'Select specialization' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Article Content',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'Enter article content' : null,
              ),
              SizedBox(height: 16),
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_selectedImage!, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              SizedBox(height: 10),
              OutlinedButton.icon(
                icon: Icon(Icons.image, color: Colors.deepPurple),
                label: Text('Attach Image', style: TextStyle(color: Colors.deepPurple)),
                onPressed: _pickImage,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.deepPurple),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.send,color: Colors.white,),
                label: Text('Submit Article',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitArticle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
