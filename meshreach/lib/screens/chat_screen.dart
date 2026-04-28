import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:meshreach/components/message_bubble.dart';
import 'package:meshreach/mesh/mesh_manager.dart';
import 'package:meshreach/mesh/mesh_message.dart';
import 'package:meshreach/models/chat_message.dart';
import 'package:meshreach/models/peer.dart';
import 'package:meshreach/services/chat_service.dart';
import 'package:meshreach/services/peer_service.dart';
import 'package:meshreach/services/sos_service.dart';
import 'package:meshreach/theme.dart';

class ChatScreen extends StatefulWidget {
  final Peer? peer;
  final String? peerId;

  const ChatScreen({super.key, required this.peer, this.peerId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final PeerService _peerService = PeerService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  Peer? _resolvedPeer;


  StreamSubscription? _meshSub;


  @override
  void initState() {
  super.initState();
  unawaited(_resolvePeerAndLoad());
  _meshSub = MeshManager().messageStream.listen((data) {
    if (!mounted) return;
    final now = DateTime.now();
    final msg = ChatMessage(
      id: '${now.microsecondsSinceEpoch}',
      peerId: data['peer_id'],
      isSent: false,
      type: ChatMessageType.text,
      text: data['content'],
      createdAt: now,
      updatedAt: now,
    );
    setState(() => _messages = [..._messages, msg]);
    _scrollToBottomSoon();
  });
  }
  // void initState() {
  //   super.initState();
  //   unawaited(_resolvePeerAndLoad());
  // }
  


  Future<void> _resolvePeerAndLoad() async {
    try {
      if (widget.peer != null) {
        _resolvedPeer = widget.peer;
      } else if (widget.peerId != null) {
        final peers = await _peerService.getPeers();
        _resolvedPeer = peers.where((p) => p.id == widget.peerId).cast<Peer?>().firstOrNull;
      }
    } catch (e) {
      debugPrint('Failed to resolve peer: $e');
    }

    if (!mounted) return;
    if (_resolvedPeer == null) {
      setState(() => _isLoading = false);
      return;
    }
    await _loadMessages(peerId: _resolvedPeer!.id);
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   _focusNode.dispose();
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  void dispose() {
    _meshSub?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({required String peerId}) async {
    try {
      final msgs = await _chatService.getMessages(peerId);
      if (!mounted) return;
      setState(() => _messages = msgs);
      _scrollToBottomSoon();
    } catch (e) {
      debugPrint('Failed to load chat messages: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  // Future<void> _send() async {
  //   final text = _controller.text.trim();
  //   if (text.isEmpty || _isSending) return;
  //   final peer = _resolvedPeer;
  //   if (peer == null) return;

  //   setState(() => _isSending = true);
  //   _controller.clear();

  //   try {
  //     final sent = await _chatService.sendMessage(peerId: peer.id, text: text);
  //     if (!mounted) return;
  //     setState(() => _messages = [..._messages, sent]);
  //     _scrollToBottomSoon();

  //     // Keep the top-level counters feeling “alive” without a backend.
  //     final current = await _peerService.getMessagesCount();
  //     await _peerService.setMessagesCount(current + 1);
  //   } catch (e) {
  //     debugPrint('Failed to send message: $e');
  //   } finally {
  //     if (!mounted) return;
  //     setState(() => _isSending = false);
  //     _focusNode.requestFocus();
  //   }
  // }

  Future<void> _send() async {
  final text = _controller.text.trim();
  if (text.isEmpty || _isSending) return;
  final peer = _resolvedPeer;
  if (peer == null) return;
  setState(() => _isSending = true);
  _controller.clear();
  try {
    await MeshManager().sendMessage(text, MeshMsgType.text);
    final sent = await _chatService.sendMessage(peerId: peer.id, text: text);
    if (!mounted) return;
    setState(() => _messages = [..._messages, sent]);
    _scrollToBottomSoon();
  } finally {
    if (!mounted) return;
    setState(() => _isSending = false);
    _focusNode.requestFocus();
  }
}


  // Future<void> _handleVoice() async {
  //   final peer = _resolvedPeer;
  //   if (peer == null) return;
  //   final msg = await _chatService.sendVoice(peerId: peer.id, durationSeconds: 9, isSent: true);
  //   if (!mounted) return;
  //   setState(() => _messages = [..._messages, msg]);
  //   _scrollToBottomSoon();
  // }
  Future<void> _handleVoice() async {
  final peer = _resolvedPeer;
  if (peer == null) return;
  // placeholder until record fixed
  final msg = await _chatService.sendVoice(peerId: peer.id, durationSeconds: 9, isSent: true);
  if (!mounted) return;
  setState(() => _messages = [..._messages, msg]);
  _scrollToBottomSoon();
}

  Future<void> _handleLocation() async {
    final peer = _resolvedPeer;
    if (peer == null) return;
    final msg = await _chatService.sendLocation(peerId: peer.id, latitude: 22.44, longitude: 88.41, isSent: true);
    if (!mounted) return;
    setState(() => _messages = [..._messages, msg]);
    _scrollToBottomSoon();
  }

  Future<void> _handleFile() async {
    final peer = _resolvedPeer;
    if (peer == null) return;
    final msg = await _chatService.sendFile(peerId: peer.id, filename: 'attachment.bin', isSent: true);
    if (!mounted) return;
    setState(() => _messages = [..._messages, msg]);
    _scrollToBottomSoon();
  }

  // void _handleSOS() {
  //   debugPrint('SOS pressed (chat)');
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('SOS Signal Sent', style: dmMonoStyle.copyWith(fontSize: 12)),
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
    final peer = _resolvedPeer;
    return Scaffold(
      backgroundColor: MeshColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ChatTopBar(peerName: peer?.deviceName ?? 'CHAT'),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: MeshColors.muted, strokeWidth: 2))
                  : peer == null
                      ? const _ChatEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) => MessageBubble(message: _messages[index]),
                        ),
            ),
            _ChatComposer(
              enabled: peer != null,
              controller: _controller,
              focusNode: _focusNode,
              isSending: _isSending,
              onSend: _send,
              onVoice: _handleVoice,
              onLocation: _handleLocation,
              onFile: _handleFile,
              onSOS: _handleSOS,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'SELECT A PEER FROM HOME',
          textAlign: TextAlign.center,
          style: dmMonoStyle.copyWith(color: MeshColors.muted, fontSize: 12, letterSpacing: 0.8, height: 1.4),
        ),
      ),
    );
  }
}

