import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; //checa o ambiente. verifica se está rodando na web
import 'package:flutter/widgets.dart'; //checa a plataforma. verifica qual S.O. hospeda o app(android, ios, linux)
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // --- NOVO GETTER _baseUrl (SOLUÇÃO DE AMBIENTE) ---
  String get _baseUrl {
    // LÊ as variáveis do arquivo .env
    final String localIp = dotenv.env['DEVICE_IP'] ?? '127.0.0.1';
    final String port = dotenv.env['SERVER_PORT'] ?? '8080';
    final String ngrokUrl = dotenv.env['NGROK_URL'] ?? '';

    if (ngrokUrl.isNotEmpty) {
      return ngrokUrl; 
    }

    // 1. Checa se é Web (Chrome) ou Desktop (Windows)
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      return 'http://127.0.0.1:$port';
    }
    // 2. Checa se é um dispositivo Físico (Android/iOS)
    return 'http://$localIp:$port';
  }

  // --- MÉTODO DE LOGIN (NOVO) ---
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    // A URL agora aponta para a nova rota de login
    final url = Uri.parse('$_baseUrl/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final responseBody = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Erro desconhecido.',
      };
    } catch (e) {
      print('Erro de conexão na AuthService (login): $e');
      return {
        'statusCode': 503,
        'message': 'Não foi possível conectar ao servidor. Verifique sua conexão e o IP.',
      };
    }
  }


  // Método para registrar um novo usuário
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          // CORREÇÃO 2: Corrigido de UTF-T para UTF-8
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password, // No backend, 'password' é o CPF
        }),
      );

      final responseBody = jsonDecode(response.body);

      // Retornamos um mapa com o status e a mensagem do servidor
      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Erro desconhecido.',
      };
    } catch (e) {
      // Captura erros de conexão (servidor offline, IP errado, etc.)
      print('Erro de conexão na AuthService: $e');
      return {
        'statusCode': 503, // Service Unavailable
        'message': 'Não foi possível conectar ao servidor. Verifique sua conexão e o IP.',
      };
    }
  }
}
