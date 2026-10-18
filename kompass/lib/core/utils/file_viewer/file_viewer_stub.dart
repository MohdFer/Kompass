import 'dart:typed_data';

Future<void> openRawDocument({
  required String fileName,
  required Uint8List bytes,
  required String contentType,
}) async {
  throw UnsupportedError('Cannot open raw document on this platform.');
}
