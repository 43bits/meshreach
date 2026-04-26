import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:meshreach/theme.dart';

class MeshMapScreen extends StatelessWidget {
  const MeshMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeshColors.background,
      appBar: AppBar(
        backgroundColor: MeshColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          icon: const Icon(Icons.arrow_back, color: MeshColors.muted, size: 20),
        ),
        title: Text('MESH MAP', style: dmMonoStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: _OutlinedChip(text: '0 PEERS'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: MeshColors.cardBackground,
                  border: Border.all(color: MeshColors.cardBorder, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  'MAP RENDERS HERE',
                  style: dmMonoStyle.copyWith(color: MeshColors.muted, fontSize: 12, letterSpacing: 1),
                ),
              ),
            ),
            const Positioned(
              left: 20,
              bottom: 20,
              child: _LegendCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MeshColors.cardBackground,
        border: Border.all(color: MeshColors.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _LegendRow(color: MeshColors.statusConnected, label: 'YOU'),
          SizedBox(height: 8),
          _LegendRow(color: MeshColors.statusPeer, label: 'MESH PEERS'),
          SizedBox(height: 8),
          _LegendRow(color: MeshColors.statusShared, label: 'SHARED LOCATION'),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(label, style: dmMonoStyle.copyWith(fontSize: 11, color: MeshColors.textPrimary, letterSpacing: 0.8)),
      ],
    );
  }
}

class _OutlinedChip extends StatelessWidget {
  final String text;

  const _OutlinedChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: MeshColors.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: dmMonoStyle.copyWith(fontSize: 11, color: MeshColors.muted, letterSpacing: 0.6)),
    );
  }
}
