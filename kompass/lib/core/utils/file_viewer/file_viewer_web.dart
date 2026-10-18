import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';

Future<void> openRawDocument({
  required String fileName,
  required Uint8List bytes,
  required String contentType,
}) async {
  final uri = Uri.dataFromBytes(bytes, mimeType: contentType);
  await launchUrl(uri);
}
