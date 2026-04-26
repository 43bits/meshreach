import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:uuid/uuid.dart';

import '../db/mesh_db.dart';
import '../security/crypto.dart';
import 'mesh_message.dart';

class MeshManager extends ChangeNotifier {
  static final MeshManager _i = MeshManager._();
  factory MeshManager() => _i;
  MeshManager._();

  final NearbyService _nearby = NearbyService();
  final String deviceId = const Uuid().v4().substring(0, 8);

  final List<Device> connectedPeers = [];
  final List<Device> nearbyPeers = [];

  Future<void> init(String userName) async {
    await _nearby.init(
      serviceType: 'meshreach',
      deviceName: userName,
      strategy: Strategy.P2P_CLUSTER,
      callback: (devices) {
        connectedPeers
          ..clear()
          ..addAll(devices.where((d) => d.state == SessionState.connected));
        nearbyPeers
          ..clear()
          ..addAll(devices.where((d) => d.state != SessionState.connected));
        notifyListeners();
      },
    );

    _nearby.dataReceivedSubscription(callback: (data) async {
      try {
        final msg = MeshMessage.fromJson(jsonDecode(data.message));
        await _onReceive(msg);
      } catch (e) {
        debugPrint('MeshManager parse error: $e');
      }
    });

    await _nearby.startAdvertisingPeer();
    await _nearby.startBrowsingForPeers();
  }

  Future<void> _onReceive(MeshMessage msg) async {
    if (await MeshDB().isDuplicate(msg.uuid)) return;
    if (msg.ttl <= 0) return;

    // Save to DB
    final plain = MeshCrypto.decrypt(msg.encryptedData, msg.iv);
    await MeshDB().insertMessage({
      'uuid': msg.uuid,
      'type': msg.type.name,
      'content': plain,
      'direction': 'received',
      'peer_id': msg.from,
      'ts': msg.ts,
    });

    // Relay (flood with TTL-1)
    msg.ttl -= 1;
    msg.hops.add(deviceId);
    await broadcast(jsonEncode(msg.toJson()));
  }

  Future<void> sendMessage(String content, MeshMsgType type) async {
    final enc = MeshCrypto.encrypt(content);
    final msg = MeshMessage(
      from: deviceId,
      type: type,
      encryptedData: enc['data']!,
      iv: enc['iv']!,
    );
    await MeshDB().insertMessage({
      'uuid': msg.uuid,
      'type': type.name,
      'content': content,
      'direction': 'sent',
      'peer_id': 'broadcast',
      'ts': msg.ts,
    });
    await broadcast(jsonEncode(msg.toJson()));
  }

  Future<void> broadcast(String payload) async {
    for (final peer in connectedPeers) {
      try {
        await _nearby.sendMessage(peer.deviceId, payload);
      } catch (e) {
        debugPrint('Send to ${peer.deviceId} failed: $e');
      }
    }
  }

  void dispose() {
    _nearby.stopAdvertisingPeer();
    _nearby.stopBrowsingForPeers();
    super.dispose();
  }
}