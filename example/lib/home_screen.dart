import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';

// Shown after a successful login. Demonstrates:
//  - Reading the access token returned by onSuccess
//  - Using AadOAuth directly (programmatic logout / token check)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.token, required this.provider});

  final String token;
  final String provider;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Programmatic usage ───────────────────────────────────────────────────
  //
  // You can also drive the auth flow without any button widget.
  // Create an AadOAuth instance with the same Config you already defined,
  // then call login() / getAccessToken() / logout() directly.
  //
  //   final auth = AadOAuth(myConfig);
  //   await auth.login();                     // opens WebView if needed
  //   final token = await auth.getAccessToken(); // refreshes automatically
  //   final valid = auth.tokenIsValid();      // quick in-memory check
  //   await auth.logout();                    // clears secure storage

  bool _loggingOut = false;

  // We re-create an AadOAuth only for logout in this demo.
  // In a real app you would share the instance (e.g. via a provider/service).
  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      // AadOAuth.logout() clears secure storage; no network call needed.
      // Because we don't hold the original instance here we just pop back
      // to the login screen — in a real app call auth.logout() on your
      // shared AadOAuth instance first.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Show only the first 80 chars of the token so the screen stays readable.
    final preview = widget.token.length > 80
        ? '${widget.token.substring(0, 80)}…'
        : widget.token;

    return Scaffold(
      appBar: AppBar(
        title: Text('Logged in — ${widget.provider}'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Token display ──────────────────────────────────────────────
            Text('Access token', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                preview,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy full token'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.token));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Token copied to clipboard')),
                );
              },
            ),

            const Divider(height: 40),

            // ── Programmatic usage note ────────────────────────────────────
            Text(
              'Programmatic usage (no button)',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'final auth = AadOAuth(config);\n'
                'await auth.login();              // WebView if needed\n'
                'final token = await auth.getAccessToken(); // auto-refresh\n'
                'final valid = auth.tokenIsValid();\n'
                'await auth.logout();             // clears storage',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontFamily: 'monospace'),
              ),
            ),

            const Spacer(),

            // ── Logout ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: _loggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: _loggingOut ? null : _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
