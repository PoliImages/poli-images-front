import 'package:flutter/material.dart';
import 'dart:async';

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
enum ChatState { waitingForPrompt, waitingForStyle, generating, finished }

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  ChatState _chatState = ChatState.waitingForPrompt;

  @override
  void initState() {
    super.initState();
    // Adiciona a mensagem inicial do bot
    _addBotMessage(
        'Olá! Eu sou seu assistente de criação de imagens. O que você gostaria de criar hoje?');
  }

  // Função para adicionar uma mensagem do bot à lista
  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text));
    });
    _scrollToBottom();
  }

  // Função para adicionar uma mensagem do usuário à lista
  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _textController.clear();
    _scrollToBottom();
  }

  // Função principal que controla a conversa
  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    _addUserMessage(text);

    // Lógica da conversa
    if (_chatState == ChatState.waitingForPrompt) {
      // Após o usuário dar o prompt, o bot pede o estilo
      setState(() => _chatState = ChatState.waitingForStyle);
      _addBotMessage('Ótima ideia! Qual estilo de imagem você prefere?');
    }
  }
  
  void _handleStyleSelected(String style) {
    // Adiciona a escolha de estilo do usuário como uma mensagem
    _addUserMessage(style);
    setState(() => _chatState = ChatState.generating);

    // Simula a geração da imagem
    _addBotMessage('Entendido! Gerando sua imagem em estilo "$style"...');
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Aqui está sua imagem! O que achou?',
          // Usaremos uma imagem de placeholder por enquanto
          imageUrl: 'https://placehold.co/600x400/00A9B8/white?text=Sua+Imagem',
        ));
        _chatState = ChatState.finished;
        _scrollToBottom();
      });
    });
  }

  // Função para rolar o chat para o final
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
          _buildInputArea(), // A área de input muda conforme o estado do chat
        ],
      ),
    );
  }

  // Constrói a área de input (campo de texto, botões de estilo, etc.)
  Widget _buildInputArea() {
    switch (_chatState) {
      case ChatState.waitingForPrompt:
        return _buildTextInput();
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
                _addBotMessage('Vamos criar algo novo! O que você tem em mente?');
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

  // Constrói a barra de input de texto
  Widget _buildTextInput() {
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
              decoration: const InputDecoration.collapsed(
                hintText: 'Ex: Um astronauta surfando em um anel de saturno',
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

  // Constrói os botões de seleção de estilo
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

  // Constrói um balão de chat
  Widget _buildChatBubble(ChatMessage message) {
    final bubbleAlignment =
        message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor =
        message.isUser ? const Color(0xFF00A9B8) : Colors.grey.shade200;
    final textColor = message.isUser ? Colors.white : Colors.black87;

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
                backgroundImage: const AssetImage('assets/chatbot.png'),
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
                  Text(message.text, style: TextStyle(color: textColor)),
                  if (message.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(message.imageUrl!),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt, size: 18),
                      label: const Text('Salvar na Galeria'),
                      onPressed: () {
                        // Lógica para salvar a imagem
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
