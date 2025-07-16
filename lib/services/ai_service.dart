import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vettore/models/color_component_model.dart';
import 'package:vettore/services/settings_service.dart';

class AIService {
  final SettingsService _settingsService;

  AIService({required SettingsService settingsService})
    : _settingsService = settingsService;

  Future<Map<String, dynamic>> importRecipeFromImage(
    Uint8List imageData,
  ) async {
    if (!_settingsService.isGeminiApiEnabled) {
      throw Exception('The Gemini API is disabled in settings.');
    }
    final apiKey = _settingsService.geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('The Gemini API key is not set in settings.');
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final prompt = TextPart(
      'Analyze the attached image which contains a color recipe. On the left side of the image, there are two colored rectangular areas. Identify the one that is furthest to the left. Determine the uniform RGB color of that specific, leftmost area. Also, extract the color components and their percentages from the right side of the image. Return the data ONLY as a valid JSON object with two keys: "recipeTitleColor" (as an object with "r", "g", and "b" integer keys) and "components" (as an array where each object has a "name" and a "percentage" key).',
    );

    final imagePart = DataPart('image/jpeg', imageData);

    try {
      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      if (response.text == null) {
        throw Exception('Received null response from API');
      }

      final String cleanedJson = response.text!
          .replaceAll('`', '')
          .replaceAll('json', '')
          .trim();

      final Map<String, dynamic> decodedJson = jsonDecode(cleanedJson);

      final componentsData = decodedJson['components'] as List<dynamic>? ?? [];
      final recipeTitleColor =
          decodedJson['recipeTitleColor'] as Map<String, dynamic>?;

      final components = componentsData.map((item) {
        final name = item['name'] as String?;
        final percentage = item['percentage'] as num?;

        if (name == null || percentage == null) {
          throw Exception(
            'Invalid data format in JSON response for components',
          );
        }

        return ColorComponent(name: name, percentage: percentage.toDouble());
      }).toList();

      return {'components': components, 'recipeTitleColor': recipeTitleColor};
    } catch (e) {
      print('Error parsing recipe from image: $e');
      // Re-throw the exception to be handled by the caller
      rethrow;
    }
  }
}
