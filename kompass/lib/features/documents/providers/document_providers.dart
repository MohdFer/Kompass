import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../data/models/document_model.dart';
import '../data/repositories/document_repository.dart';
import '../../auth/providers/auth_providers.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});

final tourDocumentsProvider =
    StreamProvider.family<List<DocumentModel>, String>((ref, tourId) {
  return ref.watch(documentRepositoryProvider).watchDocuments(tourId);
});

final documentUploadControllerProvider =
    StateNotifierProvider<DocumentUploadController, AsyncValue<void>>((ref) {
  return DocumentUploadController(ref);
});

class DocumentUploadController extends StateNotifier<AsyncValue<void>> {
  DocumentUploadController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<bool?> pickAndUploadDocument(String tourId) async {
    try {
      state = const AsyncValue.loading();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result == null || result.files.single.path == null) {
        state = const AsyncValue.data(null);
        return null;
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final currentUser = await ref.read(currentUserProvider.future);
      final uploaderName = currentUser?.name ?? 'Unknown Guide';

      await ref.read(documentRepositoryProvider).uploadDocument(
            tourId: tourId,
            fileName: fileName,
            file: file,
            uploadedBy: uploaderName,
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteDocument(String tourId, DocumentModel doc) async {
    try {
      state = const AsyncValue.loading();
      await ref.read(documentRepositoryProvider).deleteDocument(tourId, doc);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
