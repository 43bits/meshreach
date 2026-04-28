import 'package:flutter/material.dart';
import 'package:meshreach/db/mesh_db.dart';
import 'package:meshreach/mesh/mesh_manager.dart';
import 'package:meshreach/services/sos_service.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'nav.dart';
import 'package:flutter/services.dart';
import 'utils/permissions.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await MeshDB().db; // init DB
//   await MeshManager().init('user_${DateTime.now().millisecondsSinceEpoch % 9999}');
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {

//     return MaterialApp.router(
//       title: 'MeshReach',
//       debugShowCheckedModeBanner: false,


//       theme: lightTheme,
//       darkTheme: darkTheme,
//       themeMode: ThemeMode.dark,
//       routerConfig: AppRouter.router,
//     );
//   }
// }


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.light,
//   ));
//   await AppPermissions.requestAll();
//   await MeshDB().db;
//   await MeshManager().init('node_${DateTime.now().millisecondsSinceEpoch % 9999}');
//   runApp(const MeshReachApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AppPermissions.requestAll();
  debugPrint('Ensure WiFi radio ON + Bluetooth ON for mesh to work');
  await MeshDB().db;
  // Use device ID slice as name so each device shows unique
  final name = 'node_${DateTime.now().millisecondsSinceEpoch % 9999}';
  await MeshManager().init(name);
  runApp(const MeshReachApp());
  await SosService.init();
}

class MeshReachApp extends StatelessWidget {
  const MeshReachApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'MeshReach',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
      );
}
