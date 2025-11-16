import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart'; 


class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  static const Color appBarColor = Colors.white; 
  static const Color iconTextColor = Colors.black; 

  void navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }
  
  void navigateToChatbot(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ChatbotPage()),
    );
  }

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

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop) {
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
                        color: iconTextColor,
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
                    onPressed: () => navigateToHome(context), 
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
                    onPressed: () {}, 
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
                style: TextStyle(
                  color: iconTextColor, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: iconTextColor), 
        actions: const [], 
      );
    }
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

  Widget _buildBody(BuildContext context, bool isDesktop) {
    final double horizontalPadding = isDesktop ? 50.0 : 16.0;
    final double rightPaddingWithScrollbar = isDesktop ? 50.0 + 20.0 : 16.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.only(
            left: 0, 
            right: rightPaddingWithScrollbar, 
            top: 20,
            bottom: 20
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Galeria de fotos',
                      style: TextStyle(
                        fontSize: isDesktop ? 30 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10), 
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, size: isDesktop ? 30 : 24, color: Colors.black),
                        onPressed: () {
                          Navigator.of(context).pop(); 
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30), 
              
              Center( 
                child: Text(
                  'Nenhuma imagem encontrada.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}