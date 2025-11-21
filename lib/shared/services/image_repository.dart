import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageRepository extends ChangeNotifier {
  static final ImageRepository _instance = ImageRepository._internal();
  factory ImageRepository() => _instance;

  ImageRepository._internal();

  List<String> _imagesBase64 = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _imagesBase64 = prefs.getStringList('saved_images') ?? [];
    notifyListeners();
  }

  List<String> get images => _imagesBase64;

  Future<void> addImage(String base64) async {
    final prefs = await SharedPreferences.getInstance();

    final dataUri = "data:image/png;base64,$base64";

    _imagesBase64.add(dataUri);
    await prefs.setStringList('saved_images', _imagesBase64);

    notifyListeners();
  }
}