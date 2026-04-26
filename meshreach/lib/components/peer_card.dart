import 'package:flutter/material.dart';
import 'package:meshreach/models/peer.dart';
import 'package:meshreach/theme.dart';

class PeerCard extends StatelessWidget {
  final Peer peer;
  final VoidCallback? onTap;

  const PeerCard({super.key, required this.peer, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MeshColors.cardBackground,
          border: Border.all(color: MeshColors.cardBorder, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: peer.isConnected ? MeshColors.statusConnected : MeshColors.statusDisconnected,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                peer.deviceName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: dmMonoStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.8),
              ),
            ),
            const SizedBox(width: 10),
            _OutlinedTag(text: peer.connectionType.toUpperCase()),
          ],
        ),
      ),
    );
  }
}

class _OutlinedTag extends StatelessWidget {
  final String text;

  const _OutlinedTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: MeshColors.inputBorder, width: 1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: dmMonoStyle.copyWith(fontSize: 10, color: MeshColors.muted, letterSpacing: 0.6)),
    );
  }
}
