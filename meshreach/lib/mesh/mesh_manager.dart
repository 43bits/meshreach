// import 'dart:async';
// import 'dart:convert';
// // import 'dart:typed_data';
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:nearby_connections/nearby_connections.dart';
// import 'package:uuid/uuid.dart';
// import '../db/mesh_db.dart';
// import '../security/crypto.dart';
// import 'mesh_message.dart';

// class MeshManager extends ChangeNotifier {
//   final StreamController<void> _updateStream = StreamController.broadcast();
//   Stream<void> get updates => _updateStream.stream;
//   static final MeshManager _i = MeshManager._();
//   factory MeshManager() => _i;
//   MeshManager._();

//   final String deviceId = const Uuid().v4().substring(0, 8);
//   final Set<String> _connectedIds = {};
//   List<String> get connectedPeers => _connectedIds.toList();

//   Future<void> init(String userName) async {
//     try {
//       await Nearby().startAdvertising(
//         userName,
//         Strategy.P2P_CLUSTER,
//         onConnectionInitiated: _onConnectionInitiated,
//         onConnectionResult: (id, status) {
//           if (status == Status.CONNECTED) {
//             _connectedIds.add(id);
//           } else {
//             _connectedIds.remove(id);
//           }
//           // notifyListeners();
//           _updateStream.add(null);
//         },
//         onDisconnected: (id) {
//           _connectedIds.remove(id);
//           // notifyListeners();
//           _updateStream.add(null);
//         },
//         serviceId: 'com.meshreach.app',
//       );

//       await Nearby().startDiscovery(
//         userName,
//         Strategy.P2P_CLUSTER,
//         onEndpointFound: (id, name, serviceId) async {
//           try {
//             await Nearby().requestConnection(
//               userName, id,
//               onConnectionInitiated: _onConnectionInitiated,
//               onConnectionResult: (id, status) {
//                 if (status == Status.CONNECTED) {
//                   _connectedIds.add(id);
//                 } else {
//                   _connectedIds.remove(id);
//                 }
//                 // notifyListeners();
//                 _updateStream.add(null);
//               },
//               onDisconnected: (id) {
//                 _connectedIds.remove(id);
//                 // notifyListeners();
//                 _updateStream.add(null);
//               },
//             );
//           } catch (e) {
//             debugPrint('requestConnection error: $e');
//           }
//         },
//         // onEndpointLost: (id) => notifyListeners(),
//         onEndpointLost: (id) => _updateStream.add(null),
//         serviceId: 'com.meshreach.app',
//       );
//     } catch (e) {
//       debugPrint('MeshManager init error: $e');
//     }
//   }

//   void _onConnectionInitiated(String id, ConnectionInfo info) async {
//     await Nearby().acceptConnection(
//       id,
//       onPayLoadRecieved: (id, payload) async {
//         if (payload.type == PayloadType.BYTES && payload.bytes != null) {
//           try {
//             final data = utf8.decode(payload.bytes!);
//             final msg = MeshMessage.fromJson(jsonDecode(data));
//             await _onReceive(msg);
//           } catch (e) {
//             debugPrint('payload parse error: $e');
//           }
//         }
//       },
//       onPayloadTransferUpdate: (id, update) {},
//     );
//   }

//   Future<void> _onReceive(MeshMessage msg) async {
//     if (await MeshDB().isDuplicate(msg.uuid)) return;
//     if (msg.ttl <= 0) return;
//     final plain = MeshCrypto.decrypt(msg.encryptedData, msg.iv);
//     await MeshDB().insertMessage({
//       'uuid': msg.uuid, 'type': msg.type.name,
//       'content': plain, 'direction': 'received',
//       'peer_id': msg.from, 'ts': msg.ts,
//     });
//     msg.ttl -= 1;
//     msg.hops.add(deviceId);
//     await broadcast(jsonEncode(msg.toJson()));
//   }

//   Future<void> sendMessage(String content, MeshMsgType type) async {
//     final enc = MeshCrypto.encrypt(content);
//     final msg = MeshMessage(
//       from: deviceId, type: type,
//       encryptedData: enc['data']!, iv: enc['iv']!,
//     );
//     await MeshDB().insertMessage({
//       'uuid': msg.uuid, 'type': type.name,
//       'content': content, 'direction': 'sent',
//       'peer_id': 'broadcast', 'ts': msg.ts,
//     });
//     await broadcast(jsonEncode(msg.toJson()));
//   }

