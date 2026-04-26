import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meshreach/mesh/mesh_manager.dart';
import 'package:meshreach/models/peer.dart';
import 'package:meshreach/components/stat_counter.dart';
import 'package:meshreach/components/peer_card.dart';
import 'package:meshreach/components/sos_button.dart';
import 'package:meshreach/services/sos_service.dart';
import 'package:meshreach/nav.dart';
import 'package:meshreach/theme.dart';

class PeerListScreen extends StatefulWidget {
  const PeerListScreen({super.key});
  @override
  State<PeerListScreen> createState() => _PeerListScreenState();
}

class _PeerListScreenState extends State<PeerListScreen> {
  StreamSubscription? _sub;
  List<Peer> _peers = [];
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    _sub = MeshManager().updates.listen((_) => _refresh());
    _refresh();
    // show scanning indicator for 3s
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _scanning = false);
    });
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _peers = MeshManager().connectedPeers.map((id) => Peer(
        id: id,
        deviceName: id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase(),
        connectionType: 'WiFi Direct',
        isConnected: true,
        lastSeen: DateTime.now(),
      )).toList();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handleSOS() async {
    await SosService.broadcast();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('SOS BROADCAST SENT', style: dmMonoStyle.copyWith(fontSize: 12)),
      backgroundColor: MeshColors.sosButton,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MeshColors.background,
      appBar: AppBar(
        backgroundColor: MeshColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('MESHREACH',
            style: dmMonoStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Scanning indicator
                if (_scanning)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10, height: 10,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: MeshColors.muted),
                        ),
                        const SizedBox(width: 10),
                        Text('SCANNING NEARBY DEVICES...',
                            style: dmMonoStyle.copyWith(
                                fontSize: 10, color: MeshColors.muted, letterSpacing: 0.8)),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      StatCounter(label: 'peers', count: _peers.length),
                      const SizedBox(width: 8),
                      StatCounter(label: 'connected', count: _peers.length),
                    ],
                  ),
                ),
                Expanded(
                  child: _peers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('NO PEERS FOUND',
                                  style: dmMonoStyle.copyWith(
                                      color: MeshColors.muted, fontSize: 12, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              Text('ensure both devices have app open',
                                  style: dmMonoStyle.copyWith(
                                      color: MeshColors.cardBorder, fontSize: 10)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _peers.length,
                          itemBuilder: (context, i) => PeerCard(
                            peer: _peers[i],
                            onTap: () => context.go(
                                AppRoutes.chatForPeer(_peers[i].id),
                                extra: _peers[i]),
                          ),
                        ),
                ),
              ],
            ),
            Positioned(right: 20, bottom: 20, child: SOSButton(onPressed: _handleSOS)),
          ],
        ),
      ),
    );
  }
}