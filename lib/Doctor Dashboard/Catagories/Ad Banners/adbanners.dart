import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddBanner extends StatefulWidget {
  @override
  _AddBannerState createState() => _AddBannerState();
}

class _AddBannerState extends State<AddBanner> {
  File? _pickedImage;
  List<File> _banners = [];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _addBanner() {
    if (_pickedImage != null) {
      setState(() {
        _banners.add(_pickedImage!);
        _pickedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Banner added successfully"),
        backgroundColor: Colors.deepPurple,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select a banner image"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _deleteBanner(int index) {
    setState(() {
      _banners.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Banner deleted"),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Add Banner', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Upload Banner Image", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _pickedImage == null
                    ? Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.deepPurple))
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_pickedImage!, fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _addBanner,
                icon: Icon(Icons.check, color: Colors.white),
                label: Text('Add Banner', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 30),
            Divider(color: Colors.deepPurple),
            Text("Added Banners", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 10),
            ..._banners.asMap().entries.map((entry) {
              int index = entry.key;
              File imageFile = entry.value;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: FileImage(imageFile)),
                  title: Text("Banner", style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBanner(index),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
