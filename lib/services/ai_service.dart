import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
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
      'Analyze the attached image which contains a color recipe. Each line contains a number, a color name, and a percentage. You must ignore the number at the beginning of each line. Extract only the color name and its corresponding percentage. Return the data ONLY as a valid JSON object with one key: "components" (as an array where each object has a "name" (string) and a "percentage" (number, not a string) key).',
    );

    final imagePart = DataPart('image/jpeg', imageData);

    try {
      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      if (response.text == null) {
        throw Exception('Received null response from API');
      }

      final String cleanedJson =
          response.text!.replaceAll('`', '').replaceAll('json', '').trim();

      final Map<String, dynamic> decodedJson = jsonDecode(cleanedJson);

      final componentsData = decodedJson['components'];

      if (componentsData == null ||
          componentsData is! List ||
          componentsData.isEmpty) {
        throw Exception(
            'The AI response did not contain a valid list of components. Raw response: ${response.text}');
      }

      // TODO: This part needs to be adapted to the new data model
      // For now, we will return the raw data and process it in the UI layer.
      /*
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
      */

      return {
        'components': componentsData,
      };
    } catch (e) {
      print('Error parsing recipe from image: $e');
      // Re-throw the exception to be handled by the caller
      rethrow;
    }
  }
}
