import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meshreach/models/chat_message.dart';

class ChatService {
  String _messagesKey(String peerId) => 'chat_messages_$peerId';

  Future<List<ChatMessage>> getMessages(String peerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_messagesKey(peerId));
      if (raw == null) {
        final sample = _sampleMessages(peerId);
        await saveMessages(peerId, sample);
        return sample;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final messages = decoded.map((e) {
        try {
          return ChatMessage.fromJson((e as Map).cast<String, dynamic>());
        } catch (err) {
          debugPrint('Failed to decode message: $err');
          return null;
        }
      }).whereType<ChatMessage>().toList();

      // Sanitize any corrupted entries so future loads don’t fail again.
      await saveMessages(peerId, messages);
      return messages;
    } catch (e) {
      debugPrint('Failed to load messages for $peerId: $e');
      return _sampleMessages(peerId);
    }
  }

  Future<void> saveMessages(String peerId, List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(messages.map((m) => m.toJson()).toList());
      await prefs.setString(_messagesKey(peerId), raw);
    } catch (e) {
      debugPrint('Failed to save messages for $peerId: $e');
    }
  }

  Future<ChatMessage> sendMessage({required String peerId, required String text}) async {
    final now = DateTime.now();
    final message = ChatMessage(
      id: '${now.microsecondsSinceEpoch}',
      peerId: peerId,
      isSent: true,
      type: ChatMessageType.text,
      text: text,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final existing = await getMessages(peerId);
      final updated = [...existing, message];
      await saveMessages(peerId, updated);
    } catch (e) {
      debugPrint('Failed to send message for $peerId: $e');
    }

    return message;
  }

  Future<ChatMessage> sendVoice({required String peerId, required int durationSeconds, bool isSent = true}) async {
    final now = DateTime.now();
    final message = ChatMessage(
      id: '${now.microsecondsSinceEpoch}',
      peerId: peerId,
      isSent: isSent,
      type: ChatMessageType.voice,
      text: '',
      durationSeconds: durationSeconds,
      createdAt: now,
      updatedAt: now,
    );
    await _append(peerId, message);
    return message;
  }

  Future<ChatMessage> sendLocation({required String peerId, required double latitude, required double longitude, bool isSent = true}) async {
    final now = DateTime.now();
    final message = ChatMessage(
      id: '${now.microsecondsSinceEpoch}',
      peerId: peerId,
      isSent: isSent,
      type: ChatMessageType.location,
      text: '',
      latitude: latitude,
      longitude: longitude,
      createdAt: now,
      updatedAt: now,
    );
    await _append(peerId, message);
    return message;
  }

  Future<ChatMessage> sendFile({required String peerId, required String filename, bool isSent = true}) async {
    final now = DateTime.now();
    final message = ChatMessage(
      id: '${now.microsecondsSinceEpoch}',
      peerId: peerId,
      isSent: isSent,
      type: ChatMessageType.file,
      text: '',
      filename: filename,
      createdAt: now,
      updatedAt: now,
    );
    await _append(peerId, message);
    return message;
  }

  Future<void> _append(String peerId, ChatMessage message) async {
    try {
      final existing = await getMessages(peerId);
      await saveMessages(peerId, [...existing, message]);
    } catch (e) {
      debugPrint('Failed to append message for $peerId: $e');
    }
  }

  List<ChatMessage> _sampleMessages(String peerId) {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'seed_1',
        peerId: peerId,
        isSent: false,
        type: ChatMessageType.text,
        text: 'ping',
        createdAt: now.subtract(const Duration(minutes: 8)),
        updatedAt: now.subtract(const Duration(minutes: 8)),
      ),
      ChatMessage(
        id: 'seed_2',
        peerId: peerId,
        isSent: true,
        type: ChatMessageType.text,
        text: 'ack',
        createdAt: now.subtract(const Duration(minutes: 7, seconds: 40)),
        updatedAt: now.subtract(const Duration(minutes: 7, seconds: 40)),
      ),
      ChatMessage(
        id: 'seed_voice',
        peerId: peerId,
        isSent: false,
        type: ChatMessageType.voice,
        text: '',
        durationSeconds: 12,
        createdAt: now.subtract(const Duration(minutes: 5, seconds: 10)),
        updatedAt: now.subtract(const Duration(minutes: 5, seconds: 10)),
      ),
      ChatMessage(
        id: 'seed_loc',
        peerId: peerId,
        isSent: true,
        type: ChatMessageType.location,
        text: '',
        latitude: 22.44,
        longitude: 88.41,
        createdAt: now.subtract(const Duration(minutes: 3, seconds: 20)),
        updatedAt: now.subtract(const Duration(minutes: 3, seconds: 20)),
      ),
      ChatMessage(
        id: 'seed_file',
        peerId: peerId,
        isSent: false,
        type: ChatMessageType.file,
        text: '',
        filename: 'mesh_log.txt',
        createdAt: now.subtract(const Duration(minutes: 2, seconds: 50)),
        updatedAt: now.subtract(const Duration(minutes: 2, seconds: 50)),
      ),
      ChatMessage(
        id: 'seed_3',
        peerId: peerId,
        isSent: false,
        type: ChatMessageType.text,
        text: 'status?',
        createdAt: now.subtract(const Duration(minutes: 2)),
        updatedAt: now.subtract(const Duration(minutes: 2)),
      ),
      ChatMessage(
        id: 'seed_4',
        peerId: peerId,
        isSent: true,
        type: ChatMessageType.text,
        text: 'connected. low power mode.',
        createdAt: now.subtract(const Duration(minutes: 1, seconds: 20)),
        updatedAt: now.subtract(const Duration(minutes: 1, seconds: 20)),
      ),
    ];
  }
}
