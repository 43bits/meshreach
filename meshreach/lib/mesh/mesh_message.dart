import 'package:uuid/uuid.dart';

enum MeshMsgType { text, voice, file, location, sos, ack }

class MeshMessage {
  final String uuid;
  final String from;
  final MeshMsgType type;
  final String encryptedData;
  final String iv;
  int ttl;
  final List<String> hops;
  final int ts;

  MeshMessage({
    String? uuid,
    required this.from,
    required this.type,
    required this.encryptedData,
    required this.iv,
    this.ttl = 7,
    List<String>? hops,
    int? ts,
  })  : uuid = uuid ?? const Uuid().v4(),
        hops = hops ?? [],
        ts = ts ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'from': from,
        'type': type.name,
        'data': encryptedData,
        'iv': iv,
        'ttl': ttl,
        'hops': hops,
        'ts': ts,
      };

  factory MeshMessage.fromJson(Map<String, dynamic> j) => MeshMessage(
        uuid: j['uuid'],
        from: j['from'],
        type: MeshMsgType.values.byName(j['type'] ?? 'text'),
        encryptedData: j['data'],
        iv: j['iv'],
        ttl: j['ttl'] ?? 7,
        hops: List<String>.from(j['hops'] ?? []),
        ts: j['ts'],
      );
}