import 'package:flutter/material.dart';
import 'package:poli_images_front/features/auth/presentation/pages/login_page.dart';
import 'package:poli_images_front/features/home/presentation/pages/home_page.dart'; 
import 'package:poli_images_front/features/chatbot/presentation/pages/chatbot_page.dart'; 
import 'package:poli_images_front/features/gallery/presentation/pages/gallery_page.dart'; 

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateToHomeAndClearStack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); 
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color desktopAppBarColor = Colors.white; 
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white, 
            ),
            child: InkWell(
              onTap: () => _navigateToHomeAndClearStack(context),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Image(
                        image: AssetImage('assets/logo_poliedro.png'), 
                        height: 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Poli Images',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home, 
            text: 'Página Inicial',
            onTap: () {
              _navigateToHomeAndClearStack(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.chat, 
            text: 'Gerar Nova Imagem',
            onTap: () {
              Navigator.of(context).pop(); 
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ChatbotPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.photo_library, 
            text: 'Galeria de Fotos',
            onTap: () {
              Navigator.of(context).pop(); 
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GalleryPage()),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Deslogar',
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text, style: const TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }
}