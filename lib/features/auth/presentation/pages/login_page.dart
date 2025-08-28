import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
// Importa a página de cadastro para podermos navegar até ela
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    // Chama o método de login do nosso serviço
    final result = await _authService.loginUser(
      email: email,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      _showFeedback(
        message: result['message'],
        isSuccess: result['statusCode'] == 200, // Sucesso no login é 200 OK
      );
    }
  }

  void _showFeedback({required String message, required bool isSuccess}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green[600] : Colors.red[600],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _navigateToRegister() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const RegisterPage(),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        // ... (AppBar idêntico ao da RegisterPage) ...
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (Título idêntico) ...
              const SizedBox(height: 40),
              Card(
                // ... (Estilo do Card idêntico) ...
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Acesse sua conta', // Texto alterado
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        // ... (Resto do TextField idêntico) ...
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        // ... (Resto do TextField idêntico) ...
                      ),
                      const SizedBox(height: 24),
                      _buildGradientButton(),
                      const SizedBox(height: 16),
                      _buildRegisterButton(), // Botão para ir para a tela de cadastro
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton() {
    return ClipRRect(
      // ... (Botão de gradiente idêntico, mas chama _handleLogin) ...
      child: ElevatedButton(
        onPressed: _handleLogin, // Chama a função de login
        // ... (Resto do estilo) ...
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Entrar', // Texto alterado
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: _navigateToRegister,
      child: Text(
        'Não tem uma conta? Cadastre-se',
        style: TextStyle(color: Colors.teal[400]),
      ),
    );
  }
}
