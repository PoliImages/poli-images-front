import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  String get _baseUrl {
    final String localIp = dotenv.env['DEVICE_IP'] ?? '127.0.0.1';
    final String port = dotenv.env['SERVER_PORT'] ?? '8080';
    final String ngrokUrl = dotenv.env['NGROK_URL'] ?? '';

    if (ngrokUrl.isNotEmpty) {
      return ngrokUrl; 
    }

    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      return 'http://127.0.0.1:$port';
    }
    return 'http://$localIp:$port';
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
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

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'message': responseBody['message'] ?? 'Erro desconhecido.',
      };
    } catch (e) {
      print('Erro de conexão na AuthService: $e');
      return {
        'statusCode': 503,
        'message': 'Não foi possível conectar ao servidor. Verifique sua conexão e o IP.',
      };
    }
  }
}
