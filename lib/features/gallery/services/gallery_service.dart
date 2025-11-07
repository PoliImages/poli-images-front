// lib/features/gallery/services/gallery_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../presentation/models/image_model.dart';

class GalleryService {
  static final String _baseUrl = dotenv.env['BASE_URL']!;
  
  static Future<bool> saveImage(ImageModel image) async {
    try {
      final url = Uri.parse('$_baseUrl/api/images');
      print('📤 Salvando imagem no MongoDB via: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(image.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Imagem salva com sucesso no MongoDB');
        return true;
      } else {
        print('❌ Erro ao salvar imagem: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erro de conexão ao salvar imagem: $e');
      return false;
    }
  }

  static Future<List<ImageModel>> getAllImages() async {
    try {
      final url = Uri.parse('$_baseUrl/api/images');
      print('📥 Buscando todas as imagens de: $url');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final images = data.map((json) => ImageModel.fromJson(json)).toList();
        print('✅ ${images.length} imagens carregadas do MongoDB');
        return images;
      } else {
        print('❌ Erro ao buscar imagens: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erro de conexão ao buscar imagens: $e');
      return [];
    }
  }

  static Future<List<ImageModel>> getImagesBySubject(String subject) async {
    try {
      final url = Uri.parse('$_baseUrl/api/images/subject/$subject');
      print('📥 Buscando imagens de $subject de: $url');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final images = data.map((json) => ImageModel.fromJson(json)).toList();
        print('✅ ${images.length} imagens de $subject carregadas');
        return images;
      } else {
        print('❌ Erro ao buscar imagens por matéria: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erro de conexão ao buscar imagens por matéria: $e');
      return [];
    }
  }

  static Future<bool> deleteImage(String imageId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/images/$imageId');
      print('🗑️ Deletando imagem $imageId de: $url');
      
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Imagem deletada com sucesso');
        return true;
      } else {
        print('❌ Erro ao deletar imagem: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erro de conexão ao deletar imagem: $e');
      return false;
    }
  }

  static Map<String, List<ImageModel>> groupImagesBySubject(List<ImageModel> images) {
    final Map<String, List<ImageModel>> grouped = {};
    
    for (var image in images) {
      if (!grouped.containsKey(image.subject)) {
        grouped[image.subject] = [];
      }
      grouped[image.subject]!.add(image);
    }
    
    return grouped;
  }
}