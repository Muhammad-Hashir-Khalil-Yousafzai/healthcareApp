import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'MyReelsScreen.dart';

class AddReelScreen extends StatefulWidget {
  const AddReelScreen({Key? key}) : super(key: key);

  @override
  State<AddReelScreen> createState() => _AddReelScreenState();
}

class _AddReelScreenState extends State<AddReelScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _videoFile;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
      });
    }
  }

  void _uploadReel() {
    if (_captionController.text.isEmpty || _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please add a caption and select a video."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Upload logic goes here

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Reel uploaded successfully!"),
        backgroundColor: Colors.deepPurple,
      ),
    );

    setState(() {
      _captionController.clear();
      _videoFile = null;
    });
  }

  void _goToMyReels() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyReelsScreen()),
    );
  }

  Widget _buildVideoBox() {
    return GestureDetector(
      onTap: _pickVideo,
      child: DottedBorder(
        color: Colors.deepPurple,
        strokeWidth: 2,
        dashPattern: [6, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(12),
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _videoFile == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_call, size: 48, color: Colors.deepPurple),
              SizedBox(height: 8),
              Text(
                'Tap to upload a video',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ],
          )
              : Center(
            child: Text(
              "Video Selected: ${_videoFile!.path.split('/').last}",
              style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Add Reel"),
        actions: [
          IconButton(
            icon: Icon(Icons.video_library),
            tooltip: 'View My Reels',
            onPressed: _goToMyReels,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _captionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Caption",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildVideoBox(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _uploadReel,
                icon: Icon(Icons.cloud_upload,color: Colors.white,),
                label: Text("Upload Reel"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
