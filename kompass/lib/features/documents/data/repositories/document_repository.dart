import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/document_model.dart';

class DocumentRepository {
  DocumentRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _docsRef(String tourId) =>
      _firestore
          .collection('Tours')
          .doc(tourId)
          .collection('Documents');

  /// Upload a document file and save metadata.
  Future<DocumentModel> uploadDocument({
    required String tourId,
    required String fileName,
    required File file,
    required String uploadedBy,
  }) async {
    try {
      // Upload to Firebase Storage
      final ref = _storage.ref('tours/$tourId/documents/$fileName');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      final metadata = await ref.getMetadata();

      // Save metadata to Firestore
      final docModel = DocumentModel(
        documentId: '',
        tourId: tourId,
        name: fileName,
        url: url,
        uploadedBy: uploadedBy,
        fileType: fileName.split('.').last,
        fileSizeBytes: metadata.size ?? 0,
      );

      final docRef = await _docsRef(tourId).add(docModel.toFirestore());
      return docModel.copyWith(documentId: docRef.id);
    } catch (e) {
      throw StorageException('Failed to upload document: $e');
    }
  }

  /// Watch all documents for a tour.
  Stream<List<DocumentModel>> watchDocuments(String tourId) {
    return _docsRef(tourId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(DocumentModel.fromFirestore).toList());
  }

  /// Delete a document from Storage and Firestore.
  Future<void> deleteDocument(String tourId, DocumentModel doc) async {
    try {
      await _storage.ref('tours/$tourId/documents/${doc.name}').delete();
      await _docsRef(tourId).doc(doc.documentId).delete();
    } catch (e) {
      throw StorageException('Failed to delete document: $e');
    }
  }
}
