import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final model = GenerativeModel(
    model: 'gemini-pro-vision',
    apiKey: 'YOUR_API_KEY_HERE', // Replace with your Gemini API key
  );

  Future<String?> sendTextAndImage({
    required String text,
    required List<Uint8List> images,
  }) async {
    try {
      final content = [
        Content.multi([
          TextPart(text),
          for (final image in images)
            DataPart('image/png', image),
        ])
      ];

      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
