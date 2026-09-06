import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/user_role.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../providers/emergency_providers.dart';
import '../../data/models/sos_alert_model.dart';

class SOSScreen extends ConsumerWidget {
  const SOSScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final isGuide = user?.userRole == UserRole.guide || user?.userRole == UserRole.admin;

    return Scaffold(
      appBar: const KompassAppBar(title: 'Distress Signals'),
      body: isGuide ? _GuideSOSView(tourId: tourId) : _ParticipantSOSView(tourId: tourId),
    );
  }
}

class _GuideSOSView extends ConsumerWidget {
  const _GuideSOSView({required this.tourId});
  final String tourId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(activeSOSAlertsProvider(tourId));

    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) {
          return const KompassEmptyState(
            title: 'All clear',
            message: 'No active SOS alerts right now.',
            icon: Icons.check_circle_outline,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return Card(
              color: AppColors.error.withValues(alpha: 0.1),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.error),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.warning, color: AppColors.error, size: 36),
                title: Text('SOS: ${alert.userName}', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.error)),
                subtitle: Text(
                  alert.timestamp != null 
                      ? DateFormat.yMMMd().add_jm().format(alert.timestamp!)
                      : 'Just now',
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  onPressed: () {
                    ref.read(emergencyRepositoryProvider).resolveSOS(tourId, alert.alertId);
                  },
                  child: const Text('Resolve'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: KompassLoading()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _ParticipantSOSView extends ConsumerStatefulWidget {
  const _ParticipantSOSView({required this.tourId});
  final String tourId;

  @override
  ConsumerState<_ParticipantSOSView> createState() => _ParticipantSOSViewState();
}

class _ParticipantSOSViewState extends ConsumerState<_ParticipantSOSView> {
  bool _isSending = false;

  Future<void> _triggerSOS() async {
    setState(() => _isSending = true);
    try {
      final user = ref.read(currentUserProvider).value;
      final authUser = ref.read(authStateChangesProvider).value;
      
      if (authUser != null) {
        final alert = SosAlertModel(
          alertId: '',
          tourId: widget.tourId,
          userId: authUser.uid,
          userName: user?.name ?? 'Unknown Participant',
          latitude: 0.0, // Should be fetched from location service
          longitude: 0.0,
          message: 'Emergency!',
        );
        
        await ref.read(emergencyRepositoryProvider).triggerSOS(widget.tourId, alert);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SOS Alert Sent! Guide notified.'), backgroundColor: AppColors.error),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 80, color: AppColors.error),
          const SizedBox(height: 24),
          Text(
            'In case of emergency,\npress the button below.',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayMedium,
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _isSending ? null : _triggerSOS,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _isSending 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'PANIC',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
