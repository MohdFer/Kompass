import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/document_model.dart';
import '../data/repositories/document_repository.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});

final tourDocumentsProvider =
    StreamProvider.family<List<DocumentModel>, String>((ref, tourId) {
  return ref.watch(documentRepositoryProvider).watchDocuments(tourId);
});
