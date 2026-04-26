enum ChatMessageType {
  text,
  voice,
  location,
  file,
}

class ChatMessage {
  final String id;
  final String peerId;
  final bool isSent;
  final ChatMessageType type;
  final String text;
  final int? durationSeconds;
  final double? latitude;
  final double? longitude;
  final String? filename;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatMessage({
    required this.id,
    required this.peerId,
    required this.isSent,
    this.type = ChatMessageType.text,
    required this.text,
    this.durationSeconds,
    this.latitude,
    this.longitude,
    this.filename,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'peerId': peerId,
    'isSent': isSent,
    'type': type.name,
    'text': text,
    'durationSeconds': durationSeconds,
    'latitude': latitude,
    'longitude': longitude,
    'filename': filename,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] as String?) ?? 'text';
    final type = ChatMessageType.values.where((e) => e.name == rawType).cast<ChatMessageType?>().firstOrNull ?? ChatMessageType.text;

    return ChatMessage(
      id: json['id'] as String,
      peerId: json['peerId'] as String,
      isSent: json['isSent'] as bool,
      type: type,
      text: (json['text'] as String?) ?? '',
      durationSeconds: json['durationSeconds'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      filename: json['filename'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? peerId,
    bool? isSent,
    ChatMessageType? type,
    String? text,
    int? durationSeconds,
    double? latitude,
    double? longitude,
    String? filename,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ChatMessage(
    id: id ?? this.id,
    peerId: peerId ?? this.peerId,
    isSent: isSent ?? this.isSent,
    type: type ?? this.type,
    text: text ?? this.text,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    filename: filename ?? this.filename,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

extension IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
