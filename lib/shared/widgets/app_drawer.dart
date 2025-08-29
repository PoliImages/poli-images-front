import 'package:flutter/material.dart';
import 'package:poli_images_front/features/auth/presentation/pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal[400],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Poli Images',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Navegue pelo App',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home_outlined,
            text: 'Página Inicial',
            onTap: () {
              // Já estamos na home, então apenas fechamos o drawer
              Navigator.of(context).pop();
            },
          ),
          _buildDrawerItem(
            icon: Icons.chat_bubble_outline,
            text: 'Gerar Nova Imagem',
            onTap: () {
              // TODO: Navegar para a página de Chat
            },
          ),
          _buildDrawerItem(
            icon: Icons.photo_library_outlined,
            text: 'Galeria de Fotos',
            onTap: () {
              // TODO: Navegar para a página de Galeria
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            text: 'Minha Conta',
            onTap: () {
              // TODO: Navegar para a página da conta do usuário
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Deslogar',
            onTap: () {
              // Navega para a tela de login e remove todas as outras telas da pilha
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

  // Widget auxiliar para criar os itens do menu
  ListTile _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
