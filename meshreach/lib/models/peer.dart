class Peer {
  final String id;
  final String deviceName;
  final String connectionType;
  final bool isConnected;
  final DateTime lastSeen;

  Peer({
    required this.id,
    required this.deviceName,
    required this.connectionType,
    required this.isConnected,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectionType': connectionType,
    'isConnected': isConnected,
    'lastSeen': lastSeen.toIso8601String(),
  };

  factory Peer.fromJson(Map<String, dynamic> json) => Peer(
    id: json['id'] as String,
    deviceName: json['deviceName'] as String,
    connectionType: json['connectionType'] as String,
    isConnected: json['isConnected'] as bool,
    lastSeen: DateTime.parse(json['lastSeen'] as String),
  );

  Peer copyWith({
    String? id,
    String? deviceName,
    String? connectionType,
    bool? isConnected,
    DateTime? lastSeen,
  }) => Peer(
    id: id ?? this.id,
    deviceName: deviceName ?? this.deviceName,
    connectionType: connectionType ?? this.connectionType,
    isConnected: isConnected ?? this.isConnected,
    lastSeen: lastSeen ?? this.lastSeen,
  );
}
