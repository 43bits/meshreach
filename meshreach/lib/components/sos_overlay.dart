import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:meshreach/theme.dart';

class SosOverlay extends StatelessWidget {
  const SosOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: MeshColors.cardBackground,
          border: Border.all(color: MeshColors.sosButton, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded, color: MeshColors.sosButton, size: 48),
            const SizedBox(height: 14),
            Text('SOS ALERT', textAlign: TextAlign.center, style: dmMonoStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 12),
            Text('From: 850248fb...', style: dmMonoStyle.copyWith(color: MeshColors.muted, fontSize: 11)),
            const SizedBox(height: 10),
            Text('SOS — HELP ME!', style: dmMonoStyle.copyWith(color: MeshColors.textPrimary, fontSize: 13, height: 1.4)),
            const SizedBox(height: 10),
            Text('Location: 22.44, 88.41', style: dmMonoStyle.copyWith(color: MeshColors.muted, fontSize: 11)),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: MeshColors.sosButton, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
              child: Text('ACKNOWLEDGED', style: dmMonoStyle.copyWith(color: MeshColors.sosButton, fontSize: 12, letterSpacing: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
