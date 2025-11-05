import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// 💡 MODELO: Modelo de dados para a imagem na galeria.
// Esta classe é usada tanto pelo ImageService quanto pelas páginas da galeria.
class GalleryImage {
  final String id;
  final String prompt;
  final String base64Data; // Base64 COMPLETO com cabeçalho (data:image/jpeg;base64,...)
  final DateTime createdAt;

  GalleryImage({
    required this.id,
    required this.prompt,
    required this.base64Data,
    required this.createdAt,
  });
  
  // Construtor de fábrica para desserialização JSON
  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['_id'] as String, // Usamos _id do Mongo como ID
      prompt: json['prompt'] as String,
      base64Data: json['base64Data'] as String,
      // O backend Node.js retorna a data em formato ISO8601
      createdAt: DateTime.parse(json['createdAt'] as String), 
    );
  }
}

// 💡 SERVICE: Classe que lida com a comunicação do Back-end de Geração de Imagens
class ImageService {
  // Ajuste a porta para 3000 (Backend Node.js de IA).
  // O método é estático, então o acesso ao _baseUrl é direto pela classe.
  static final String _baseUrl = dotenv.env['BASE_URL_NODE'] ?? 'http://10.0.2.2:3000'; 
  
  // --- 1. MÉTODO DE GERAÇÃO DE IMAGEM ---
  // MÉTODOS ESTÁTICOS: Acessados via ImageService.generateImage(...)
  static Future<String> generateImage(
    String prompt, 
    String style, 
    String userId, 
    String subject // A matéria/pasta
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/api/generate-image');
      
      final body = json.encode({
        'prompt': prompt,
        'style': style,
        'userId': userId, // ENVIO DO ID DO USUÁRIO
        'subject': subject, // ENVIO DA MATÉRIA PARA SALVAR NO MONGO
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final base64Image = data['base64Image'];
        
        if (base64Image == null || base64Image.isEmpty) {
          throw Exception('Resposta do Backend não contém imagem codificada em Base64.');
        }
        return base64Image; 
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Erro desconhecido';
        
        // Log para debug
        print('Erro no Back-end Node.js: $errorMessage');
        
        throw Exception('Falha ao gerar e salvar imagem no servidor (Status ${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('Erro ao comunicar com o Backend Node.js: $e');
      throw Exception('Falha de conexão com o Back-end Node.js. Erro: $e');
    }
  }

  // --- 2. MÉTODO PARA BUSCAR GALERIA ---
  // MÉTODOS ESTÁTICOS: Acessados via ImageService.fetchGallery(...)
  // Retorna um mapa onde a chave é a matéria (String) e o valor é uma lista de GalleryImage
  static Future<Map<String, List<GalleryImage>>> fetchGallery(String userId) async {
    try {
      // Endpoint: /api/gallery?userId=ID_DO_USUARIO
      final url = Uri.parse('$_baseUrl/api/gallery?userId=$userId'); 
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // O backend Node.js retorna um JSON como: { "Matemática": [...], "História": [...] }
        final Map<String, dynamic> data = json.decode(response.body);
        
        final Map<String, List<GalleryImage>> galleryData = {};
        
        // Percorre as chaves (Matérias) e converte a lista de JSONs para GalleryImage
        data.forEach((subject, imageList) {
          // Garante que imageList é uma lista e não nula
          if (imageList is List) {
             galleryData[subject] = imageList
                .map((item) => GalleryImage.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        });
        
        return galleryData;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Erro desconhecido';
        throw Exception('Falha ao buscar galeria (Status ${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('Erro ao buscar galeria: $e');
      throw Exception('Falha ao buscar dados da galeria. Verifique a conexão. Erro: $e');
    }
  }
  
  // --- 3. MÉTODO PARA DELETAR IMAGEM ---
  // (Este método não estava no seu código original, mas é comum para uma galeria)
  static Future<bool> deleteImage(String imageId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/gallery/$imageId');
      
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Erro desconhecido';
        print('Falha ao deletar imagem: $errorMessage');
        return false;
      }
    } catch (e) {
      print('Erro ao deletar imagem: $e');
      return false;
    }
  }
}