import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // ATENÇÃO: Verifique se este IP ainda é o IP da sua máquina
  // CORREÇÃO 1: Adicionada a porta :8080 no final da URL
  final String _baseUrl = 'http://10.2.2.115:8080';

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
