import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshreach/models/peer.dart';

class PeerService {
  static const String _peersKey = 'peers';
  static const String _messagesCountKey = 'messages_count';
  static const String _acksCountKey = 'acks_count';

  Future<List<Peer>> getPeers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final peersJson = prefs.getString(_peersKey);
      
      if (peersJson == null) {
        final samplePeers = getSamplePeers();
        await savePeers(samplePeers);
        return samplePeers;
      }

      final List<dynamic> decoded = jsonDecode(peersJson);
      return decoded.map((json) {
        try {
          return Peer.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Failed to decode peer: $e');
          return null;
        }
      }).whereType<Peer>().toList();
    } catch (e) {
      debugPrint('Failed to load peers: $e');
      return getSamplePeers();
    }
  }

  Future<void> savePeers(List<Peer> peers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final peersJson = jsonEncode(peers.map((p) => p.toJson()).toList());
      await prefs.setString(_peersKey, peersJson);
    } catch (e) {
      debugPrint('Failed to save peers: $e');
    }
  }

  Future<int> getMessagesCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_messagesCountKey) ?? 42;
    } catch (e) {
      debugPrint('Failed to load messages count: $e');
      return 42;
    }
  }

  Future<int> getAcksCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_acksCountKey) ?? 38;
    } catch (e) {
      debugPrint('Failed to load acks count: $e');
      return 38;
    }
  }

  Future<void> setMessagesCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_messagesCountKey, count);
    } catch (e) {
      debugPrint('Failed to save messages count: $e');
    }
  }

  Future<void> setAcksCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_acksCountKey, count);
    } catch (e) {
      debugPrint('Failed to save acks count: $e');
    }
  }

  // List<Peer> _getSamplePeers() => [
  //   Peer(
  //     id: '1',
  //     deviceName: 'PIXEL 8 PRO',
  //     connectionType: 'WiFi Direct',
  //     isConnected: true,
  //     lastSeen: DateTime.now(),
  //   ),
  //   Peer(
  //     id: '2',
  //     deviceName: 'IPHONE 15',
  //     connectionType: 'WiFi Direct',
  //     isConnected: true,
  //     lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
  //   ),
  //   Peer(
  //     id: '3',
  //     deviceName: 'SAMSUNG TAB S9',
  //     connectionType: 'WiFi Direct',
  //     isConnected: false,
  //     lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
  //   ),
  //   Peer(
  //     id: '4',
  //     deviceName: 'MACBOOK PRO',
  //     connectionType: 'WiFi Direct',
  //     isConnected: true,
  //     lastSeen: DateTime.now().subtract(const Duration(seconds: 30)),
  //   ),
  //   Peer(
  //     id: '5',
  //     deviceName: 'DELL XPS 13',
  //     connectionType: 'WiFi Direct',
  //     isConnected: false,
  //     lastSeen: DateTime.now().subtract(const Duration(days: 1)),
  //   ),
  // ];
  List<Peer> getSamplePeers() => [
  Peer(
    id: '1',
    deviceName: 'PIXEL 8 PRO',
    connectionType: 'WiFi Direct',
    isConnected: true,
    lastSeen: DateTime.now(),
  ),
  Peer(
    id: '2',
    deviceName: 'IPHONE 15',
    connectionType: 'WiFi Direct',
    isConnected: true,
    lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  Peer(
    id: '3',
    deviceName: 'SAMSUNG TAB S9',
    connectionType: 'WiFi Direct',
    isConnected: false,
    lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Peer(
    id: '4',
    deviceName: 'MACBOOK PRO',
    connectionType: 'WiFi Direct',
    isConnected: true,
    lastSeen: DateTime.now().subtract(const Duration(seconds: 30)),
  ),
  Peer(
    id: '5',
    deviceName: 'DELL XPS 13',
    connectionType: 'WiFi Direct',
    isConnected: false,
    lastSeen: DateTime.now().subtract(const Duration(days: 1)),
  ),
];
}
