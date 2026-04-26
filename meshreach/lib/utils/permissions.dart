import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<void> requestAll() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
      Permission.microphone,
    ].request();
  }
}