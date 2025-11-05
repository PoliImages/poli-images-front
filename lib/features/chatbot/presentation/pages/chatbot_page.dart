import 'package:flutter/material.dart';
import 'dart:async';
import 'package:poli_images_front/features/chatbot/services/image_service.dart'; // CORREÇÃO 1
import 'package:poli_images_front/features/auth/services/auth_service.dart'; // CORREÇÃO 2
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:convert'; 
import 'dart:typed_data';

// Modelo para representar uma mensagem no chat
class ChatMessage {
  final String text;
  final bool isUser;
  // Armazena a string Base64 da imagem
  final String? base64String; 

  ChatMessage({required this.text, this.isUser = false, this.base64String});
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

// Enum para controlar o estado da conversa
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
  
  // 💡 NOVO: Variável para armazenar a MATÉRIA principal (ex: "Matemática")
  String _currentSubject = ''; 
  // Variável que armazena o PROMPT final a ser enviado (ex: "Matemática: equações")
  String _currentPrompt = ''; 

  // Lista principal de matérias genéricas para seleção
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
    // Verifica se o usuário está logado antes de iniciar o chat
    if (!UserSessionManager.isLoggedIn()) {
      _addBotMessage('❌ **ERRO:** Você precisa estar logado para usar o gerador de imagens. Por favor, volte e faça login.');
      setState(() => _chatState = ChatState.finished); // Trava o input
      return;
    }

    // Primeira Mensagem: Boas-vindas
    _addBotMessage(
        'Olá! Eu sou seu assistente de criação de imagens para **conteúdos escolares**.');
    
    // Segunda Mensagem: A Lista
    String listMessage = 'Para começar, escolha uma matéria da lista digitando o **número** correspondente, ou digite o seu prompt completo.\n\n';
    
    for (int i = 0; i < _subjectsList.length; i++) {
      listMessage += '${i + 1} - ${_subjectsList[i]}\n';
    }
    
    _addBotMessage(listMessage);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  // --- Funções de Ajuda e Lógica de Chat ---

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
  
  // Lógica de Validação
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

