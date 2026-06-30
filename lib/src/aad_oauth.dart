import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'helper/auth_storage.dart';
import 'model/config.dart';
import 'model/token.dart';
import 'request_code.dart';
import 'request_token.dart';

class AadOAuth {
  final Config _config;
  final AuthStorage _authStorage;
  late final RequestCode _requestCode;
  late final RequestToken _requestToken;
  Token? _token;

  AadOAuth(Config config)
      : _config = config,
        _authStorage = AuthStorage() {
    _requestCode = RequestCode(config);
    _requestToken = RequestToken(config);
  }

  /// Logs the user in. Shows the WebView consent screen when no valid token
  /// is cached.
  Future<void> login() async {
    await _clearTokenOnFreshInstall();
    if (!Token.tokenIsValid(_token)) await _performAuthorization();
  }

  /// Returns a valid access token, refreshing or re-authenticating as needed.
  Future<String?> getAccessToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();
    return _token?.accessToken;
  }

  bool tokenIsValid() => Token.tokenIsValid(_token);

  Future<void> logout() async {
    await _authStorage.clear();
    _token = null;
  }

  // ── private ────────────────────────────────────────────────────────────────

  Future<void> _performAuthorization() async {
    _token = await _authStorage.loadTokenFromCache();

    if (_token != null) {
      try {
        await _refreshToken();
      } catch (_) {
        await _fullAuthFlow();
      }
    } else {
      await _fullAuthFlow();
    }

    await _authStorage.saveTokenToCache(_token!);
  }

  Future<void> _fullAuthFlow() async {
    final code = await _requestCode.requestCode();
    if (code == null) throw Exception('Authorization code not received.');
    _token = await _requestToken.requestToken(code);
  }

  Future<void> _refreshToken() async {
    if (_token?.refreshToken == null) throw Exception('No refresh token.');
    _token = await _requestToken.requestRefreshToken(_token!.refreshToken!);
  }

  Future<void> _clearTokenOnFreshInstall() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'ad_fresh_install';
    if (!prefs.containsKey(key)) {
      await _authStorage.clear();
      await prefs.setBool(key, false);
    }
  }
}
