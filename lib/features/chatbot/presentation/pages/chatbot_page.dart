import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Para ler a URL do .env


final String YOUR_BACKEND_ENDPOINT = dotenv.env['BACKEND_URL'] ?? 'http://127.0.0.1:8080/api/generate-image';

// Modelo para representar uma mensagem no chat
class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl; // Para exibir a imagem gerada

  ChatMessage({required this.text, this.isUser = false, this.imageUrl});
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

// Enum para controlar o estado da conversa
enum ChatState { waitingForPrompt, waitingForTopicDetail, waitingForStyle, generating, finished }

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); 
  
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  ChatState _chatState = ChatState.waitingForPrompt;
  String _currentTopic = ''; // Guarda a matéria genérica ou o prompt completo

  // Lista principal de matérias genéricas para seleção
  final List<String> _subjectsList = [
    'Matemática', 'Física', 'Química', 'Biologia', 'História', 
    'Geografia', 'Português', 'Sociologia', 'Filosofia', 'Arte'
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
    // Primeira Mensagem: Boas-vindas
    _addBotMessage(
        'Olá! Eu sou seu assistente de criação de imagens para **conteúdos escolares**.');
    
    // Segunda Mensagem: A Lista (logo em seguida)
    String listMessage = 'Para começar, escolha uma matéria da lista digitando o **número** correspondente, ou digite o seu prompt completo.\n\n';
    
    for (int i = 0; i < _subjectsList.length; i++) {
      listMessage += '${i + 1} - ${_subjectsList[i]}\n';
    }
    
    _addBotMessage(listMessage);
    // Tenta focar logo após a inicialização do chat
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  // --- LÓGICA DE REDE: CHAMA O SEU BACKEND DART ---
  Future<String> _generateImage(String prompt, String style) async {
    final url = Uri.parse(YOUR_BACKEND_ENDPOINT);

    try {
      // Envia o prompt e o estilo como JSON para o seu servidor Dart
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'style': style,
        }),
      );

      if (response.statusCode == 200) {
        // Recebe a resposta do seu servidor Dart
        final data = jsonDecode(response.body);
        
        final imageUrl = data['imageUrl'];

        if (imageUrl != null && imageUrl.isNotEmpty) {
          return imageUrl;
        }
        return 'https://via.placeholder.com/600x400/FF0000/FFFFFF?text=Erro:+URL+vazia';

      } else {
        // Trata erros vindos do seu próprio servidor (seu backend)
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? 'Erro desconhecido do servidor Dart.';

        return 'https://via.placeholder.com/600x400/FF0000/FFFFFF?text=Falha+no+Servidor:+${response.statusCode}';
      }
    } catch (e) {
      // Erro de comunicação (Rede, CORS, etc.)
      print('Erro de comunicação com o backend: $e');
      return 'https://via.placeholder.com/600x400/FF0000/FFFFFF?text=Erro+de+Rede';
    }
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
  final List<String> _genericSubjectsNormalized = [
    'matematica', 'fisica', 'quimica', 'biologia', 'historia', 
    'geografia', 'portugues', 'sociologia', 'filosofia', 'arte'
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
    
    // Limpeza garantida
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
        _addBotMessage('Perfeito! Gerando imagem de **$combinedPrompt**. Qual estilo você prefere?');

      } else {
        _addBotMessage(
            'Desculpe, esse termo não parece um tópico válido. Por favor, insira um assunto específico sobre **${_currentTopic}** que contenha palavras reconhecíveis, como "cinemática" ou "ondas sonoras".');
      }
    }
    
    _focusNode.requestFocus();
  }
  
  // --- FUNÇÃO ALTERADA PARA CHAMAR A GERAÇÃO DE IMAGEM REAL ---
  void _handleStyleSelected(String style) async {
    _addUserMessage(style);
    
    _focusNode.unfocus(); 
    
    setState(() => _chatState = ChatState.generating);

    final finalPrompt = _currentTopic; 

    // Mensagem de loading
    _addBotMessage('Entendido! Gerando sua imagem de "$finalPrompt" em estilo "$style"... Isso pode levar alguns segundos.');

    // CHAMADA REAL DE REDE
    final imageUrl = await _generateImage(finalPrompt, style);

    // Quando a imagem é gerada, atualiza a tela
    setState(() {
      _messages.add(ChatMessage(
        // Se a URL for um erro de placeholder, avisa o usuário.
        text: imageUrl.startsWith('https://via.placeholder.com') 
              ? 'Ocorreu um erro ao gerar a imagem. Tente novamente ou verifique o log do servidor.'
              : 'Aqui está sua imagem! O que achou?',
        imageUrl: imageUrl, 
      ));
      _chatState = ChatState.finished;
      _scrollToBottom();
    });
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
        return const Padding(
          padding: EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Gerando imagem...'),
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
                  RichText(text: TextSpan(children: textSpans)), 
                  if (message.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    // O widget Image.network fará o download e exibirá a imagem da URL
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(message.imageUrl!),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt, size: 18),
                      label: const Text('Salvar na Galeria'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Imagem salva com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
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
        ],
      ),
    );
  }
}