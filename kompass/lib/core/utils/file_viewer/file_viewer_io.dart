import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> openRawDocument({
  required String fileName,
  required Uint8List bytes,
  required String contentType,
}) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  await OpenFile.open(file.path);
}
