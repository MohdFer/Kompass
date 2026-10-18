import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_toast.dart';
import 'features/location/providers/location_providers.dart';
import 'routing/app_router.dart';
import 'services/notifications/chat_notification_service.dart';
import 'services/notifications/notification_service.dart';
import 'services/permissions/app_permission_service.dart';

/// Root widget for the KOMPASS application.
class KompassApp extends ConsumerStatefulWidget {
  const KompassApp({super.key});

  @override
  ConsumerState<KompassApp> createState() => _KompassAppState();
}

class _KompassAppState extends ConsumerState<KompassApp> {
  @override
  void initState() {
    super.initState();

    // Prompt for essential system permissions immediately on initial launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppPermissionService.instance.requestInitialPermissionsPrompt();
    });

    NotificationService.instance.onNotificationTapCallback = (payload) {
      try {
        if (payload.startsWith('announcement:')) {
          final tourId = payload.replaceFirst('announcement:', '');
          ref.read(goRouterProvider).push('/tours/$tourId/announcements');
        } else if (payload.startsWith('sos:')) {
          final tourId = payload.replaceFirst('sos:', '');
          ref.read(goRouterProvider).push('/tours/$tourId/sos');
        } else if (payload.startsWith('chat:')) {
          final tourId = payload.replaceFirst('chat:', '');
          ref.read(goRouterProvider).push('/tours/$tourId/chat');
        } else {
          ref.read(goRouterProvider).push('/tours/$payload/chat');
        }
      } catch (e) {
        debugPrint('Error navigating from notification tap: $e');
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    // Actively coordinate real-time chat, broadcast announcements & SOS notifications
    ref.watch(chatNotificationCoordinatorProvider);
    // Actively coordinate automatic location tracking for enrolled users within tour timeframe
    ref.watch(tourLocationTrackerCoordinatorProvider);

    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'KOMPASS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      routerConfig: router,
    );
  }
}
