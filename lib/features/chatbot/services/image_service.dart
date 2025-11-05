import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageService {
  // 🚨 ATENÇÃO: Defina BASE_URL no seu .env do Flutter como:
  // BASE_URL=http://10.0.2.2:8080 (para Android Emulator)
  // BASE_URL=http://localhost:8080 (para iOS Simulator/Web)
  static final String _baseUrl = dotenv.env['BASE_URL']!; 
  
  // ❌ REMOVIDO: O Token JWT fixo e o campo _AUTH_TOKEN não são mais necessários.

  static void initialize() {
    // Placeholder.
  }

  // Recebe prompt e style separadamente e agora retorna uma STRING BASE64
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
          // ❌ REMOVIDO: O header de autenticação
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // ✅ MUDANÇA PRINCIPAL: Esperamos uma chave 'base64Image' no JSON
        final base64Image = data['base64Image'];
        
        if (base64Image == null || base64Image.isEmpty) {
          throw Exception('Resposta do Backend não contém imagem codificada em Base64.');
        }
        // Retorna a string Base64
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