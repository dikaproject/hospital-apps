class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? attachmentUrl;
  final Map<String, dynamic>? metadata; // Add this field

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.attachmentUrl,
    this.metadata, // Add this parameter
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      attachmentUrl: json['attachmentUrl'],
      metadata: json['metadata'], // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'attachmentUrl': attachmentUrl,
      'metadata': metadata, // Add this line
    };
  }
}