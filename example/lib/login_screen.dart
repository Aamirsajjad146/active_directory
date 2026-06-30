import 'package:flutter/material.dart';
import 'package:msl_oauth_login/msl_oauth_login.dart';

import 'main.dart' show navigatorKey;
import 'home_screen.dart';

// ---------------------------------------------------------------------------
// Replace these placeholder values with your real credentials before running.
// ---------------------------------------------------------------------------
const _msClientId = 'YOUR_AZURE_CLIENT_ID';
const _msTenant = 'YOUR_AZURE_TENANT_ID';
const _msRedirectUri = 'YOUR_REDIRECT_URI'; // e.g. msauth.com.example.app://auth

const _googleClientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
const _googleRedirectUri = 'com.example.app:/oauth2redirect';

const _customClientId = 'YOUR_OKTA_CLIENT_ID';
const _customRedirectUri = 'com.example.app:/callback';
const _customAuthUrl = 'https://your-org.okta.com/oauth2/v1/authorize';
const _customTokenUrl = 'https://your-org.okta.com/oauth2/v1/token';
// ---------------------------------------------------------------------------

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // ── Microsoft (Azure AD) config ──────────────────────────────────────────
  //
  // Supply tenant — authorizationUrl and tokenUrl are built automatically:
  //   https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize
  //   https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token
  static final _microsoftConfig = Config(
    tenant: _msTenant,
    clientId: _msClientId,
    redirectUri: _msRedirectUri,
    scope: 'openid offline_access User.Read',
    navigatorKey: navigatorKey,
    loader: const Center(child: CircularProgressIndicator()),
  );

  // ── Google config ────────────────────────────────────────────────────────
  //
  // Google has no tenant, so supply the endpoint URLs directly.
  static final _googleConfig = Config(
    clientId: _googleClientId,
    redirectUri: _googleRedirectUri,
    scope: 'openid email profile',
    authorizationUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenUrl: 'https://oauth2.googleapis.com/token',
    navigatorKey: navigatorKey,
    loader: const Center(child: CircularProgressIndicator()),
  );

  // ── Custom provider (Okta) config ────────────────────────────────────────
  //
  // OAuthLoginButton accepts any provider — just supply the right URLs and
  // a child widget for the button appearance.
  static final _customConfig = Config(
    clientId: _customClientId,
    redirectUri: _customRedirectUri,
    scope: 'openid offline_access',
    authorizationUrl: _customAuthUrl,
    tokenUrl: _customTokenUrl,
    navigatorKey: navigatorKey,
    loader: const SizedBox.shrink(),
  );

  void _onSuccess(BuildContext context, String token, String provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeScreen(token: token, provider: provider),
      ),
    );
  }

  void _onError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login failed: $error'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('msl_oauth_login'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Microsoft'),
              Tab(text: 'Google'),
              Tab(text: 'Custom'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ProviderTab(
              description:
                  'Azure AD login using tenant + client ID.\n'
                  'Auth URLs are built automatically from the tenant.',
              button: MicrosoftLoginButton(
                config: _microsoftConfig,
                onSuccess: (t) => _onSuccess(context, t, 'Microsoft'),
                onError: (e) => _onError(context, e),
              ),
            ),
            _ProviderTab(
              description:
                  'Google login using explicit authorization\n'
                  'and token endpoint URLs.',
              button: GoogleLoginButton(
                config: _googleConfig,
                onSuccess: (t) => _onSuccess(context, t, 'Google'),
                onError: (e) => _onError(context, e),
              ),
            ),
            _ProviderTab(
              description:
                  'Any provider via OAuthLoginButton.\n'
                  'Supply your own child widget for full control.',
              button: OAuthLoginButton(
                config: _customConfig,
                onSuccess: (t) => _onSuccess(context, t, 'Okta'),
                onError: (e) => _onError(context, e),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007DC1),
                  shape: const StadiumBorder(),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Sign in with Okta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared tab layout ────────────────────────────────────────────────────────

class _ProviderTab extends StatelessWidget {
  const _ProviderTab({required this.description, required this.button});

  final String description;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          button,
        ],
      ),
    );
  }
}
