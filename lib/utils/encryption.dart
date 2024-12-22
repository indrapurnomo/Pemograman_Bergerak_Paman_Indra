import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static String encryptPassword(String key, String plainText) {
    final keyBytes = _getKeyBytes(key);
    final encrypter = encrypt.Encrypter(encrypt.AES(
      encrypt.Key(Uint8List.fromList(keyBytes)),
      mode: encrypt.AESMode.cbc,
      padding: 'PKCS7',
    ));
    final iv = encrypt.IV.fromUtf8('1234567890123456'); // IV statis untuk konsistensi
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decryptPassword(String key, String encryptedText) {
    final keyBytes = _getKeyBytes(key);
    final encrypter = encrypt.Encrypter(encrypt.AES(
      encrypt.Key(Uint8List.fromList(keyBytes)),
      mode: encrypt.AESMode.cbc,
      padding: 'PKCS7',
    ));
    final iv = encrypt.IV.fromUtf8('1234567890123456'); // IV harus sama
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

  static List<int> _getKeyBytes(String key) {
    final keyBytes = List<int>.filled(16, 0);
    final keyAsBytes = key.codeUnits;
    for (int i = 0; i < keyAsBytes.length && i < 16; i++) {
      keyBytes[i] = keyAsBytes[i];
    }
    return keyBytes;
  }
}
