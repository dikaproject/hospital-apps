class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  // Safer fromJson method
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    try {
      return ChatMessage(
        text: json['text']?.toString() ?? '',
        isUser: json['isUser'] == true,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        metadata: json['metadata'] is Map<String, dynamic>
            ? json['metadata'] as Map<String, dynamic>
            : null,
      );
    } catch (e) {
      print('Error parsing ChatMessage: $e');
      // Return fallback message
      return ChatMessage(
        text: json['text']?.toString() ?? 'Pesan tidak dapat dimuat',
        isUser: json['isUser'] == true,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}
