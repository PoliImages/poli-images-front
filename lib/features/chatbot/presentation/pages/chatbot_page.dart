import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/image_service.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:convert';
import 'dart:typed_data';

// isola dart:html da compilação Desktop/Mobile
import 'package:poli_images_front/download_helper.dart'
    if (dart.library.html) 'package:poli_images_front/download_helper_web.dart';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? base64String;

  ChatMessage({required this.text, this.isUser = false, this.base64String});
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

enum ChatState {
  waitingForPrompt,
  waitingForTopicDetail,
  waitingForStyle,
  generating,
  finished
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  ChatState _chatState = ChatState.waitingForPrompt;
  String _currentTopic = '';

  final List<String> _subjectsList = const [
    'Matemática',
    'Física',
    'Química',
    'Biologia',
    'História',
    'Geografia',
    'Português',
    'Sociologia',
    'Filosofia',
    'Arte'
  ];

  @override
  void initState() {
    super.initState();
    _sendInitialMessage();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendInitialMessage() {
    _addBotMessage(
        'Olá! Eu sou seu assistente de criação de imagens para **conteúdos escolares**.');

    String listMessage = 'Para começar, escolha uma matéria da lista digitando o **número** correspondente, ou digite o seu prompt completo.\n\n';

    for (int i = 0; i < _subjectsList.length; i++) {
      listMessage += '${i + 1} - ${_subjectsList[i]}\n';
    }

    _addBotMessage(listMessage);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  String _normalizeText(String text) {
    String normalized = text.toLowerCase();
    normalized = normalized
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');

    return normalized.trim();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  final List<String> _genericSubjectsNormalized = const [
    'matematica', 'fisica', 'quimica', 'biologia', 'historia', 'geografia',
    'portugues', 'sociologia', 'filosofia', 'arte'
  ];

  bool _isTopicDetail(String text) {
    final normalizedText = _normalizeText(text);
    if (normalizedText.length < 4) return false;
    if (!RegExp(r'\b[a-z]{4,}\b').hasMatch(normalizedText)) return false;
    int nonAlphaCount = normalizedText.replaceAll(RegExp(r'[a-z0-9\s]'), '').length;

    return (nonAlphaCount / normalizedText.length) < 0.25;
  }

  bool _isDetailedPrompt(String text) {
    final normalizedText = _normalizeText(text);
    bool looksLikeASentence = normalizedText.length > 15 && normalizedText.contains(' ');
    bool isNotJustASubject = !_genericSubjectsNormalized.contains(normalizedText);

    return looksLikeASentence && isNotJustASubject;
  }

  // --- FUNÇÃO PRINCIPAL ---
  void _handleSubmitted(String text) {
    if (text.isEmpty) {
        _focusNode.requestFocus();
        return;
    }

    final submittedText = _textController.text;
    _addUserMessage(submittedText);

    _textController.clear();

    if (_chatState == ChatState.waitingForPrompt) {

      final int? selectedNumber = int.tryParse(submittedText.trim());

      if (selectedNumber != null && selectedNumber >= 1 && selectedNumber <= _subjectsList.length) {
        final selectedSubject = _subjectsList[selectedNumber - 1];

        setState(() {
          _chatState = ChatState.waitingForTopicDetail;
          _currentTopic = selectedSubject;
        });
        _addBotMessage(
            'Você escolheu **${selectedSubject}**! Por favor, digite o assunto específico que você deseja (ex: "cinemática", "geometria plana", "O Iluminismo").');

      } else if (_isDetailedPrompt(submittedText)) {
        setState(() {
          _chatState = ChatState.waitingForStyle;
          _currentTopic = submittedText;
        });
        _addBotMessage('Ótima ideia! Qual estilo de imagem você prefere?');

      } else {
        _addBotMessage(
            'Entrada inválida. Por favor, digite o **número** da matéria na lista ou um prompt detalhado (ex: "Modelo atômico de Bohr").');
      }

    } else if (_chatState == ChatState.waitingForTopicDetail) {

      if (_isTopicDetail(submittedText)) {
        final combinedPrompt = '${_currentTopic}: $submittedText';

        setState(() {
          _chatState = ChatState.waitingForStyle;
          _currentTopic = combinedPrompt;
        });
        _addBotMessage('Perfeito! Tópico definido como **$combinedPrompt**. Agora, qual estilo de imagem você prefere?');

      } else {
        _addBotMessage(
            'Desculpe, esse termo não parece um tópico válido. Por favor, insira um assunto específico sobre **${_currentTopic}** que contenha palavras reconhecíveis, como "cinemática" ou "ondas sonoras".');
      }
    }

    _focusNode.requestFocus();
  }

  // --- FUNÇÃO ATUALIZADA PARA CHAMAR O BACKEND E GERAR IMAGEM ---
  Future<void> _handleStyleSelected(String style) async {
    _addUserMessage(style);
    _focusNode.unfocus();

    final finalPromptForUser = "$_currentTopic em estilo $style";

    _addBotMessage('Gerando imagem para "$finalPromptForUser". Aguarde alguns segundos...');

    setState(() {
      _chatState = ChatState.generating;
    });

    try {
      // Chama o serviço que retorna a string Base64
      final base64String = await ImageService.generateImage(_currentTopic, style);

      setState(() {
        _messages.add(ChatMessage(
          text: 'Sua imagem foi gerada!',
          base64String: base64String,
        ));
        _chatState = ChatState.finished;
      });
      _scrollToBottom();

    } catch (e) {
      _addBotMessage('❌ Erro ao gerar imagem. Verifique se o Backend está rodando corretamente (erro: $e).');

      setState(() {
        _chatState = ChatState.waitingForStyle;
      });
    }
  }

  // FUNÇÃO: Converte a string Base64 para Uint8List
  Uint8List _dataFromBase64String(String base64String) {
    String cleanString = base64String.split(',').last;
    return base64Decode(cleanString);
  }

  Future<void> _downloadImageDesktop(Uint8List bytes) async {
    try {
      final directory = await getDownloadsDirectory(); // Pasta Downloads do usuário
      if (directory == null) {
        return; // Em plataformas sem suporte
      }

      final filePath =
          '${directory.path}/imagem_${DateTime.now().millisecondsSinceEpoch}.png';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Aviso de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imagem salva na pasta de Downloads'),
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


  // --- Widgets de UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerar Nova Imagem'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    switch (_chatState) {
      case ChatState.waitingForPrompt:
        return _buildTextInput(hintText: 'Digite o número da matéria ou o prompt completo.');
      case ChatState.waitingForTopicDetail:
        return _buildTextInput(hintText: 'Digite o assunto específico de ${_currentTopic}');
      case ChatState.waitingForStyle:
        return _buildStyleSelection();
      case ChatState.generating:
        return Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          color: Colors.white,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF00A9B8)),
              SizedBox(width: 16),
              Text('Gerando...'),
            ],
          ),
        );
      case ChatState.finished:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Criar outra imagem', style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                _messages.clear();
                _chatState = ChatState.waitingForPrompt;
                _currentTopic = '';
                _sendInitialMessage();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A9B8),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        );
    }
  }

  Widget _buildTextInput({required String hintText}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              focusNode: _focusNode,
              decoration: InputDecoration.collapsed(
                hintText: hintText,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF00A9B8)),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            _buildStyleButton('Fotografia'),
            _buildStyleButton('Anime'),
            _buildStyleButton('Aquarela'),
            _buildStyleButton('Arte Digital'),
            _buildStyleButton('Pixel Art'),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleButton(String style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () => _handleStyleSelected(style),
        child: Text(style),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade50,
          foregroundColor: Colors.teal.shade800,
        ),
      ),
    );
  }

  @override
  Widget _buildChatBubble(ChatMessage message) {
    List<TextSpan> textSpans = [];
    final parts = message.text.split('**');
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        textSpans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ));
      } else {
        textSpans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ));
      }
    }

    final bubbleColor =
        message.isUser ? const Color(0xFF00A9B8) : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/chatbot.png',
                    fit: BoxFit.cover,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const CircleAvatar(
                        child: Icon(Icons.psychology_alt, color: Colors.white),
                        backgroundColor: Colors.teal,
                        radius: 16,
                      );
                    },
                  ),
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.text.isNotEmpty)
                    RichText(text: TextSpan(children: textSpans)),

                  if (message.base64String != null) ...[
                    if (message.text.isNotEmpty)
                      const SizedBox(height: 8),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _dataFromBase64String(message.base64String!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.red.shade100,
                              alignment: Alignment.center,
                              child: const Text('Falha ao converter e carregar imagem Base64.', style: TextStyle(color: Colors.red)),
                            );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // LÓGICA DE SALVAMENTO (mobile + web)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Baixar imagem'),
                      onPressed: () async {
                        final base64 = message.base64String;

                        if (base64 == null || base64.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nenhuma imagem para salvar.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        Uint8List bytes = _dataFromBase64String(base64);

                        if (kIsWeb) {
                          // Salvar download WEB
                          downloadImageWeb(bytes);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Download iniciado!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          return;
                        }

                        // Salvar download no desktop
                        if (!Platform.isAndroid && !Platform.isIOS) {
                          await _downloadImageDesktop(bytes);
                          return;
                        }

                        // Salvar download na galeria (Android/iOS)
                        final result = await ImageGallerySaverPlus.saveImage(
                          bytes,
                          quality: 90,
                          name: 'GeneratedImage_${DateTime.now().millisecondsSinceEpoch}',
                        );

                        if (result != null && result['isSuccess'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Imagem salva na galeria com sucesso! 🎉'),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal.shade800,
                      ),
                    )
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                child: Icon(Icons.person, color: Colors.white),
                backgroundColor: Color(0xFF00A9B8),
                radius: 16,
              ),
            ),
        ],
      ),
    );
  }
}