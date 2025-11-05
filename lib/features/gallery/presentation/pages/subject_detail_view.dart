import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:poli_images_front/features/image/services/image_service.dart'; // CORREÇÃO

class SubjectDetailView extends StatelessWidget {
  // A matéria (pasta) atual, passada pela página anterior
  final String subject;
  // A lista de imagens DESSE usuário para ESSA matéria
  final List<GalleryImage> images;

  const SubjectDetailView({
    super.key,
    required this.subject,
    required this.images,
  });

  // Função utilitária para converter Base64 para Uint8List
  Uint8List _dataFromBase64String(String base64String) {
    // Remove possíveis cabeçalhos de URI, se existirem (ex: data:image/png;base64,)
    String cleanString = base64String.split(',').last;
    return base64Decode(cleanString);
  }

  // --- 1. WIDGET PARA EXIBIR IMAGEM EM TELA CHEIA (MODAL) ---
  void _showImageDialog(BuildContext context, GalleryImage image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          // Define a cor de fundo como transparente para que a imagem domine
          backgroundColor: Colors.transparent, 
          // O conteúdo do diálogo
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Imagem Principal
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _dataFromBase64String(image.base64Data),
                    fit: BoxFit.contain,
                    // Garante que a imagem não tente ser maior que a tela
                    height: MediaQuery.of(context).size.height * 0.7, 
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.red.shade100,
                        alignment: Alignment.center,
                        child: const Text('Falha ao carregar Base64.', style: TextStyle(color: Colors.red)),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Botão Fechar
              Align(
                alignment: Alignment.center,
                child: FloatingActionButton(
                  heroTag: 'closeBtn',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close),
                ),
              ),
              const SizedBox(height: 20),
              // Informações da Imagem
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prompt: ${image.prompt}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Criado em: ${image.createdAt.day}/${image.createdAt.month}/${image.createdAt.year} ${image.createdAt.hour}:${image.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ordena as imagens pela data de criação (mais recentes primeiro)
    images.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 768;
        final int crossAxisCount = isDesktop ? 6 : 3;
        final double horizontalPadding = isDesktop ? 50.0 : 16.0;

        return Scaffold(
          backgroundColor: isDesktop ? Colors.white : Colors.grey[100],
          appBar: AppBar(
            backgroundColor: const Color(0xFF00A9B8),
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Pasta: ${subject}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 1,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Imagens salvas em "${subject}" (${images.length})',
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0, // Miniaturas quadradas
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return _buildImageThumbnail(context, image);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 2. WIDGET DE MINIATURA (THUMBNAIL) ---
  Widget _buildImageThumbnail(BuildContext context, GalleryImage image) {
    // Miniatura com o prompt no rodapé
    return InkWell(
      onTap: () => _showImageDialog(context, image), // Abre o modal ao clicar
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.memory(
                  _dataFromBase64String(image.base64Data),
                  fit: BoxFit.cover, // Cobrirá o espaço disponível
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.red.shade100,
                      alignment: Alignment.center,
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
            // Rodapé com o Prompt
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                image.prompt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}