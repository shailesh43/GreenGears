// import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

// class DecryptData {
//   static String? decryptData(String encryptedData) {
//     print("decryptData function called");
//
//     try {
//       const secretKey = "testTestTest@1122"; // Use the same key as in the backend
//
//       // Create key from the secret string
//       final key = encrypt.Key.fromUtf8(secretKey.padRight(32, '\x00').substring(0, 32));
//
//       // Create encrypter with AES algorithm in CBC mode
//       final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
//
//       // Decrypt the data
//       final decrypted = encrypter.decrypt64(encryptedData, iv: encrypt.IV.fromLength(16));
//
//       if (decrypted.isEmpty) {
//         print("Decryption failed: Possible incorrect secret key or corrupted data.");
//         return null;
//       }
//
//       return decrypted;
//     } catch (error) {
//       print("Decryption error: $error"); // Log the specific error
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'package:crypto/crypto.dart';

List<int> evpBytesToKey(
    List<int> password,
    List<int> salt, {
      required int keySize,
      required int ivSize,
    }) {
  final totalSize = keySize + ivSize;
  var derived = <int>[];
  var block = <int>[];

  while (derived.length < totalSize) {
    block = md5
        .convert([...block, ...password, ...salt])
        .bytes;
    derived.addAll(block);
  }

  return derived.sublist(0, totalSize);
}
