import 'package:flutter_test/flutter_test.dart';
import 'package:msl_oauth_login/msl_oauth_login.dart';

void main() {
  group('Token.fromMap', () {
    test('parses a standard JSON response', () {
      final token = Token.fromMap({
        'access_token': 'abc123',
        'token_type': 'Bearer',
        'expires_in': 3600,
        'refresh_token': 'refresh456',
      });

      expect(token.accessToken, 'abc123');
      expect(token.tokenType, 'Bearer');
      expect(token.refreshToken, 'refresh456');
      expect(token.expiresIn, 3600);
      expect(token.expireTimeStamp, isNotNull);
      expect(token.issueTimeStamp, isNotNull);
    });

    test('parses expires_in when supplied as a string', () {
      final token = Token.fromMap({
        'access_token': 'tok',
        'expires_in': '7200',
      });
      expect(token.expiresIn, 7200);
    });

    test('defaults expires_in to 60 when value cannot be parsed', () {
      final token = Token.fromMap({
        'access_token': 'tok',
        'expires_in': 'bad',
      });
      expect(token.expiresIn, 60);
    });

    test('restores expireTimeStamp from cached expire_timestamp', () {
      final future = DateTime.utc(2099, 1, 1);
      final token = Token.fromMap({
        'access_token': 'tok',
        'expires_in': 3600,
        'expire_timestamp': future.millisecondsSinceEpoch,
      });
      expect(
        token.expireTimeStamp!.millisecondsSinceEpoch,
        future.millisecondsSinceEpoch,
      );
    });

    test('throws when the response contains an error field', () {
      expect(
        () => Token.fromMap({
          'error': 'invalid_grant',
          'error_description': 'Token expired.',
        }),
        throwsException,
      );
    });
  });

  group('Token.toJsonMap', () {
    test('serialises all populated fields', () {
      final token = Token.fromMap({
        'access_token': 'abc',
        'token_type': 'Bearer',
        'refresh_token': 'ref',
        'expires_in': 3600,
      });
      final map = Token.toJsonMap(token);

      expect(map['access_token'], 'abc');
      expect(map['token_type'], 'Bearer');
      expect(map['refresh_token'], 'ref');
      expect(map['expires_in'], 3600);
      expect(map['expire_timestamp'], isA<int>());
    });

    test('round-trips through fromMap without data loss', () {
      final original = Token.fromMap({
        'access_token': 'tok',
        'token_type': 'Bearer',
        'refresh_token': 'ref',
        'expires_in': 3600,
      });
      final restored = Token.fromMap(Token.toJsonMap(original));

      expect(restored.accessToken, original.accessToken);
      expect(restored.tokenType, original.tokenType);
      expect(restored.refreshToken, original.refreshToken);
      expect(
        restored.expireTimeStamp!.millisecondsSinceEpoch,
        original.expireTimeStamp!.millisecondsSinceEpoch,
      );
    });

    test('returns empty map for null token', () {
      expect(Token.toJsonMap(null), isEmpty);
    });
  });

  group('Token.tokenIsValid', () {
    test('returns false for null', () {
      expect(Token.tokenIsValid(null), isFalse);
    });

    test('returns false when accessToken is null', () {
      final token = Token();
      token.expireTimeStamp = DateTime.now().toUtc().add(const Duration(hours: 1));
      expect(Token.tokenIsValid(token), isFalse);
    });

    test('returns false for an expired token', () {
      final token = Token.fromMap({
        'access_token': 'tok',
        'expire_timestamp': DateTime.now()
            .toUtc()
            .subtract(const Duration(seconds: 1))
            .millisecondsSinceEpoch,
        'expires_in': 1,
      });
      expect(Token.tokenIsValid(token), isFalse);
    });

    test('returns true for a valid, unexpired token', () {
      final token = Token.fromMap({
        'access_token': 'tok',
        'expires_in': 3600,
      });
      expect(Token.tokenIsValid(token), isTrue);
    });
  });
}
