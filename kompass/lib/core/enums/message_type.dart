/// Enum for message types in the chat system.
enum MessageType {
  text('text'),
  announcement('announcement'),
  sos('sos'),
  system('system');

  const MessageType(this.value);
  final String value;

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (t) => t.value.toLowerCase() == value.toLowerCase(),
      orElse: () => MessageType.text,
    );
  }
}
