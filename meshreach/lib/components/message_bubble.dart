import 'package:flutter/material.dart';

import 'package:meshreach/models/chat_message.dart';
import 'package:meshreach/theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent;
    final bubbleColor = isSent ? MeshColors.bubbleSent : MeshColors.cardBackground;
    final showBorder = !isSent;

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            border: showBorder ? Border.all(color: MeshColors.cardBorder, width: 1) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: _BubbleContent(message: message),
        ),
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  final ChatMessage message;

  const _BubbleContent({required this.message});

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case ChatMessageType.voice:
        return _IconRow(
          icon: Icons.graphic_eq,
          primary: 'VOICE',
          secondary: _formatDuration(message.durationSeconds ?? 0),
        );
      case ChatMessageType.location:
        final lat = (message.latitude ?? 0).toStringAsFixed(2);
        final lng = (message.longitude ?? 0).toStringAsFixed(2);
        return _IconRow(
          icon: Icons.location_pin,
          primary: 'LOCATION',
          secondary: '$lat, $lng',
        );
      case ChatMessageType.file:
        return _IconRow(
          icon: Icons.attach_file,
          primary: 'FILE',
          secondary: message.filename ?? 'unknown',
        );
      case ChatMessageType.text:
        return Text(message.text, style: dmMonoStyle.copyWith(fontSize: 13, height: 1.35));
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String primary;
  final String secondary;

  const _IconRow({required this.icon, required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: MeshColors.muted),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(primary, style: dmMonoStyle.copyWith(fontSize: 11, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(secondary, softWrap: true, style: dmMonoStyle.copyWith(fontSize: 12, color: MeshColors.muted, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
