import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../../shared/services/image_repository.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:poli_images_front/download_helper.dart'
    if (dart.library.html) 'package:poli_images_front/download_helper_web.dart';



class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

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

  void logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Uint8List _decodeBase64(String dataUri) {
    final base64String = dataUri.split(',').last;
    return Uint8List.fromList(base64Decode(base64String));
  }

  Future<void> _downloadImageDesktop(BuildContext context, Uint8List bytes) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) return;

      final filePath =
          '${directory.path}/imagem_${DateTime.now().millisecondsSinceEpoch}.png';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imagem salva na pasta Downloads!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                onPressed: () => logout(context),
                iconTextColor: iconTextColor,
              ),
              const SizedBox(width: 50),
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
        actions: [],
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
      label: Text(
        text,
        style: TextStyle(
          color: iconTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(
          Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDesktop) {
    return Consumer<ImageRepository>(
      builder: (context, repo, child) {
        final images = repo.images;

        if (images.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          'Galeria de Fotos',
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
                          icon: Icon(
                            Icons.arrow_back,
                            size: isDesktop ? 30 : 24,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Nenhuma imagem salva ainda",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final crossAxisCount = isDesktop ? 4 : 1;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Galeria de Fotos',
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
                      icon: Icon(
                        Icons.arrow_back,
                        size: isDesktop ? 30 : 24,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  itemCount: images.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _decodeBase64(images[index]),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Excluir imagem'),
                                  content: const Text(
                                      'Deseja realmente excluir esta imagem?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await repo.deleteImage(index);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () async {
                              final base64Image = images[index];
                              final bytes = _decodeBase64(base64Image);

                              if (kIsWeb) {
                                downloadImageWeb(bytes);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Download iniciado!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                return;
                              }

                              if (!Platform.isAndroid && !Platform.isIOS) {
                                await _downloadImageDesktop(context, bytes);
                                return;
                              }

                              final result = await ImageGallerySaverPlus.saveImage(
                                bytes,
                                quality: 90,
                                name: 'GalleryImage_${DateTime.now().millisecondsSinceEpoch}',
                              );

                              if (result['isSuccess'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Imagem salva na galeria!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Falha ao salvar imagem!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}