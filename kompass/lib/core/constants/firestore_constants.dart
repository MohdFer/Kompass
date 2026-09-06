/// Firestore collection and field name constants.
library;

class FirestoreConstants {
  FirestoreConstants._();

  // Collection Names
  static const String usersCollection = 'Users';
  static const String toursCollection = 'Tours';
  static const String participantsCollection = 'Participants';
  static const String attendanceCollection = 'Attendance';
  static const String messagesCollection = 'Messages';
  static const String locationsCollection = 'Locations';
  static const String announcementsCollection = 'Announcements';

  // User Fields
  static const String fieldUserId = 'userId';
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldRole = 'role';
  static const String fieldProfileImage = 'profileImage';
  static const String fieldCreatedAt = 'createdAt';

  // Tour Fields
  static const String fieldTourId = 'tourId';
  static const String fieldDescription = 'description';
  static const String fieldStartDate = 'startDate';
  static const String fieldEndDate = 'endDate';
  static const String fieldGuideId = 'guideId';
  static const String fieldParticipantIds = 'participantIds';
  static const String fieldStatus = 'status';

  // Attendance Fields
  static const String fieldAttendanceId = 'attendanceId';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldLocation = 'location';
  static const String fieldMethod = 'method';

  // Message Fields
  static const String fieldMessageId = 'messageId';
  static const String fieldSenderId = 'senderId';
  static const String fieldMessage = 'message';
  static const String fieldMessageType = 'type';

  // Location Fields
  static const String fieldLocationId = 'locationId';
  static const String fieldLatitude = 'latitude';
  static const String fieldLongitude = 'longitude';

  // Announcement Fields
  static const String fieldAnnouncementId = 'announcementId';
  static const String fieldTitle = 'title';
  static const String fieldCreatedBy = 'createdBy';
}
