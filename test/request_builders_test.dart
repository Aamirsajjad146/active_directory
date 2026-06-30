import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msl_oauth_login/msl_oauth_login.dart';

// Internal request-builder classes are not exported from the public barrel, so
// import them directly from their source paths.
import 'package:msl_oauth_login/src/request/authorization_request.dart';
import 'package:msl_oauth_login/src/request/token_request.dart';
import 'package:msl_oauth_login/src/request/token_refresh_request.dart';

Config _makeConfig({
  String tenant = 'my-tenant',
  String clientId = 'my-client',
  String redirectUri = 'https://example.com/cb',
  String scope = 'openid offline_access',
  bool forceConsent = true,
  String? clientSecret,
}) =>
    Config(
      tenant: tenant,
      clientId: clientId,
      redirectUri: redirectUri,
      scope: scope,
      navigatorKey: GlobalKey<NavigatorState>(),
      forceConsent: forceConsent,
      clientSecret: clientSecret,
    );

void main() {
  // ── AuthorizationRequest ───────────────────────────────────────────────────

  group('AuthorizationRequest', () {
    test('sets url to authorizationUrl from config', () {
      final req = AuthorizationRequest(_makeConfig());
      expect(
        req.url,
        'https://login.microsoftonline.com/my-tenant/oauth2/v2.0/authorize',
      );
    });

    test('includes required parameters', () {
      final req = AuthorizationRequest(_makeConfig());
      final p = req.parameters!;

      expect(p['client_id'], 'my-client');
      expect(p['response_type'], 'code');
      expect(p['redirect_uri'], 'https://example.com/cb');
      expect(p['scope'], 'openid offline_access');
    });

    test('adds prompt=consent when forceConsent is true', () {
      final req = AuthorizationRequest(_makeConfig(forceConsent: true));
      expect(req.parameters!['prompt'], 'consent');
    });

    test('omits prompt when forceConsent is false', () {
      final req = AuthorizationRequest(_makeConfig(forceConsent: false));
      expect(req.parameters!.containsKey('prompt'), isFalse);
    });

    test('sets redirectUrl to config.redirectUri', () {
      final req = AuthorizationRequest(_makeConfig());
      expect(req.redirectUrl, 'https://example.com/cb');
    });
  });

  // ── TokenRequestDetails ────────────────────────────────────────────────────

  group('TokenRequestDetails', () {
    test('sets url to tokenUrl from config', () {
      final req = TokenRequestDetails(_makeConfig(), 'auth-code');
      expect(
        req.url,
        'https://login.microsoftonline.com/my-tenant/oauth2/v2.0/token',
      );
    });

    test('includes required parameters', () {
      final req = TokenRequestDetails(_makeConfig(), 'auth-code');
      final p = req.params!;

      expect(p['client_id'], 'my-client');
      expect(p['code'], 'auth-code');
      expect(p['redirect_uri'], 'https://example.com/cb');
      expect(p['grant_type'], 'authorization_code');
    });

    test('includes client_secret when provided', () {
      final req =
          TokenRequestDetails(_makeConfig(clientSecret: 'sec'), 'auth-code');
      expect(req.params!['client_secret'], 'sec');
    });

    test('omits client_secret when not provided', () {
      final req = TokenRequestDetails(_makeConfig(), 'auth-code');
      expect(req.params!.containsKey('client_secret'), isFalse);
    });

    test('sets Accept and Content-Type headers', () {
      final req = TokenRequestDetails(_makeConfig(), 'auth-code');
      expect(req.headers!['Accept'], 'application/json');
      expect(req.headers!['Content-Type'],
          'application/x-www-form-urlencoded');
    });
  });

  // ── TokenRefreshRequestDetails ─────────────────────────────────────────────

  group('TokenRefreshRequestDetails', () {
    test('sets url to tokenUrl from config', () {
      final req = TokenRefreshRequestDetails(_makeConfig(), 'my-refresh');
      expect(
        req.url,
        'https://login.microsoftonline.com/my-tenant/oauth2/v2.0/token',
      );
    });

    test('includes required parameters', () {
      final req = TokenRefreshRequestDetails(_makeConfig(), 'my-refresh');
      final p = req.params!;

      expect(p['client_id'], 'my-client');
      expect(p['scope'], 'openid offline_access');
      expect(p['redirect_uri'], 'https://example.com/cb');
      expect(p['grant_type'], 'refresh_token');
      expect(p['refresh_token'], 'my-refresh');
    });

    test('includes client_secret when provided', () {
      final req = TokenRefreshRequestDetails(
          _makeConfig(clientSecret: 'sec'), 'my-refresh');
      expect(req.params!['client_secret'], 'sec');
    });

    test('omits client_secret when not provided', () {
      final req = TokenRefreshRequestDetails(_makeConfig(), 'my-refresh');
      expect(req.params!.containsKey('client_secret'), isFalse);
    });

    test('sets Accept and Content-Type headers', () {
      final req = TokenRefreshRequestDetails(_makeConfig(), 'my-refresh');
      expect(req.headers!['Accept'], 'application/json');
      expect(req.headers!['Content-Type'],
          'application/x-www-form-urlencoded');
    });
  });
}
