import 'package:flutter/material.dart';
// Importa nossa nova página de cadastro organizada
import 'features/auth/presentation/pages/register_page.dart';

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
        fontFamily: 'Roboto',
        primarySwatch: Colors.teal,
      ),
      home: const RegisterPage(),
    );
  }
}
