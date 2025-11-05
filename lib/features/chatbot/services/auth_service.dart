import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Note: O UserSessionManager é definido neste arquivo, por isso não precisa de import.

// 💡 CLASSE AUXILIAR para armazenamento global do ID
// Este gerenciador de sessão deve ser usado por outras partes do app (ex: ImageService)
class UserSessionManager {
  static String? _currentUserId;

  static String? get currentUserId => _currentUserId;

  // Método chamado APÓS o login bem-sucedido
  static void setUserId(String userId) {
    _currentUserId = userId;
    print('✅ Flutter Session: User ID definido: $_currentUserId');
    // Em um app real, você salvaria isso em SharedPreferences/SecureStorage
  }
  
  static bool isLoggedIn() => _currentUserId != null && _currentUserId!.isNotEmpty;
  
  // Opcional: Método para fazer logout
  static void logout() {
    _currentUserId = null;
    print('❌ Flutter Session: Usuário deslogado.');
  }
}
// FIM da CLASSE AUXILIAR

class AuthService {
  // O Backend Dart (Auth) está na porta 8080
  final String _baseUrl = dotenv.env['BASE_URL_AUTH'] ?? 'http://10.0.2.2:8080'; 

  // --- FUNÇÃO DE LOGIN ATUALIZADA ---
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/login');
      final body = json.encode({
        'email': email,
        'password': password, // O CPF
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // 💡 CORREÇÃO CRÍTICA: Capturar e Salvar o userId
        final userId = data['userId'] as String?;
        if (userId != null) {
          UserSessionManager.setUserId(userId); // Armazena o ID globalmente
        } else {
          return {'statusCode': 500, 'message': 'Login bem-sucedido, mas o servidor não retornou o ID do usuário.'};
        }
        
        return {'statusCode': 200, 'message': data['message']};

      } else {
        return {'statusCode': response.statusCode, 'message': data['message'] ?? 'Erro desconhecido.'};
      }
    } catch (e) {
      print('Erro de Login: $e');
      return {'statusCode': 500, 'message': 'Falha na comunicação com o servidor de autenticação.'};
    }
  }
  
  // --- FUNÇÃO DE REGISTRO (Mantida para fins de contexto, se o backend for implementado) ---
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': data['message'] ?? 'Erro desconhecido.',
      };
    } catch (e) {
      print('Erro de Registro: $e');
      return {'statusCode': 500, 'message': 'Falha na comunicação com o servidor de autenticação.'};
    }
  }
}