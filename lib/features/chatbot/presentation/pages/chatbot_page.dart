import 'package:flutter/material.dart';
import 'dart:async';
// NOVO: Importa o ImageService (na pasta services)
import '../../services/image_service.dart';
// NOVO: Usa o pacote atualizado
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
// Necessários para baixar a imagem da URL antes de salvar
import 'package:http/http.dart' as http;
import 'dart:typed_data';


// Modelo para representar uma mensagem no chat
class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl;


  ChatMessage({required this.text, this.isUser = false, this.imageUrl});
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
  // Estado inicial 'generating' reintroduzido para loading
  ChatState _chatState = ChatState.waitingForPrompt;
  String _currentTopic = '';

  // Lista principal de matérias genéricas para seleção (Quebra de linha corrigida)
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
    // 🚨 CORREÇÃO: Removido o ImageService.initialize() pois o token é fixo agora.
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
    'matematica',
    'fisica',
    'quimica',
    'biologia',
    'historia',
    'geografia',
    'portugues',
    'sociologia',
    'filosofia',
    'arte'
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
  
  // --- FUNÇÃO ATUALIZADA PARA CHAMAR O BACKEND E GERAR IMAGEM ---
  Future<void> _handleStyleSelected(String style) async {
    _addUserMessage(style);
    _focusNode.unfocus();
    
    // Concatena o tópico com o estilo para a mensagem de status (não para o backend)
    final finalPromptForUser = "$_currentTopic em estilo $style";

    // Adiciona uma mensagem de loading
    _addBotMessage('Gerando imagem para "$finalPromptForUser". Aguarde alguns segundos...');
    
    setState(() {
      _chatState = ChatState.generating; // NOVO: Mudar para estado de carregamento
    });
    
    try {
      // 🚨 CORREÇÃO AQUI: A chamada agora passa o prompt (_currentTopic) E o style (estilo) separadamente.
      final imageUrl = await ImageService.generateImage(_currentTopic, style);

      setState(() {
        _messages.add(ChatMessage(
          // Adiciona uma bolha vazia para que apenas a imagem apareça
          text: '',
          imageUrl: imageUrl,
        ));
        _chatState = ChatState.finished;
      });
      _scrollToBottom();
      
    } catch (e) {
      // Tratamento de erro
      _addBotMessage('❌ Erro ao gerar imagem. Verifique se o Backend está rodando corretamente (erro: $e).');
      
      setState(() {
        // Retorna ao estado de seleção de estilo para tentar novamente
        _chatState = ChatState.waitingForStyle;
      });
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
      case ChatState.generating: // NOVO: Adiciona indicador de loading
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
                  
                  if (message.imageUrl != null) ...[
                    // Adicionamos um SizedBox somente se houver texto
                    if (message.text.isNotEmpty)
                      const SizedBox(height: 8),

                    // O widget Image.network fará o download e exibirá a imagem da URL
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.imageUrl!,
                        // Adicionando um fallback simples para caso a URL simulada falhe
                        errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.red.shade100,
                              alignment: Alignment.center,
                              child: const Text('Falha ao carregar imagem.', style: TextStyle(color: Colors.red)),
                            );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt, size: 18),
                      label: const Text('Salvar na Galeria'),
                      // LÓGICA ATUALIZADA PARA BAIXAR BYTES E SALVAR
                      onPressed: () async {
                        // Checagem de URL
                        if (message.imageUrl == null || message.imageUrl!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nenhuma imagem para salvar.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // MENSAGEM DE LOADING (Opcional, mas útil)
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Baixando imagem...'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.blueGrey,
                            ),
                          );

                        try {
                          // 1. Faz a requisição HTTP para baixar a imagem
                          final response = await http.get(Uri.parse(message.imageUrl!));

                          // 2. Verifica se a requisição foi bem-sucedida
                          if (response.statusCode == 200) {
                            // 3. Obtém os bytes da imagem
                            Uint8List bytes = response.bodyBytes;

                            // 4. Salva os bytes da imagem
                            final result = await ImageGallerySaverPlus.saveImage(
                              bytes,
                              quality: 80,
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
                              // Caso a biblioteca retorne sucesso=false
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Falha ao salvar imagem. O sistema negou a permissão.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Falha ao baixar imagem (Status: ${response.statusCode}).'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          // Captura erro de rede ou qualquer outro erro no processo
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao salvar imagem. Verifique a URL e a conexão. Erro: $e'),
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