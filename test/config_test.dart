import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msl_oauth_login/msl_oauth_login.dart';

void main() {
  final key = GlobalKey<NavigatorState>();

  group('Config — Microsoft (tenant)', () {
    late Config config;

    setUp(() {
      config = Config(
        tenant: 'my-tenant',
        clientId: 'my-client',
        redirectUri: 'https://example.com/callback',
        scope: 'openid offline_access',
        navigatorKey: key,
      );
    });

    test('builds authorizationUrl from tenant', () {
      expect(
        config.authorizationUrl,
        'https://login.microsoftonline.com/my-tenant/oauth2/v2.0/authorize',
      );
    });

    test('builds tokenUrl from tenant', () {
      expect(
        config.tokenUrl,
        'https://login.microsoftonline.com/my-tenant/oauth2/v2.0/token',
      );
    });

    test('builds logoutUrl from tenant', () {
      expect(
        config.logoutUrl,
        'https://login.microsoftonline.com/my-tenant/oauth2/v2.0/logout',
      );
    });
  });

  group('Config — custom provider (explicit URLs)', () {
    late Config config;

    setUp(() {
      config = Config(
        clientId: 'google-client',
        redirectUri: 'com.example.app:/oauth2redirect',
        scope: 'openid email profile',
        authorizationUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
        tokenUrl: 'https://oauth2.googleapis.com/token',
        navigatorKey: key,
      );
    });

    test('uses provided authorizationUrl', () {
      expect(config.authorizationUrl,
          'https://accounts.google.com/o/oauth2/v2/auth');
    });

    test('uses provided tokenUrl', () {
      expect(config.tokenUrl, 'https://oauth2.googleapis.com/token');
    });
  });

  group('Config — defaults', () {
    late Config config;

    setUp(() {
      config = Config(
        tenant: 'tenant',
        clientId: 'client',
        redirectUri: 'https://example.com/cb',
        scope: 'openid',
        navigatorKey: key,
      );
    });

    test('responseType defaults to code', () {
      expect(config.responseType, 'code');
    });

    test('contentType defaults to form-urlencoded', () {
      expect(config.contentType, 'application/x-www-form-urlencoded');
    });

    test('forceConsent defaults to true', () {
      expect(config.forceConsent, isTrue);
    });

    test('clientSecret defaults to null', () {
      expect(config.clientSecret, isNull);
    });
  });

  group('Config — optional overrides', () {
    test('accepts explicit logoutUrl', () {
      final config = Config(
        tenant: 'tenant',
        clientId: 'client',
        redirectUri: 'https://example.com/cb',
        scope: 'openid',
        navigatorKey: key,
        logoutUrl: 'https://custom.logout/end',
      );
      expect(config.logoutUrl, 'https://custom.logout/end');
    });

    test('stores clientSecret when provided', () {
      final config = Config(
        tenant: 'tenant',
        clientId: 'client',
        redirectUri: 'https://example.com/cb',
        scope: 'openid',
        navigatorKey: key,
        clientSecret: 'secret123',
      );
      expect(config.clientSecret, 'secret123');
    });
  });
}
