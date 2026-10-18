import 'dart:convert';
import 'dart:typed_data';
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

  String contentTypeForExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// Upload a document using raw bytes directly to Firestore.
  /// This works 100% on the FREE Firebase Spark Plan with NO Blaze plan or credit card required!
  Future<DocumentModel> uploadDocument({
    required String tourId,
    required String fileName,
    required Uint8List fileBytes,
    required String uploadedBy,
  }) async {
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last : '';
      final docRef = _docsRef(tourId).doc();
      final docId = docRef.id;
      final int size = fileBytes.lengthInBytes;

      // 500 KB limit for single document vs chunked subcollection
      const int maxChunkSize = 500 * 1024;

      final docModel = DocumentModel(
        documentId: docId,
        tourId: tourId,
        name: fileName,
        url: 'firestore://$tourId/$docId',
        uploadedBy: uploadedBy,
        fileType: ext,
        fileSizeBytes: size,
      );

      final firestoreData = docModel.toFirestore();

      if (size <= maxChunkSize) {
        // Fits comfortably in a single Firestore document (limit 1MB)
        firestoreData['isChunked'] = false;
        firestoreData['data'] = base64Encode(fileBytes);
        await docRef.set(firestoreData);
      } else {
        // Automatically partition larger files into chunks in a subcollection
        firestoreData['isChunked'] = true;
        final batch = _firestore.batch();
        batch.set(docRef, firestoreData);

        int chunkIndex = 0;
        for (int i = 0; i < size; i += maxChunkSize) {
          final end = (i + maxChunkSize < size) ? i + maxChunkSize : size;
          final chunkBytes = fileBytes.sublist(i, end);
          final chunkDocRef = docRef.collection('Chunks').doc('$chunkIndex');
          batch.set(chunkDocRef, {
            'index': chunkIndex,
            'data': base64Encode(chunkBytes),
          });
          chunkIndex++;
        }
        firestoreData['totalChunks'] = chunkIndex;
        await batch.commit();
      }

      return docModel;
    } catch (e) {
      throw StorageException('Failed to upload document: $e');
    }
  }

  /// Retrieve raw document bytes from Firestore (works on Free Spark Plan).
  Future<Uint8List> getDocumentBytes(String tourId, String documentId) async {
    try {
      final docSnapshot = await _docsRef(tourId).doc(documentId).get();
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        throw const StorageException('Document does not exist.');
      }

      final data = docSnapshot.data()!;
      final bool isChunked = data['isChunked'] as bool? ?? false;

      if (!isChunked) {
        final base64Str = data['data'] as String?;
        if (base64Str == null) {
          throw const StorageException('No document data found.');
        }
        return base64Decode(base64Str);
      } else {
        final chunksSnapshot = await _docsRef(tourId)
            .doc(documentId)
            .collection('Chunks')
            .orderBy('index')
            .get();

        final buffer = BytesBuilder();
        for (final doc in chunksSnapshot.docs) {
          final chunkData = doc.data()['data'] as String?;
          if (chunkData != null) {
            buffer.add(base64Decode(chunkData));
          }
        }
        return buffer.toBytes();
      }
    } catch (e) {
      throw StorageException('Failed to retrieve document: $e');
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

  /// Delete a document from Storage / Firestore.
  Future<void> deleteDocument(String tourId, DocumentModel doc) async {
    try {
      if (doc.url.startsWith('firestore://')) {
        final chunks = await _docsRef(tourId).doc(doc.documentId).collection('Chunks').get();
        final batch = _firestore.batch();
        for (final c in chunks.docs) {
          batch.delete(c.reference);
        }
        batch.delete(_docsRef(tourId).doc(doc.documentId));
        await batch.commit();
      } else {
        try {
          await _storage.ref('tours/$tourId/documents/${doc.name}').delete();
        } catch (_) {}
        await _docsRef(tourId).doc(doc.documentId).delete();
      }
    } catch (e) {
      throw StorageException('Failed to delete document: $e');
    }
  }
}