class _ChatTopBar extends StatelessWidget {
  final String peerName;

  const _ChatTopBar({required this.peerName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              peerName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: dmMonoStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  final bool enabled;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final VoidCallback onLocation;
  final VoidCallback onFile;
  final VoidCallback onSOS;

  const _ChatComposer({
    required this.enabled,
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
    required this.onVoice,
    required this.onLocation,
    required this.onFile,
    required this.onSOS,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: MeshColors.inputBorder, width: 1),
                borderRadius: BorderRadius.circular(4),
                color: MeshColors.bubbleSent,
              ),
              child: Row(
                children: [
                  _MonoIconButton(icon: Icons.mic_none, onPressed: enabled ? onVoice : null),
                  _MonoIconButton(icon: Icons.location_pin, onPressed: enabled ? onLocation : null),
                  _MonoIconButton(icon: Icons.attach_file, onPressed: enabled ? onFile : null),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: dmMonoStyle.copyWith(fontSize: 13),
                      cursorColor: MeshColors.textPrimary,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => enabled ? onSend() : null,
                      enabled: enabled,
                      decoration: InputDecoration(
                        hintText: 'message',
                        hintStyle: dmMonoStyle.copyWith(fontSize: 13, color: MeshColors.muted),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedScale(
            duration: const Duration(milliseconds: 140),
            scale: isSending ? 0.96 : 1,
            child: _MonoIconButton(
              icon: Icons.send,
              onPressed: (!enabled || isSending) ? null : onSend,
            ),
          ),
          const SizedBox(width: 6),
          _MonoIconButton(
            icon: Icons.crisis_alert,
            color: MeshColors.sosButton,
            onPressed: onSOS,
          ),
        ],
      ),
    );
  }
}

class _MonoIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback? onPressed;

  const _MonoIconButton({required this.icon, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      icon: Icon(icon, size: 18, color: onPressed == null ? MeshColors.cardBorder : (color ?? MeshColors.muted)),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}

