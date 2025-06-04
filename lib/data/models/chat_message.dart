class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderId = json['senderUserId']?.toString() ?? '';
    
    String senderName;
    if (senderId == '1') {
      senderName = 'Suporte';
    } else if (senderId == currentUserId) {
      senderName = 'Você';
    } else {
      senderName = 'Usuário';
    }
    
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: senderId,
      senderName: senderName,
      content: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      type: MessageType.text,
      isMe: senderId == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }
}

enum MessageType {
  text,
  image,
  system
}