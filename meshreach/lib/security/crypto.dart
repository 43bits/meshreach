import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;

class MeshCrypto {
  static const _passphrase = 'meshreach_gdg_2026'; // replace with key exchange later

  static enc.Key get _key =>
      enc.Key.fromUtf8(_passphrase.padRight(32).substring(0, 32));

  static Map<String, String> encrypt(String plaintext) {
    final iv = enc.IV.fromSecureRandom(12);
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return {'data': encrypted.base64, 'iv': iv.base64};
  }

  static String decrypt(String data, String ivBase64) {
    final iv = enc.IV.fromBase64(ivBase64);
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.gcm));
    return encrypter.decrypt64(data, iv: iv);
  }
}