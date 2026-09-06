import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/document_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(tourDocumentsProvider(tourId));
    final uploadState = ref.watch(documentUploadControllerProvider);

    return Scaffold(
      appBar: const KompassAppBar(title: 'Scrolls & Charts'),
      body: docsAsync.when(
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(child: Text('No documents uploaded yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    doc.isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                    color: AppColors.primaryGold,
                  ),
                  title: Text(doc.name, style: AppTextStyles.titleMedium),
                  subtitle: Text('Size: ${doc.formattedSize}\nUploaded by: ${doc.uploadedBy}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () {
                      ref.read(documentUploadControllerProvider.notifier).deleteDocument(tourId, doc);
                    },
                  ),
                  onTap: () async {
                    final uri = Uri.parse(doc.url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uploadState.isLoading
            ? null
            : () => ref.read(documentUploadControllerProvider.notifier).pickAndUploadDocument(tourId),
        icon: uploadState.isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.upload_file),
        label: const Text('Upload Document'),
      ),
    );
  }
}
