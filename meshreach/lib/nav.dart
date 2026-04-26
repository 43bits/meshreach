import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:meshreach/models/peer.dart';
import 'package:meshreach/screens/chat_screen.dart';
import 'package:meshreach/screens/mesh_map_screen.dart';
import 'package:meshreach/screens/peer_list_screen.dart';
import 'package:meshreach/screens/sos_screen.dart';
import 'package:meshreach/screens/tabs_shell.dart';

class AppRoutes {
  static const String home = '/';
  static const String chat = '/chat';
  static const String map = '/map';
  static const String sos = '/sos';

  static String chatForPeer(String peerId) => '/chat/$peerId';
}

/// GoRouter configuration.
///
/// The app uses a bottom-tab shell with 4 branches:
/// - Home (/)
/// - Chat (/chat and /chat/:peerId)
/// - Map (/map)
/// - SOS (/sos)
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => TabsShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(child: PeerListScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chat,
                name: 'chat_root',
                pageBuilder: (context, state) => const NoTransitionPage(child: ChatScreen(peer: null)),
                routes: [
                  GoRoute(
                    path: ':peerId',
                    name: 'chat_peer',
                    pageBuilder: (context, state) {
                      final peer = state.extra as Peer?;
                      final peerId = state.pathParameters['peerId'] ?? '';
                      return NoTransitionPage(child: ChatScreen(peer: peer, peerId: peerId.isEmpty ? null : peerId));
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                name: 'map',
                pageBuilder: (context, state) => const NoTransitionPage(child: MeshMapScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sos,
                name: 'sos',
                pageBuilder: (context, state) => const NoTransitionPage(child: SosScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