//   Future<void> broadcast(String payload) async {
//     final bytes = Uint8List.fromList(utf8.encode(payload));
//     for (final id in _connectedIds) {
//       try {
//         await Nearby().sendBytesPayload(id, bytes);
//       } catch (e) {
//         debugPrint('send to $id failed: $e');
//       }
//     }
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:meshreach/services/sos_service.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:uuid/uuid.dart';
import '../db/mesh_db.dart';
import '../security/crypto.dart';
import 'mesh_message.dart';

class MeshManager extends ChangeNotifier {
  static final MeshManager _i = MeshManager._();
  factory MeshManager() => _i;
  MeshManager._();

  final StreamController<void> _updateStream = StreamController.broadcast();
  Stream<void> get updates => _updateStream.stream;

// fix
  final StreamController<Map<String,dynamic>> _msgStream = StreamController.broadcast();
  Stream<Map<String,dynamic>> get messageStream => _msgStream.stream;
  // 

  final String deviceId = const Uuid().v4().substring(0, 8);
  final Set<String> _connectedIds = {};
  List<String> get connectedPeers => _connectedIds.toList();

  Future<void> init(String userName) async {
    try {
      await Nearby().startAdvertising(
        userName,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            _connectedIds.add(id);
          } else {
            _connectedIds.remove(id);
          }
          _updateStream.add(null);
          notifyListeners();
        },
        onDisconnected: (id) {
          _connectedIds.remove(id);
          _updateStream.add(null);
          notifyListeners();
        },
        serviceId: 'com.meshreach.app',
      );

      await Nearby().startDiscovery(
        userName,
        Strategy.P2P_CLUSTER,
        onEndpointFound: (id, name, serviceId) async {
          try {
            await Nearby().requestConnection(
              userName, id,
              onConnectionInitiated: _onConnectionInitiated,
              onConnectionResult: (id, status) {
                if (status == Status.CONNECTED) {
                  _connectedIds.add(id);
                } else {
                  _connectedIds.remove(id);
                }
                _updateStream.add(null);
                notifyListeners();
              },
              onDisconnected: (id) {
                _connectedIds.remove(id);
                _updateStream.add(null);
                notifyListeners();
              },
            );
          } catch (e) {
            debugPrint('requestConnection error: $e');
          }
        },
        onEndpointLost: (id) {
          _updateStream.add(null);
          notifyListeners();
        },
        serviceId: 'com.meshreach.app',
      );
    } catch (e) {
      debugPrint('MeshManager init error: $e');
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) async {
    await Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (id, payload) async {
        if (payload.type == PayloadType.BYTES && payload.bytes != null) {
          try {
            final data = utf8.decode(payload.bytes!);
            final msg = MeshMessage.fromJson(jsonDecode(data));
            await _onReceive(msg);
          } catch (e) {
            debugPrint('payload parse error: $e');
          }
        }
      },
      onPayloadTransferUpdate: (id, update) {},
    );
  }

  Future<void> _onReceive(MeshMessage msg) async {
    if (await MeshDB().isDuplicate(msg.uuid)) return;
    if (msg.ttl <= 0) return;
    
    final plain = MeshCrypto.decrypt(msg.encryptedData, msg.iv);

    if (msg.type == MeshMsgType.sos) {
    final parts = plain.split('|');
    final location = parts.length > 1 ? parts[1] : 'unknown';
    await SosService.showIncoming(msg.from, location);
    }
    await MeshDB().insertMessage({
      'uuid': msg.uuid, 'type': msg.type.name,
      'content': plain, 'direction': 'received',
      'peer_id': msg.from, 'ts': msg.ts,
    });
    _msgStream.add({'peer_id': msg.from, 'content': plain, 'type': msg.type.name, 'ts': msg.ts});
    msg.ttl -= 1;
    msg.hops.add(deviceId);
    _updateStream.add(null);
    await broadcast(jsonEncode(msg.toJson()));
  }

  Future<void> sendMessage(String content, MeshMsgType type) async {
    final enc = MeshCrypto.encrypt(content);
    final msg = MeshMessage(
      from: deviceId, type: type,
      encryptedData: enc['data']!, iv: enc['iv']!,
    );
    await MeshDB().insertMessage({
      'uuid': msg.uuid, 'type': type.name,
      'content': content, 'direction': 'sent',
      'peer_id': 'broadcast', 'ts': msg.ts,
    });
    await broadcast(jsonEncode(msg.toJson()));
  }

  Future<void> broadcast(String payload) async {
    final bytes = Uint8List.fromList(utf8.encode(payload));
    for (final id in List.from(_connectedIds)) {
      try {
        await Nearby().sendBytesPayload(id, bytes);
      } catch (e) {
        debugPrint('send to $id failed: $e');
      }
    }
  }
}