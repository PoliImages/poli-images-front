import 'package:flutter/material.dart';

void main() {
  runApp(const PoliImagesApp());
}

class PoliImagesApp extends StatelessWidget {
  const PoliImagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poli Images',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define a fonte padrão da aplicação
        fontFamily: 'Roboto',
        // Define as cores principais
        primarySwatch: Colors.teal,
        // Remove a faixa de "debug" no canto
      ),
      home: const RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores para ler o texto dos campos de e-mail e senha
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Função que será chamada quando o botão "Continuar" for pressionado
  void _handleRegister() {
    // Pegamos os valores digitados nos campos
    final email = _emailController.text;
    final password = _passwordController.text;

    // Por enquanto, vamos apenas imprimir no console para testar
    print('Tentativa de cadastro com:');
    print('E-mail: $email');
    print('Senha: $password');

    // --- PONTO DE CONEXÃO COM O BACKEND ---
    // É aqui que você fará a chamada HTTP para a sua API.
    // A rota no seu backend poderia ser, por exemplo: POST /api/auth/register
    // O corpo da requisição enviaria um JSON como: {"email": email, "password": password}
    //
    // Exemplo de como seria com o pacote http:
    //
    // final response = await http.post(
    //   Uri.parse('http://seu-backend.com/api/auth/register'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'email': email, 'password': password}),
    // );
    //
    // if (response.statusCode == 201) {
    //   // Cadastro bem-sucedido, navegar para a próxima tela
    // } else {
    //   // Mostrar um erro para o usuário
    // }
  }

  // É importante limpar os controladores quando a tela é destruída para liberar memória
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold é o esqueleto básico de uma página no Material Design
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Barra no topo da aplicação
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove a sombra
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[800]),
          onPressed: () {
            // Ação para o menu sanduíche
          },
        ),
        title: Row(
          children: [
            // Ícone representando a logo
            Icon(Icons.widgets, color: Colors.teal[400]),
            const SizedBox(width: 8),
            const Text(
              'Poliedro',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // Corpo da página
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Texto de boas-vindas
              const Text(
                'Seja bem-vindo\nPoli Images!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              // Cartão de cadastro
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Crie uma conta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Campo de E-mail
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          hintText: 'Inserir e-mail institucional',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Campo de Senha
                      TextField(
                        controller: _passwordController,
                        obscureText: true, // Esconde o texto da senha
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          hintText: 'Inserir senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botão Continuar
                      _buildGradientButton(),
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

  // Widget separado para construir o botão com gradiente
  Widget _buildGradientButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00A9B8), Color(0xFF00C7B3)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: ElevatedButton(
          onPressed: _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50), // Ocupa toda a largura
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}