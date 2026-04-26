import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:meshreach/theme.dart';

class TabsShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const TabsShell({super.key, required this.navigationShell});

  void _goBranch(BuildContext context, int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeshColors.background,
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: MeshColors.background,
        indicatorColor: Colors.transparent,
        elevation: 0,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => _goBranch(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: MeshColors.muted),
            selectedIcon: Icon(Icons.home, color: MeshColors.textPrimary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: MeshColors.muted),
            selectedIcon: Icon(Icons.chat_bubble, color: MeshColors.textPrimary),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined, color: MeshColors.muted),
            selectedIcon: Icon(Icons.map, color: MeshColors.textPrimary),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.crisis_alert_outlined, color: MeshColors.muted),
            selectedIcon: Icon(Icons.crisis_alert, color: MeshColors.sosButton),
            label: 'SOS',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
    );
  }
}
