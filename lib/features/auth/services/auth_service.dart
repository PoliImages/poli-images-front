import 'package:flutter/material.dart';
import 'package:poli_images_front/features/chatbot/services/image_service.dart'; // CORREÇÃO
import 'package:poli_images_front/features/auth/services/auth_service.dart'; // CORREÇÃO

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _promptController = TextEditingController();
  final _imageService = ImageService();
  
  bool _isLoading = false;
  String? _generatedImageUrl;
  String? _lastGeneratedPrompt;
  bool _isImageSaved = false;

  // 1. Função para chamar o serviço de Geração de Imagem
  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      _showFeedback(message: 'Por favor, insira um prompt para gerar a imagem.', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedImageUrl = null;
      _isImageSaved = false;
      _lastGeneratedPrompt = null;
    });

    try {
      // Chama o serviço para gerar a imagem
      final result = await _imageService.generateImage(prompt: prompt);

      setState(() {
        _isLoading = false;
        if (result['imageUrl'] != null) {
          _generatedImageUrl = result['imageUrl'];
          _lastGeneratedPrompt = prompt;
        }
      });
      
      if (result['statusCode'] != 200) {
        _showFeedback(
          message: result['message'] ?? 'Erro ao gerar imagem.',
          isSuccess: false,
        );
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showFeedback(
        message: 'Falha na comunicação com o servidor de IA.',
        isSuccess: false,
      );
    }
  }

  // 2. Função para salvar a imagem gerada
  Future<void> _saveImage() async {
    if (_generatedImageUrl == null || _lastGeneratedPrompt == null || _isImageSaved) return;

    // Obtém o ID do usuário da sessão
    final userId = UserSessionManager.currentUserId;
    if (userId == null) {
      _showFeedback(message: 'Erro: ID do usuário não encontrado. Faça login novamente.', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Chama o serviço para salvar a imagem
      final result = await _imageService.saveImage(
        userId: userId,
        imageUrl: _generatedImageUrl!,
        prompt: _lastGeneratedPrompt!,
      );

      setState(() {
        _isLoading = false;
      });

      _showFeedback(
        message: result['message'],
        isSuccess: result['statusCode'] == 201,
      );

      if (result['statusCode'] == 201) {
        setState(() {
          _isImageSaved = true;
        });
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showFeedback(
        message: 'Falha ao salvar a imagem. Tente novamente.',
        isSuccess: false,
      );
    }
  }

  void _showFeedback({required String message, required bool isSuccess}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green[600] : Colors.red[600],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geração de Imagens (Chatbot DALL-E)'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), // Largura máxima
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPromptInput(),
                const SizedBox(height: 16),
                _buildGenerateButton(),
                const SizedBox(height: 32),
                _buildImageArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromptInput() {
    return TextField(
      controller: _promptController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Descreva a imagem desejada (ex: "professor explicando física quântica em estilo Pixar")',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: _isLoading && _generatedImageUrl == null ? 
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ) 
          : null,
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _generateImage,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        _isLoading && _generatedImageUrl == null ? 'Gerando Imagem...' : 'Gerar Imagem',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildImageArea() {
    if (_isLoading && _generatedImageUrl == null) {
      return const Center(child: Text('Aguardando a inteligência artificial...', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }

    if (_generatedImageUrl == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)
        ),
        child: const Center(
          child: Text(
            'A imagem gerada aparecerá aqui.',
            style: TextStyle(color: Colors.grey, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Column(
      children: [
        // Exibição da Imagem
        Container(
          height: 400,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Image.network(
            _generatedImageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.red[100],
              child: const Center(child: Text('Erro ao carregar imagem', style: TextStyle(color: Colors.red))),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Botão para Salvar Imagem
        ElevatedButton.icon(
          onPressed: _isImageSaved || _isLoading ? null : _saveImage,
          icon: Icon(_isImageSaved ? Icons.check : Icons.save),
          label: Text(_isImageSaved ? 'Imagem Salva!' : 'Salvar Imagem na Galeria'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: _isImageSaved ? Colors.green : Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isImageSaved ? 'Você pode ver esta imagem na Galeria de Assuntos.' : 'A imagem será salva na sua galeria pessoal.',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}