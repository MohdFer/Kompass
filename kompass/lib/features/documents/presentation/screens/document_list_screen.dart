import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../data/models/document_model.dart';
import '../../providers/document_providers.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({required this.tourId, super.key});
  final String tourId;

  void _confirmDelete(BuildContext context, WidgetRef ref, DocumentModel doc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text('Are you sure you want to delete "${doc.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(documentUploadControllerProvider.notifier)
                    .deleteDocument(tourId, doc);
                AppToast.showInfo('Document "${doc.name}" deleted.');
              } catch (e) {
                AppToast.showError('Failed to delete document: $e');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(tourDocumentsProvider(tourId));
    final uploadState = ref.watch(documentUploadControllerProvider);

    return Scaffold(
      appBar: const KompassAppBar(title: 'Scrolls & Documents'),
      body: docsAsync.when(
        data: (docs) {
          if (docs.isEmpty) {
            return const KompassEmptyState(
              icon: Icons.folder_open,
              message: 'No documents or scrolls uploaded yet.\nTap below to upload PDFs or images for this tour.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(
                      doc.isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                      color: doc.isPdf ? AppColors.error : AppColors.primaryGold,
                    ),
                  ),
                  title: Text(doc.name, style: AppTextStyles.labelLarge),
                  subtitle: Text(
                    'Size: ${doc.formattedSize} • By: ${doc.uploadedBy}',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Delete document',
                    onPressed: () => _confirmDelete(context, ref, doc),
                  ),
                  onTap: () async {
                    try {
                      final uri = Uri.parse(doc.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        AppToast.showError('Could not open document link.');
                      }
                    } catch (e) {
                      AppToast.showError('Failed to open document: $e');
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const KompassLoading(),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uploadState.isLoading
            ? null
            : () async {
                try {
                  final result = await ref
                      .read(documentUploadControllerProvider.notifier)
                      .pickAndUploadDocument(tourId);
                  if (result == true) {
                    AppToast.showSuccess('Document uploaded successfully!');
                  }
                } catch (e) {
                  AppToast.showError('Failed to upload document: $e');
                }
              },
        icon: uploadState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.textOnPrimary,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.upload_file),
        label: Text(uploadState.isLoading ? 'Uploading...' : 'Upload Document'),
      ),
    );
  }
}
