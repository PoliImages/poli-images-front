import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageService {
  static final String _baseUrl = dotenv.env['BASE_URL']!; 
  
  static void initialize() {
  }

  static Future<String> generateImage(String prompt, String style) async {
    try {
      final url = Uri.parse('$_baseUrl/api/generate-image');
      print('Enviando requisição para o Backend: $url com prompt: $prompt e style: $style');
      
      final body = json.encode({
        'prompt': prompt,
        'style': style,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final base64Image = data['base64Image'];
        
        if (base64Image == null || base64Image.isEmpty) {
          throw Exception('Resposta do Backend não contém imagem codificada em Base64.');
        }
        return base64Image; 
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Erro desconhecido';
        
        throw Exception('Falha ao gerar imagem no servidor (Status ${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('Erro ao comunicar com o Backend: $e');
      throw Exception('Falha de conexão com o Back-end. Verifique se o servidor (${_baseUrl}) está online. Erro: $e');
    }
  }
}