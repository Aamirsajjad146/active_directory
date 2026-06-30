import 'dart:convert' as convert;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/token.dart';

class AuthStorage {
  static const _key = 'ad_token';
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokenToCache(Token token) async {
    final json = convert.jsonEncode(Token.toJsonMap(token));
    await _storage.write(key: _key, value: json);
  }

  Future<Token?> loadTokenFromCache() async {
    final json = await _storage.read(key: _key);
    if (json == null) return null;
    try {
      final data = convert.jsonDecode(json) as Map<String, dynamic>;
      return Token.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
