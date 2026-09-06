import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/message_model.dart';
import '../data/models/announcement_model.dart';
import '../data/repositories/message_repository.dart';
import '../data/repositories/announcement_repository.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository();
});

final tourMessagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, tourId) {
  return ref.watch(messageRepositoryProvider).watchMessages(tourId);
});

final tourAnnouncementsProvider =
    StreamProvider.family<List<AnnouncementModel>, String>((ref, tourId) {
  return ref.watch(announcementRepositoryProvider).watchAnnouncements(tourId);
});
