import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ¡IMPORTANTE! Reemplaza 'TU_API_KEY_REAL' con tu API Key actual de Google Gemini.
  // Recuerda que hardcodearla no es lo más seguro para producción.
  static const String _apiKey = 'AIzaSyBZUUal0DLkceJwScxBWdW8vLWE1ldiuoQ'; 
  
  static const String _modelName = 'gemini-1.5-flash';

  late final GenerativeModel _model;

  GeminiService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: _getGenerationConfig(),
      safetySettings: _getSafetySettings(),
    );
  }

  GenerationConfig _getGenerationConfig() => GenerationConfig(
        temperature: 0.9,
        topK: 1,
        topP: 1,
        maxOutputTokens: 2048,
      );

  List<SafetySetting> _getSafetySettings() => [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ];

  Future<String> getResponse(String prompt) async {
    try {
      // --- MODIFICACIÓN CLAVE AQUÍ ---
      // Prepara el prompt con las instrucciones de contexto y idioma
      final String formattedPrompt = '''
      Habla solo sobre la Universidad Católica Boliviana "San Pablo" (UCB). Debo brindar cualquier tipo de informacion, sobre sus carreras, todo, pued buscar en internet y asi proporcionar datos reales y actualizados, tambien debo usar emojis y hablar al usuario de la manera mas amable posible.

      Pregunta del usuario: "$prompt"
      ''';
      // -------------------------------

      final content = Content.text(formattedPrompt); // Envía el prompt formateado
      final response = await _model.generateContent([content]);
      
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  String _processResponse(GenerateContentResponse response) {
    if (response.text == null || response.text!.isEmpty) {
      return 'No recibí una respuesta válida. ¿Podrías reformular tu pregunta?';
    }
    
    return response.text!
        .replaceAll('**', '')
        .replaceAll('*', '')
        .trim();
  }

  String _handleError(dynamic error) {
    if (error is Exception) {
      try {
        return 'Error de la API: ${error.toString()}';
      } catch (e) {
        return 'Error inesperado: ${e.toString()}';
      }
    }
    return 'Error desconocido: ${error.toString()}';
  }
}