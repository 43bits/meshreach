import 'package:flutter/material.dart';
import 'package:meshreach/theme.dart';

class StatCounter extends StatelessWidget {
  final String label;
  final int count;

  const StatCounter({
    super.key,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: MeshColors.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${count.toString()} ${label.toUpperCase()}',
        style: dmMonoStyle.copyWith(fontSize: 11, color: MeshColors.muted, letterSpacing: 0.6),
      ),
    );
  }
}
