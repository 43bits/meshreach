import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '../mesh/mesh_manager.dart';
import '../mesh/mesh_message.dart';

class SosService {
  static final _notif = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _notif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  static Future<void> broadcast() async {
    final pos = await Geolocator.getCurrentPosition();
    await MeshManager().sendMessage(
      'SOS|${pos.latitude},${pos.longitude}',
      MeshMsgType.sos,
    );
  }

  static Future<void> showIncoming(String from, String location) async {
    await _notif.show(
      0,
      '🆘 SOS ALERT',
      'From: $from · Location: $location',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sos_channel', 'SOS Alerts',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
        ),
      ),
    );
  }
}