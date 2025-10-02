import 'package:flutter/material.dart';
// 1. Importa a página de LOGIN em vez da de cadastro
import 'features/auth/presentation/pages/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; //carreca o arquivo .env

Future<void> main() async {
  // 2. GARANTE que o Flutter esteja pronto para carregar assets (arquivos .env)
  WidgetsFlutterBinding.ensureInitialized(); 

  // 3. CARREGA o arquivo .env (deve ser feito antes de chamar runApp)
  await dotenv.load(fileName: ".env");

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
        fontFamily: 'Roboto',
        primarySwatch: Colors.teal,
      ),
      // 2. AQUI ESTÁ A CORREÇÃO: O app agora começa na LoginPage
      home: const LoginPage(),
    );
  }
}
