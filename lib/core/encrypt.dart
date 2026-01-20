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
