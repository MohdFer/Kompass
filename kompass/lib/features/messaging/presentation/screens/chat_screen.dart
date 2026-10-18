import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../services/notifications/chat_notification_service.dart';
import '../../../../services/notifications/fcm_direct_dispatcher.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../tour/providers/tour_providers.dart';
import '../../data/models/message_model.dart';
import '../../providers/messaging_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.tourId, super.key});
  final String tourId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    ChatNotificationService.instance.setActiveChatTourId(widget.tourId);
  }

  @override
  void dispose() {
    ChatNotificationService.instance.setActiveChatTourId(null);
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider).value;
    final authUser = ref.read(authStateChangesProvider).value;
    if (authUser == null) return;

    final message = MessageModel(
      messageId: '',
      tourId: widget.tourId,
      senderId: authUser.uid,
      message: text,
      senderName: user?.name ?? 'Unknown',
    );

    _controller.clear();
    try {
      final messageId = await ref.read(messageRepositoryProvider).sendMessage(widget.tourId, message);

      // Dispatch direct background push notification to all tour members
      final tour = ref.read(tourDetailProvider(widget.tourId)).valueOrNull;
      unawaited(
        FcmDirectDispatcher.instance.sendChatMessage(
          tourId: widget.tourId,
          tourName: tour?.name ?? 'Expedition',
          senderName: user?.name ?? 'Explorer',
          messageText: text,
          senderId: authUser.uid,
          messageId: messageId,
        ).catchError((err) {
          debugPrint('FCM direct send chat error: $err');
        }),
      );
    } catch (e) {
      if (mounted) {
        AppToast.showError('Failed to send message: $e', context: context);
      }
    }
  }

  Future<void> _onRefresh() async {
    ref.invalidate(tourMessagesProvider(widget.tourId));
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(tourMessagesProvider(widget.tourId));
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid;

    return Scaffold(
      appBar: const KompassAppBar(title: 'Ship\'s Radio'),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                return RefreshIndicator(
                  color: AppColors.primaryGold,
                  backgroundColor: AppColors.surface,
                  onRefresh: _onRefresh,
                  child: messages.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 160),
                            KompassEmptyState(
                              title: 'No messages yet',
                              message: 'Be the first to say ahoy!',
                              icon: Icons.chat_bubble_outline,
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                messages[messages.length - 1 - index];
                            final isMe = message.senderId == currentUserId;
                            return _MessageBubble(message: message, isMe: isMe);
                          },
                        ),
                );
              },
              loading: () => const Center(child: KompassLoading()),
              error: (e, st) => RefreshIndicator(
                color: AppColors.primaryGold,
                backgroundColor: AppColors.surface,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 160),
                    Center(child: Text('Error: $e')),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      cursorColor: AppColors.primaryNeon,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.primaryNeon,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryNeon,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppColors.textOnPrimary,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});
  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryNeon : AppColors.surface,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(2) : null,
            bottomLeft: !isMe ? const Radius.circular(2) : null,
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
          boxShadow: [
            if (isMe)
              BoxShadow(
                color: AppColors.primaryNeon.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) ...[
              Text(
                message.senderName.isNotEmpty ? message.senderName : 'Explorer',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryNeon,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (message.timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatTime(message.timestamp!),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                  color: isMe
                      ? AppColors.textOnPrimary.withValues(alpha: 0.65)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
