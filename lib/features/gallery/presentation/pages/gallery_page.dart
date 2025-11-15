import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define o breakpoint para responsividade
        final bool isDesktop = constraints.maxWidth > 768;

        return Scaffold(
          // Fundo branco no desktop, cinza claro no mobile
          backgroundColor: isDesktop ? Colors.white : Colors.grey[100],
          // Reutiliza a AppBar do layout principal
          appBar: _buildAppBar(context, isDesktop),
          // A gaveta lateral é usada apenas no mobile
          drawer: isDesktop ? null : const AppDrawer(),
          body: _buildBody(context, isDesktop),
        );
      },
    );
  }

  // --- Funções de Componentes Comuns (Mantidas para consistência visual) ---

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop) {
    final Color desktopAppBarColor = const Color(0xFF00A9B8); // Cor da AppBar do desktop

    // navega para a HomePage
    void navigateToHome(BuildContext context) {
      // Usa pushAndRemoveUntil para limpar a pilha de navegação e ir para a HomePage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    }
    
    // navega para a ChatbotPage
    void navigateToChatbot(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ChatbotPage()),
      );
    }

    // AppBar para Desktop
    if (isDesktop) {
      return AppBar(
        backgroundColor: desktopAppBarColor,
        automaticallyImplyLeading: false,
        elevation: 1,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          // REMOVIDO: Padding horizontal aqui para que o conteúdo fique colado nas bordas de 1200px
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Torna a logo e o texto "Poli Images" clicáveis (Desktop)
              InkWell(
                onTap: () => navigateToHome(context), // Navega para a HomePage
                child: Row(
                  children: [
                    Image.asset('assets/logo_poliedro.png', height: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Poli Images',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Mantém branco no desktop
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildNavButton(text: 'Página Inicial', icon: Icons.home, onPressed: () {
                    // Simular navegação de volta (pop)
                    Navigator.of(context).pop();
                  }),
                  const SizedBox(width: 10),
                  // AÇÃO MODIFICADA AQUI: Navega para a ChatbotPage
                  _buildNavButton(
                      text: 'Gerar Nova Imagem', 
                      icon: Icons.chat, 
                      onPressed: () => navigateToChatbot(context),
                    ),
                  const SizedBox(width: 10),
                  // Botão da Galeria Ativo
                  _buildNavButton(text: 'Galeria de Fotos', icon: Icons.photo_library, onPressed: () {}),
                  const SizedBox(width: 10),
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
      );
    } else {
      // AppBar para Mobile (Cor e estilo ajustados)
      return AppBar(
        backgroundColor: desktopAppBarColor, // Cor da navbar do desktop
        elevation: 1,
        title: InkWell( // Torna a logo e o texto "Poli Images" clicáveis (Mobile)
          onTap: () => navigateToHome(context), // Navega para a HomePage
          child: Row(
            children: [
              Image.asset('assets/logo_poliedro.png', height: 24), // Usando a logo Poliedro
              const SizedBox(width: 8),
              const Text(
                'Poli Images',
                style: TextStyle(
                  color: Colors.white, // Texto branco para contrastar com o fundo azul
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Ícone do drawer branco
        actions: const [
        ],
      );
    }
  }

  Widget _buildNavButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    // Mantido idêntico ao original
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

  // --- Implementação do Body da Galeria ---

  Widget _buildBody(BuildContext context, bool isDesktop) {
    // Dados simulados das pastas/matérias
    final List<String> subjects = [
      'Português',
      'Matemática',
      'Biologia',
      'História',
      'Geografia',
      'Inglês',
      'Física',
      'Química',
    ];

    // Configuração do GridView (4 colunas no desktop, 2 no mobile)
    final int crossAxisCount = isDesktop ? 4 : 2;
    // Padding padrão para as laterais
    final double horizontalPadding = isDesktop ? 50.0 : 16.0;
    // Espaço adicional para a barra de rolagem no Desktop
    final double rightPaddingWithScrollbar = isDesktop ? 50.0 + 20.0 : 16.0;


    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: rightPaddingWithScrollbar, // Padding ajustado para a barra de rolagem
            top: 20,
            bottom: 20
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com Ícone de Voltar e Título CENTRALIZADO (usando Stack)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Título Centralizado
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
                  // Botão de Voltar (alinhado à esquerda)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, size: isDesktop ? 30 : 24, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop(); // Volta para a tela anterior (HomePage)
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30), // Espaçamento após o título (substituindo o Divider)
              
              // GridView com as Pastas
              Expanded(
                // O widget Scrollbar é usado para exibir a barra de rolagem
                child: Scrollbar(
                  // Garante que a barra de rolagem seja visível no desktop
                  thumbVisibility: isDesktop,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isDesktop ? 30 : 16,
                      mainAxisSpacing: isDesktop ? 30 : 16,
                      childAspectRatio: 0.85, // Proporção para o card da pasta
                    ),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      return _buildSubjectCard(
                        subject: subjects[index],
                        onTap: () {
                          // Implemente a navegação para a pasta da matéria aqui
                          debugPrint('Pasta ${subjects[index]} clicada');
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para simular o card de pasta da imagem
  Widget _buildSubjectCard({
    required String subject,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shadowColor: const Color(0xFF00A9B8).withOpacity(0.1),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagem da Pasta
              Container(
                width: 120,
                height: 120,
                child: Image.asset(
                  'assets/pasta_galeria.png',
                  fit: BoxFit.contain,
                  height: 120,
                  width: 120,
                ),
              ),
              const SizedBox(height: 16),
              // Nome do Assunto
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  subject,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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