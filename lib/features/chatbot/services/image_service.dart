import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageService {
  // 🚨 ATENÇÃO: Defina BASE_URL no seu .env do Flutter como:
  // BASE_URL=http://10.0.2.2:8080 (para Android Emulator)
  // BASE_URL=http://localhost:8080 (para iOS Simulator/Web)
  static final String _baseUrl = dotenv.env['BASE_URL']!;
  
  // 🚨 TOKEN DE AUTENTICAÇÃO: SUBSTITUA POR UM TOKEN JWT VÁLIDO, 
  // assinado com a chave secreta do seu arquivo .env do back-end.
  static const String _AUTH_TOKEN = 'SEU_TOKEN_JWT_VÁLIDO_AQUI'; 

  static void initialize() {
    // Placeholder.
  }

  // Recebe prompt e style separadamente
  static Future<String> generateImage(String prompt, String style) async {
    try {
      // A rota é /api/generate-image
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
          // 🚨 AUTENTICAÇÃO CORRIGIDA
          'Authorization': 'Bearer $_AUTH_TOKEN', 
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['imageUrl'];
        if (imageUrl == null || imageUrl.isEmpty) {
             throw Exception('Resposta do Backend não contém URL da imagem.');
        }
        return imageUrl;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Erro desconhecido';
        
        if (response.statusCode == 401 || response.statusCode == 403) {
           throw Exception('Acesso negado (Status ${response.statusCode}). Verifique o Token JWT. Mensagem: $errorMessage');
        }
        
        throw Exception('Falha ao gerar imagem no servidor (Status ${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('Erro ao comunicar com o Backend: $e');
      throw Exception('Falha de conexão com o Back-end. Verifique se o servidor (${_baseUrl}) está online e na porta 8080. Erro: $e');
    }
  }
}