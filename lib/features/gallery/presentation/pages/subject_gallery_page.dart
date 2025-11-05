import 'package:flutter/material.dart';
import 'package:poli_images_front/features/auth/presentation/pages/login_page.dart';
import 'package:poli_images_front/features/home/presentation/pages/home_page.dart';
import 'package:poli_images_front/shared/widgets/app_drawer.dart';
import 'package:poli_images_front/features/auth/services/auth_service.dart'; // UserSessionManager
import 'package:poli_images_front/features/image/services/image_service.dart'; // ImageService e GalleryImage
// 💡 NOVO IMPORT: Importa a página de visualização de detalhes da matéria
import 'subject_detail_view.dart';


// 💡 NOVO: Esta página será um StatefulWidget para gerenciar o estado dos dados
class SubjectGalleryPage extends StatefulWidget {
  const SubjectGalleryPage({super.key});

  @override
  State<SubjectGalleryPage> createState() => _SubjectGalleryPageState();
}

class _SubjectGalleryPageState extends State<SubjectGalleryPage> {
  // Mapa onde a Chave é a Matéria (Subject) e o Valor é a Lista de Imagens
  Map<String, List<GalleryImage>> _galleryData = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGalleryData();
  }

  // --- 1. FUNÇÃO PRINCIPAL DE BUSCA DE DADOS ---
  Future<void> _fetchGalleryData() async {
    final userId = UserSessionManager.currentUserId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Usuário não autenticado. Por favor, faça login.';
      });
      return;
    }

    try {
      final data = await ImageService.fetchGallery(userId);
      setState(() {
        _galleryData = data;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Falha ao carregar a galeria: ${e.toString()}';
      });
    }
  }
  
  // --- 2. FUNÇÃO DE NAVEGAÇÃO PARA A VISUALIZAÇÃO DE DETALHE (CORRIGIDA) ---
  void _navigateToSubjectDetail(String subject, List<GalleryImage> images) {
    debugPrint('Navegando para o detalhe da pasta: $subject');
    
    // 🚀 NAVEGAÇÃO CORRIGIDA: Usa a SubjectDetailView e passa os dados necessários
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubjectDetailView(
          subject: subject, 
          images: images,
        ),
      ),
    );
  }

  // --- 3. WIDGET DE CONSTRUÇÃO (BUILD) ---

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

  // --- Implementação do Body da Galeria (Com tratamento de estado) ---

  Widget _buildBody(BuildContext context, bool isDesktop) {
    final double horizontalPadding = isDesktop ? 50.0 : 16.0;
    final double rightPaddingWithScrollbar = isDesktop ? 50.0 + 20.0 : 16.0;
    
    // Obter a lista de Matérias (Chaves)
    final List<String> subjects = _galleryData.keys.toList();
    final int crossAxisCount = isDesktop ? 4 : 2;

    Widget content;

    if (_isLoading) {
      content = const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF00A9B8)),
          SizedBox(height: 16),
          Text('Buscando suas pastas salvas...')
        ],
      ));
    } else if (_errorMessage != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Erro: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    } else if (subjects.isEmpty) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Você ainda não salvou nenhuma imagem. Vá para a seção "Gerar Nova Imagem" e comece a criar!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    } else {
      // GridView com as Pastas Reais
      content = Scrollbar(
        thumbVisibility: isDesktop,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isDesktop ? 30 : 16,
            mainAxisSpacing: isDesktop ? 30 : 16,
            childAspectRatio: 0.85, 
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            final images = _galleryData[subject]!;
            
            return _buildSubjectCard(
              subject: subject,
              imageCount: images.length, // Passa a contagem real
              onTap: () => _navigateToSubjectDetail(subject, images),
            );
          },
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: rightPaddingWithScrollbar,
            top: 20,
            bottom: 20
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDesktop), // Título e Botão de Voltar
              const SizedBox(height: 30), 
              Expanded(child: content), // Conteúdo central
            ],
          ),
        ),
      ),
    );
  }
  
  // --- 4. WIDGETS AUXILIARES ---

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Stack(
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
          child: IconButton(
            icon: Icon(Icons.arrow_back, size: isDesktop ? 30 : 24, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop(); 
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard({
    required String subject,
    required int imageCount,
    required VoidCallback onTap,
  }) {
    // Ícones simulados baseados na primeira letra
    IconData folderIcon;
    Color color;

    switch (subject.toLowerCase().substring(0, 1)) {
      case 'm':
      case 'f':
      case 'q':
        folderIcon = Icons.calculate; // Ex: Matemática, Física, Química
        color = Colors.blue.shade700;
        break;
      case 'b':
      case 'h':
      case 'g':
        folderIcon = Icons.menu_book; // Ex: Biologia, História, Geografia
        color = Colors.green.shade700;
        break;
      case 'p':
      case 'a':
        folderIcon = Icons.gavel; // Ex: Português, Arte
        color = Colors.orange.shade700;
        break;
      default:
        folderIcon = Icons.folder_open; // Outros/Diversos
        color = const Color(0xFF00A9B8);
    }
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.15),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icone da Pasta (Substitui a imagem estática)
              Icon(
                folderIcon,
                size: 80,
                color: color,
              ),
              const SizedBox(height: 16),
              // Nome do Assunto
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  subject,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Contagem de Imagens
              Text(
                '$imageCount imagem(ns)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // --- WIDGETS DE NAVEGAÇÃO (Mantidos da implementação original) ---

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop) {
     final Color desktopAppBarColor = const Color(0xFF00A9B8);

    void navigateToHome(BuildContext context) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => navigateToHome(context),
                child: Row(
                  children: [
                    // Assumindo que 'assets/logo_poliedro.png' existe
                    Image.asset('assets/logo_poliedro.png', height: 24), 
                    const SizedBox(width: 8),
                    const Text('Poli Images', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildNavButton(text: 'Página Inicial', icon: Icons.home, onPressed: () { Navigator.of(context).pop(); }),
                  const SizedBox(width: 10),
                  _buildNavButton(text: 'Gerar Nova Imagem', icon: Icons.chat, onPressed: () { /* Navegar para ChatbotPage */ }),
                  const SizedBox(width: 10),
                  _buildNavButton(text: 'Galeria de Fotos', icon: Icons.photo_library, onPressed: () {}),
                  const SizedBox(width: 10),
                  _buildNavButton(text: 'Minha Conta', icon: Icons.person, onPressed: () {}),
                  const SizedBox(width: 20),
                  _buildNavButton(
                    text: 'Deslogar',
                    icon: Icons.logout,
                    onPressed: () {
                      UserSessionManager.logout(); // Limpa a sessão
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
      // AppBar para Mobile
      return AppBar(
        backgroundColor: desktopAppBarColor,
        elevation: 1,
        title: InkWell( 
          onTap: () => navigateToHome(context), 
          child: Row(
            children: [
              Image.asset('assets/logo_poliedro.png', height: 24),
              const SizedBox(width: 8),
              const Text('Poli Images', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      );
    }
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