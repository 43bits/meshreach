import 'package:geolocator/geolocator.dart';
import '../mesh/mesh_manager.dart';
import '../mesh/mesh_message.dart';

class SosService {
  static Future<void> broadcast() async {
    final pos = await Geolocator.getCurrentPosition();
    await MeshManager().sendMessage(
      'SOS|${pos.latitude},${pos.longitude}',
      MeshMsgType.sos,
    );
  }
}