import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:go_router/go_router.dart';
import 'package:meshreach/models/peer.dart';
import 'package:meshreach/services/peer_service.dart';
import 'package:meshreach/components/stat_counter.dart';
import 'package:meshreach/components/peer_card.dart';
import 'package:meshreach/components/sos_button.dart';
import 'package:meshreach/nav.dart';
import 'package:meshreach/services/sos_service.dart';
import 'package:meshreach/theme.dart';
import 'package:meshreach/mesh/mesh_manager.dart';

class PeerListScreen extends StatefulWidget {
  const PeerListScreen({super.key});

  @override
  State<PeerListScreen> createState() => _PeerListScreenState();
}

class _PeerListScreenState extends State<PeerListScreen> {
  final PeerService _peerService = PeerService();
  List<Peer> _peers = [];
  int _messagesCount = 0;
  int _acksCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(showLoading: true);
  }

  // Future<void> _loadData({required bool showLoading}) async {
  //   if (showLoading) {
  //     setState(() => _isLoading = true);
  //   }
  //   try {
  //     final peers = await _peerService.getPeers();
  //     final messages = await _peerService.getMessagesCount();
  //     final acks = await _peerService.getAcksCount();

  //     if (!mounted) return;
  //     setState(() {
  //       _peers = peers;
  //       _messagesCount = messages;
  //       _acksCount = acks;
  //     });
  //   } catch (e) {
  //     debugPrint('Failed to load data: $e');
  //   } finally {
  //     if (!mounted) return;
  //     setState(() => _isLoading = false);
  //   }
  // }
  // Add import
// Replace _loadData

Future<void> _loadData({required bool showLoading}) async {
  if (showLoading) setState(() => _isLoading = true);
  try {
    final mesh = MeshManager();
    final dbPeers = mesh.connectedPeers.map((d) => Peer(
      id: d.deviceId,
      deviceName: d.deviceName,
      connectionType: 'WiFi Direct',
      isConnected: d.state == SessionState.connected,
      lastSeen: DateTime.now(),
    )).toList();
    final messages = await _peerService.getMessagesCount();
    final acks = await _peerService.getAcksCount();
    if (!mounted) return;
    setState(() {
      _peers = dbPeers.isEmpty ? _peerService._getSamplePeers() : dbPeers;
      _messagesCount = messages;
      _acksCount = acks;
    });
  } catch (e) {
    debugPrint('loadData: $e');
  } finally {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}

  Future<void> _onRefresh() async => _loadData(showLoading: false);

  // void _handleSOS() {
  //   debugPrint('SOS button pressed!');
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         'SOS Signal Sent',
  //         style: dmMonoStyle.copyWith(fontSize: 12),
  //       ),
  //       backgroundColor: MeshColors.sosButton,
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }
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
    final connectedPeers = _peers.where((p) => p.isConnected).length;

    return Scaffold(
      backgroundColor: MeshColors.background,
      appBar: AppBar(
        backgroundColor: MeshColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'MESHREACH',
          style: dmMonoStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      StatCounter(label: 'peers', count: connectedPeers),
                      const SizedBox(width: 8),
                      StatCounter(label: 'msgs', count: _messagesCount),
                      const SizedBox(width: 8),
                      StatCounter(label: 'ack', count: _acksCount),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: MeshColors.muted, strokeWidth: 2),
                        )
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: MeshColors.textPrimary,
                          backgroundColor: MeshColors.cardBackground,
                          child: _peers.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  children: [
                                    const SizedBox(height: 40),
                                    Center(
                                      child: Text('No peers found', style: dmMonoStyle.copyWith(color: MeshColors.muted, fontSize: 12)),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: _peers.length,
                                  itemBuilder: (context, index) {
                                    final peer = _peers[index];
                                    return PeerCard(
                                      peer: peer,
                                      onTap: () => context.go(AppRoutes.chatForPeer(peer.id), extra: peer),
                                    );
                                  },
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
