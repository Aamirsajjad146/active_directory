import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'model/config.dart';
import 'model/token.dart';
import 'request/token_refresh_request.dart';
import 'request/token_request.dart';

class RequestToken {
  final Config config;

  RequestToken(this.config);

  Future<Token> requestToken(String code) async {
    final req = TokenRequestDetails(config, code);
    return _sendTokenRequest(req.url!, req.params!, req.headers!);
  }

  Future<Token> requestRefreshToken(String refreshToken) async {
    final req = TokenRefreshRequestDetails(config, refreshToken);
    return _sendTokenRequest(req.url!, req.params!, req.headers!);
  }

  Future<Token> _sendTokenRequest(
    String url,
    Map<String, String> params,
    Map<String, String> headers,
  ) async {
    final response =
        await post(Uri.parse(url), body: params, headers: headers);
    final tokenJson =
        json.decode(response.body) as Map<String, dynamic>;
    return Token.fromJson(tokenJson);
  }
}
