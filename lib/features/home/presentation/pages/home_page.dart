import 'package:flutter/material.dart';
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
          backgroundColor: Colors.white, 
          appBar: _buildAppBar(context, isDesktop),
          drawer: isDesktop ? null : const AppDrawer(),
          body: _buildBody(context, isDesktop),
        );
      },
    );
  }

  void navigateToChatbot(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ChatbotPage()),
    );
  }

  void navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop) {
    const Color appBarColor = Colors.white; 
    const Color iconTextColor = Colors.black; 

    if (isDesktop) {
      return AppBar(
        backgroundColor: appBarColor, 
        automaticallyImplyLeading: false,
        elevation: 1,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, 
            children: [
              const SizedBox(width: 50),
              
              InkWell(
                onTap: () => navigateToHome(context),
                child: Row(
                  children: [
                    Image.asset('assets/logo_polimages.png', height: 27),
                    const SizedBox(width: 8),
                    const Text(
                      'Poli Images', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.black
                      ),
                      ),
                  ],
                ),
              ),
              
              const Spacer(), 

              Row(
                children: [
                  _buildNavButton(
                    text: 'Página Inicial', 
                    icon: Icons.home, 
                    onPressed: () {},
                    iconTextColor: iconTextColor,
                  ),
                  const SizedBox(width: 10),
                  _buildNavButton(
                    text: 'Gerar Nova Imagem', 
                    icon: Icons.chat, 
                    onPressed: () => navigateToChatbot(context),
                    iconTextColor: iconTextColor,
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
                    iconTextColor: iconTextColor,
                  ),
                  
                  const SizedBox(width: 20), 
                  
                  _buildNavButton(
                    text: 'Deslogar',
                    icon: Icons.logout,
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    iconTextColor: iconTextColor,
                  ),
                  const SizedBox(width: 50),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return AppBar(
        backgroundColor: appBarColor, 
        elevation: 1,
        title: InkWell(
          onTap: () => navigateToHome(context),
          child: Row(
            children: [
              Image.asset('assets/logo_polimages.png', height: 27),
              const SizedBox(width: 8),
              const Text(
                'Poli Images',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), 
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: iconTextColor), 
        actions: const [],
      );
    }
  }

  Widget _buildBody(BuildContext context, bool isDesktop) {
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
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              card1, 
              const SizedBox(height: 24),
              card2, 
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
    required Color iconTextColor, 
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: iconTextColor, size: 18), 
      label: Text(text, style: TextStyle(color: iconTextColor, fontWeight: FontWeight.w600)), 
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(Colors.black.withOpacity(0.1)), 
      ),
    );
  }
}