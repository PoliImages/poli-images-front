import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageService {
  // Carrega a URL do SEU BACKEND a partir do .env do Frontend
  static final String _baseUrl = dotenv.env['BASE_URL']!;

  // A função initialize() agora é apenas um placeholder no Frontend
  static void initialize() {
    // A chave da API NÃO é inicializada aqui. Apenas a lógica do Backend a tem.
  }

  static Future<String> generateImage(String prompt) async {
    try {
      // Chama o endpoint seguro no SEU Backend (http://localhost:8080/api/generate-image)
      final url = Uri.parse('$_baseUrl/api/generate-image');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Recebe a URL da imagem do Backend
        return data['imageUrl'];
      } else {
        // Se o servidor retornar erro (403, 500, etc.)
        final errorData = json.decode(response.body);
        throw Exception('Falha ao gerar imagem no servidor: ${errorData['message'] ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      print('Erro ao comunicar com o Backend: $e');
      // O erro é re-lançado para ser tratado no ChatbotPage
      rethrow;
    }
  }
}
