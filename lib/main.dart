import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared/services/image_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../shared/services/image_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await ImageRepository().load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ImageRepository(),
      child: const PoliImagesApp(),
    ),
  );
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
      home: const LoginPage(),
    );
  }
}
