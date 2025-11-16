import 'dart:typed_data';
//ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadImageWeb(Uint8List bytes) {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..download = "imagem_${DateTime.now().millisecondsSinceEpoch}.png"
    ..click();

  html.Url.revokeObjectUrl(url);
}