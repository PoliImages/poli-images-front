import 'package:flutter/material.dart';
// Certifique-se de que estes imports apontem para os locais corretos no seu projeto
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/pages/login_page.dart';


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
    // AppBar para Desktop
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
                    // Simulação do logo (use Icons.palette no lugar de Image.asset)
                    const Icon(Icons.palette, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    const Text('Poli Images', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    _buildNavButton(text: 'Página Inicial', icon: Icons.home, onPressed: () {
                      // Simular navegação de volta (pop)
                      Navigator.of(context).pop();
                    }),
                    const SizedBox(width: 10),
                    _buildNavButton(text: 'Gerar Nova Imagem', icon: Icons.chat, onPressed: () {}),
                    const SizedBox(width: 10),
                    // Botão da Galeria Ativo
                    _buildNavButton(text: 'Galeria de Fotos', icon: Icons.photo_library, onPressed: () {}),
                    const SizedBox(width: 10),
                    _buildNavButton(text: 'Minha Conta', icon: Icons.person, onPressed: () {}),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // AppBar para Mobile
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.palette, color: Color(0xFF00A9B8), size: 24),
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
    final double horizontalPadding = isDesktop ? 50.0 : 16.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com Ícone de Voltar e Título
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: isDesktop ? 30 : 24, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop(); // Volta para a tela anterior (HomePage)
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Galeria de fotos',
                    style: TextStyle(
                      fontSize: isDesktop ? 30 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              
              // GridView com as Pastas
              Expanded(
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
                        // Por exemplo: Navigator.of(context).push(MaterialPageRoute(builder: (context) => SubjectDetailPage(subject: subjects[index])));
                        debugPrint('Pasta ${subjects[index]} clicada');
                      },
                    );
                  },
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
              // Simulação da Imagem da Pasta (Icon)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.folder_shared_outlined, 
                  color: Color(0xFF00A9B8), 
                  size: 60
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
