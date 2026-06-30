import 'package:flutter/material.dart';

/// OAuth2 configuration for any provider.
///
/// **Microsoft (Azure AD)** — supply [tenant]; authorization/token URLs are
/// built automatically:
/// ```dart
/// Config(
///   tenant: 'YOUR_TENANT_ID',
///   clientId: 'YOUR_CLIENT_ID',
///   redirectUri: 'YOUR_REDIRECT_URI',
///   scope: 'YOUR_SCOPE',
///   navigatorKey: myNavigatorKey,
///   loader: const CircularProgressIndicator(),
/// )
/// ```
///
/// **Google / other providers** — omit [tenant] and supply [authorizationUrl]
/// and [tokenUrl] directly:
/// ```dart
/// Config(
///   clientId: 'your-google-client-id',
///   redirectUri: 'com.example.app:/oauth2redirect',
///   scope: 'openid email profile',
///   authorizationUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
///   tokenUrl: 'https://oauth2.googleapis.com/token',
///   navigatorKey: myNavigatorKey,
///   loader: const CircularProgressIndicator(),
/// )
/// ```
class Config {
  /// Azure AD tenant ID. Required for Microsoft; omit for other providers.
  final String? tenant;

  final String clientId;
  final String redirectUri;
  final String scope;
  final String? clientSecret;
  final String responseType;
  final String contentType;
  final bool forceConsent;

  /// The same [GlobalKey<NavigatorState>] you pass to [MaterialApp.navigatorKey].
  final GlobalKey<NavigatorState> navigatorKey;

  /// Widget shown as an overlay while the WebView page is loading.
  /// Use [SizedBox.shrink()] to show nothing.
  final Widget loader;

  Rect? screenSize;
  String? userAgent;

  final String? _authorizationUrl;
  final String? _tokenUrl;
  final String? _logoutUrl;

  /// Authorization endpoint. Auto-built from [tenant] for Microsoft.
  String get authorizationUrl =>
      _authorizationUrl ??
      'https://login.microsoftonline.com/$tenant/oauth2/v2.0/authorize';

  /// Token endpoint. Auto-built from [tenant] for Microsoft.
  String get tokenUrl =>
      _tokenUrl ??
      'https://login.microsoftonline.com/$tenant/oauth2/v2.0/token';

  /// Logout endpoint. Auto-built from [tenant] for Microsoft.
  String get logoutUrl =>
      _logoutUrl ??
      'https://login.microsoftonline.com/$tenant/oauth2/v2.0/logout';

  Config({
    this.tenant,
    required this.clientId,
    required this.redirectUri,
    required this.scope,
    required this.navigatorKey,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.clientSecret,
    this.responseType = 'code',
    this.contentType = 'application/x-www-form-urlencoded',
    this.forceConsent = true,
    this.screenSize,
    this.userAgent,
    String? authorizationUrl,
    String? tokenUrl,
    String? logoutUrl,
  })  : _authorizationUrl = authorizationUrl,
        _tokenUrl = tokenUrl,
        _logoutUrl = logoutUrl {
    assert(
      tenant != null || (authorizationUrl != null && tokenUrl != null),
      'Provide either tenant (Microsoft) or both authorizationUrl and tokenUrl.',
    );
  }
}
