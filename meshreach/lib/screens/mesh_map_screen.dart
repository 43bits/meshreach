import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:meshreach/mesh/mesh_manager.dart';
import 'package:meshreach/theme.dart';

class MeshMapScreen extends StatefulWidget {
  const MeshMapScreen({super.key});
  @override
  State<MeshMapScreen> createState() => _MeshMapScreenState();
}

class _MeshMapScreenState extends State<MeshMapScreen> {
  MaplibreMapController? _mapController;
  Position? _myPosition;
  final List<LatLng> _peerPositions = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _myPosition = pos);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 14),
      );
      _addMarkers();
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _addMarkers() async {
    final ctrl = _mapController;
    if (ctrl == null || _myPosition == null) return;

    // You dot
    await ctrl.addCircle(CircleOptions(
      geometry: LatLng(_myPosition!.latitude, _myPosition!.longitude),
      circleRadius: 8,
      circleColor: '#00FF00',
      circleStrokeWidth: 2,
      circleStrokeColor: '#000000',
    ));

    // Peer dots (from connected peers — placeholder offset for demo)
    for (int i = 0; i < MeshManager().connectedPeers.length; i++) {
      await ctrl.addCircle(CircleOptions(
        geometry: LatLng(
          (_myPosition!.latitude) + (i + 1) * 0.0005,
          (_myPosition!.longitude) + (i + 1) * 0.0005,
        ),
        circleRadius: 8,
        circleColor: '#3B82F6',
        circleStrokeWidth: 2,
        circleStrokeColor: '#000000',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final peerCount = MeshManager().connectedPeers.length;
    return Scaffold(
      backgroundColor: MeshColors.background,
      appBar: AppBar(
        backgroundColor: MeshColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('MESH MAP',
            style: dmMonoStyle.copyWith(
                fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _Chip(text: '$peerCount PEERS'),
          ),
        ],
      ),
      body: Stack(
        children: [
          MaplibreMap(
            styleString:
                'https://demotiles.maplibre.org/style.json', // offline tile server in prod
            initialCameraPosition: CameraPosition(
              target: _myPosition != null
                  ? LatLng(_myPosition!.latitude, _myPosition!.longitude)
                  : const LatLng(22.44, 88.41),
              zoom: 14,
            ),
            onMapCreated: (ctrl) {
              _mapController = ctrl;
              _addMarkers();
            },
            myLocationEnabled: true,
            compassEnabled: false,
            rotateGesturesEnabled: false,
          ),
          const Positioned(left: 16, bottom: 24, child: _LegendCard()),
        ],
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: MeshColors.cardBackground,
          border: Border.all(color: MeshColors.cardBorder),
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

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label,
              style: dmMonoStyle.copyWith(
                  fontSize: 11,
                  color: MeshColors.textPrimary,
                  letterSpacing: 0.8)),
        ],
      );
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: MeshColors.cardBorder),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text,
            style: dmMonoStyle.copyWith(
                fontSize: 11, color: MeshColors.muted, letterSpacing: 0.6)),
      );
}