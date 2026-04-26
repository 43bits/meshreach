import 'package:flutter/material.dart';

import 'package:meshreach/components/sos_overlay.dart';
import 'package:meshreach/theme.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  void _openOverlay(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => const SosOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeshColors.background,
      appBar: AppBar(
        backgroundColor: MeshColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('SOS', style: dmMonoStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1)),
      ),
      body: Center(
        child: OutlinedButton(
          onPressed: () => _openOverlay(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: MeshColors.sosButton, width: 1),
            foregroundColor: MeshColors.sosButton,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Text('OPEN SOS OVERLAY', style: dmMonoStyle.copyWith(color: MeshColors.sosButton, fontSize: 12, letterSpacing: 0.8)),
        ),
      ),
    );
  }
}
