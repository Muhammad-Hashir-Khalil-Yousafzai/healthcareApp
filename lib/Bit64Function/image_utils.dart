import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Converts a File image to a Base64 string
Future<String> imageFileToBase64(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  return base64Encode(bytes);
}

/// Upload Base64 string image to Firestore under a specific document and field
Future<void> uploadBase64ImageToFirestore({
  required String collection,
  required String docId,
  required String field,
  required String base64Image,
}) async {
  await FirebaseFirestore.instance
      .collection(collection)
      .doc(docId)
      .set({field: base64Image}, SetOptions(merge: true));
}

/// Converts a Base64 string to an Image widget
Image base64ToImageWidget(String base64String) {
  final bytes = base64Decode(base64String);
  return Image.memory(bytes);
}
