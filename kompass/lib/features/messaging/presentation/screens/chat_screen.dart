import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../providers/messaging_providers.dart';
import '../../data/models/message_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.tourId, super.key});
  final String tourId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
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
      await ref.read(messageRepositoryProvider).sendMessage(widget.tourId, message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
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
                if (messages.isEmpty) {
                  return const KompassEmptyState(
                    title: 'No messages yet',
                    message: 'Be the first to say ahoy!',
                    icon: Icons.chat_bubble_outline,
                  );
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == currentUserId;
                    return _MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
              loading: () => const Center(child: KompassLoading()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
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
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : null,
            bottomLeft: !isMe ? const Radius.circular(0) : null,
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            Text(
              message.message,
              style: AppTextStyles.bodyText.copyWith(
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