  // --- FUNÇÃO PRINCIPAL DE LÓGICA DO CHAT (handleSubmitted) ---
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
          // 💡 ATUALIZADO: Armazenar a matéria principal aqui
          _currentSubject = selectedSubject; 
          // Usar a matéria como prompt inicial para combinar depois
          _currentPrompt = selectedSubject; 
        });
        _addBotMessage(
            'Você escolheu **${selectedSubject}**! Por favor, digite o assunto específico que você deseja (ex: "cinemática", "geometria plana", "O Iluminismo").');
            
      } else if (_isDetailedPrompt(submittedText)) {
        // Se for prompt detalhado, a matéria é 'Diversos' ou o que for apropriado
        setState(() {
          _chatState = ChatState.waitingForStyle;
          _currentSubject = 'Diversos'; // Matéria genérica se não foi selecionada
          _currentPrompt = submittedText;
        });
        _addBotMessage('Ótima ideia! Qual estilo de imagem você prefere?');
        
      } else {
        _addBotMessage(
            'Entrada inválida. Por favor, digite o **número** da matéria na lista ou um prompt detalhado (ex: "Modelo atômico de Bohr").');
      }
      
    } else if (_chatState == ChatState.waitingForTopicDetail) {
      
      if (_isTopicDetail(submittedText)) {
        // Combina o Assunto Principal com o Detalhe
        final combinedPrompt = '${_currentSubject}: $submittedText'; 
        
        setState(() {
          _chatState = ChatState.waitingForStyle;
          _currentPrompt = combinedPrompt; // O prompt final para o DALL-E
        });
        // Mensagem de transição de estado para seleção de estilo
        _addBotMessage('Perfeito! Tópico definido como **$combinedPrompt**. Agora, qual estilo de imagem você prefere?');

      } else {
        _addBotMessage(
            'Desculpe, esse termo não parece um tópico válido. Por favor, insira um assunto específico sobre **${_currentSubject}** que contenha palavras reconhecíveis, como "cinemática" ou "ondas sonoras".');
      }
    }
    
    _focusNode.requestFocus();
  }
  
  // --- FUNÇÃO ATUALIZADA PARA CHAMAR O BACKEND E GERAR IMAGEM ---
  Future<void> _handleStyleSelected(String style) async {
    _addUserMessage(style);
    _focusNode.unfocus();
    
    // Obter ID do usuário
    final userId = UserSessionManager.currentUserId;
    if (userId == null) {
      _addBotMessage('❌ Erro de Autenticação: ID do usuário não encontrado. Por favor, faça login novamente.');
      setState(() => _chatState = ChatState.finished);
      return;
    }

    final finalPromptForUser = "$_currentPrompt em estilo $style";

    _addBotMessage('Gerando imagem para "$finalPromptForUser". Aguarde alguns segundos...');
    
    setState(() {
      _chatState = ChatState.generating; 
    });
    
    try {
      // 🚀 MUDANÇA PRINCIPAL: Chama o serviço com userId e _currentSubject
      final base64String = await ImageService.generateImage(
        _currentPrompt, 
        style, 
        userId, 
        _currentSubject // Matéria usada para AGRUPAR no servidor
      );

      setState(() {
        _messages.add(ChatMessage(
          text: 'Sua imagem foi gerada e **salva automaticamente** na sua galeria de **${_currentSubject}**! 🎉', 
          base64String: base64String, 
        ));
        _chatState = ChatState.finished;
      });
      _scrollToBottom();
      
    } catch (e) {
      _addBotMessage('❌ Erro ao gerar imagem. Verifique se o Backend está rodando corretamente (erro: ${e.toString()}).');
      
      setState(() {
        _chatState = ChatState.waitingForStyle; // Retorna ao estado de escolha de estilo em caso de falha
      });
    }
  }

  // 💡 FUNÇÃO DE CONVERSÃO Base64
  Uint8List _dataFromBase64String(String base64String) {
    // Remove possíveis cabeçalhos de URI, se existirem (ex: data:image/png;base64,)
    String cleanString = base64String.split(',').last;
    return base64Decode(cleanString);
  }
  
  // --- Widgets de UI (SEM ALTERAÇÃO) ---
  
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
      case ChatState.waitingForTopicDetail:
        String hintText = _chatState == ChatState.waitingForPrompt 
          ? 'Digite o número da matéria ou o prompt completo.' 
          : 'Digite o assunto específico de $_currentSubject';
        return _buildTextInput(hintText: hintText);
        
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
                _currentPrompt = '';
                _currentSubject = ''; // Limpa a matéria também
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
    // ... (Mantido o código do buildTextInput)
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
    // ... (Mantido o código do buildStyleSelection)
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
    // ... (Mantido o código do buildStyleButton)
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
        children: [
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                child: Icon(Icons.psychology_alt, color: Colors.white),
                backgroundColor: Colors.teal,
                radius: 16,
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
                  // Exibe o texto APENAS se não for vazio
                  if (message.text.isNotEmpty)
                    RichText(text: TextSpan(children: textSpans)),
                  
                  // Se houver Base64String, mostra a imagem e o botão de salvar
                  if (message.base64String != null) ...[ 
                    if (message.text.isNotEmpty)
                      const SizedBox(height: 8),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // Usa Image.memory para exibir a imagem a partir dos bytes Base64
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

                    // LÓGICA DE SALVAMENTO ATUALIZADA (direto do Base64)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt, size: 18),
                      label: const Text('Salvar na Galeria do Dispositivo'),
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

                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Salvando imagem...'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.blueGrey,
                            ),
                          );

                        try {
                          // CONVERTE A STRING BASE64 em bytes
                          Uint8List bytes = _dataFromBase64String(base64);

                          // Salva os bytes da imagem
                          final result = await ImageGallerySaverPlus.saveImage(
                            bytes,
                            quality: 80,
                            name: 'PoliImage_${DateTime.now().millisecondsSinceEpoch}',
                          );

                          if (result != null && result['isSuccess'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Imagem salva na galeria do dispositivo! 🎉'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Falha ao salvar imagem. O sistema negou a permissão.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao salvar imagem. Erro de conversão Base64 ou permissão: $e'),
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