import 'package:flutter/material.dart';
// Importação da página real do chatbot.
import '../../../chatbot/presentation/pages/chatbot_page.dart'; 
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 768;

        return Scaffold(
          backgroundColor: isDesktop ? Colors.white : Colors.grey[100],
          appBar: _buildAppBar(context, isDesktop),
          drawer: isDesktop ? null : const AppDrawer(),
          body: _buildBody(context, isDesktop),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return AppBar(
        backgroundColor: const Color(0xFF00A9B8),
        automaticallyImplyLeading: false,
        elevation: 1,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/logo_poliedro.png', height: 24),
                    const SizedBox(width: 8),
                    const Text('Poli Images', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    _buildNavButton(text: 'Página Inicial', icon: Icons.home, onPressed: () {}),
                    const SizedBox(width: 10),
                    // AJUSTE NA NAVEGAÇÃO 1: Botão "Gerar Nova Imagem" no AppBar (Desktop)
                    _buildNavButton(
                      text: 'Gerar Nova Imagem', 
                      icon: Icons.chat, 
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ChatbotPage()),
                        );
                      }
                    ),
                    const SizedBox(width: 10),
                    _buildNavButton(
                      text: 'Galeria de Fotos', 
                      icon: Icons.photo_library, 
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const GalleryPage()),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildNavButton(text: 'Minha Conta', icon: Icons.person, onPressed: () {}),
                    const SizedBox(width: 20), // Espaço maior antes do botão de sair
                    _buildNavButton(
                      text: 'Deslogar',
                      icon: Icons.logout,
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // AppBar para Telas Pequenas (Mobile) - Sem alterações aqui
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Image.asset('assets/logo_poliedro.png', height: 24),
            const SizedBox(width: 8),
            const Text(
              'Poli Images',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.grey[800]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[800]),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildBody(BuildContext context, bool isDesktop) {
    // AJUSTE NA NAVEGAÇÃO 2: Botão "Gerar Nova Imagem" no Card (Corpo da Página)
    final card1 = _buildFeatureCard(
      context: context,
      imagePath: 'assets/gerar_imagem.png',
      buttonText: 'Gerar Nova Imagem',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ChatbotPage()),
        );
      },
    );

    final card2 = _buildFeatureCard(
      context: context,
      imagePath: 'assets/galeria.png',
      buttonText: 'Minha Galeria de Fotos',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder:(context) => const GalleryPage()),
        );
      },
    );

    if (isDesktop) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: card1),
                const SizedBox(width: 60),
                Expanded(child: card2),
              ],
            ),
          ),
        ),
      );
    } else {
      // Layout para Telas Pequenas (Mobile)
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Usa o card1 já configurado com a navegação
              card1, 
              const SizedBox(height: 24),
              _buildFeatureCard(
                context: context,
                imagePath: 'assets/galeria.png',
                buttonText: 'Galeria de Fotos',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GalleryPage()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String imagePath,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 250,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A9B8),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
      ),
    );
  }
}
