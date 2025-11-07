// lib/features/gallery/models/image_model.dart

class ImageModel {
  final String? id;
  final String subject; // Matéria (ex: Matemática, Física)
  final String topic; // Tópico específico
  final String style; // Estilo da imagem
  final String base64String; // Imagem em Base64
  final DateTime createdAt;

  ImageModel({
    this.id,
    required this.subject,
    required this.topic,
    required this.style,
    required this.base64String,
    required this.createdAt,
  });

  // Converte o modelo para JSON (para enviar ao MongoDB)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'subject': subject,
      'topic': topic,
      'style': style,
      'base64String': base64String,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Cria um modelo a partir do JSON (recebido do MongoDB)
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['_id']?.toString(),
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      style: json['style'] ?? '',
      base64String: json['base64String'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  // Extrai a matéria do tópico completo
  // Ex: "Matemática: geometria plana" -> "Matemática"
  static String extractSubject(String fullTopic) {
    if (fullTopic.contains(':')) {
      return fullTopic.split(':')[0].trim();
    }
    
    // Lista de matérias para fallback
    final subjects = [
      'Matemática', 'Física', 'Química', 'Biologia',
      'História', 'Geografia', 'Português', 'Sociologia',
      'Filosofia', 'Arte', 'Inglês'
    ];
    
    final normalizedTopic = fullTopic.toLowerCase();
    for (var subject in subjects) {
      if (normalizedTopic.contains(subject.toLowerCase())) {
        return subject;
      }
    }
    
    return 'Outros'; // Categoria padrão
  }
}