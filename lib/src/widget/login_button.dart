import 'package:flutter/material.dart';

import '../aad_oauth.dart';
import '../model/config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Generic OAuth login button
// ─────────────────────────────────────────────────────────────────────────────

/// A fully generic OAuth2 login button.
///
/// Pass a [Config] (built on the calling screen) and a [child] widget for
/// the button's visible content. Works with Microsoft, Google, or any other
/// provider configured in [Config].
///
/// ```dart
/// OAuthLoginButton(
///   config: Config(
///     tenant: 'your-tenant-id',
///     clientId: 'your-client-id',
///     redirectUri: 'YOUR_REDIRECT_URI',
///     scope: 'openid offline_access',
///     navigatorKey: myNavigatorKey,
///     loader: const CircularProgressIndicator(),
///   ),
///   onSuccess: (token) => print(token),
///   onError:   (e)     => print(e),
///   child: const Text('Sign in'),
/// )
/// ```
class OAuthLoginButton extends StatefulWidget {
  const OAuthLoginButton({
    super.key,
    required this.config,
    required this.onSuccess,
    required this.child,
    this.onError,
    this.style,
    this.width = double.infinity,
    this.height = 48.0,
    this.loadingWidget,
  });

  final Config config;

  /// Called with the access token on successful login.
  final void Function(String accessToken) onSuccess;

  /// Called when the auth flow throws. Silently ignored if null.
  final void Function(Object error)? onError;

  /// Full custom content of the button (icon + label, image, etc.).
  final Widget child;

  /// [ButtonStyle] forwarded to [ElevatedButton].
  final ButtonStyle? style;

  final double width;
  final double height;

  /// Widget shown inside the button while the auth flow is in progress.
  /// Defaults to a small [CircularProgressIndicator].
  final Widget? loadingWidget;

  @override
  State<OAuthLoginButton> createState() => _OAuthLoginButtonState();
}

class _OAuthLoginButtonState extends State<OAuthLoginButton> {
  bool _loading = false;
  late final AadOAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = AadOAuth(widget.config);
  }

  Future<void> _handlePress() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _auth.login();
      final token = await _auth.getAccessToken();
      if (token != null) widget.onSuccess(token);
    } catch (e) {
      widget.onError?.call(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        onPressed: _loading ? null : _handlePress,
        style: widget.style,
        child: _loading
            ? widget.loadingWidget ??
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
            : widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Microsoft convenience button
// ─────────────────────────────────────────────────────────────────────────────

/// Pre-styled "Sign in with Microsoft" button.
///
/// Accepts a [Config] built on the calling screen — just set [Config.tenant]
/// (or supply Microsoft URLs directly) and pass the same [navigatorKey] that
/// you give to [MaterialApp].
///
/// ```dart
/// MicrosoftLoginButton(
///   config: _config,
///   onSuccess: (token) => _onLogin(token),
///   onError:   (e)     => _showError(e),
/// )
/// ```
class MicrosoftLoginButton extends StatelessWidget {
  const MicrosoftLoginButton({
    super.key,
    required this.config,
    required this.onSuccess,
    this.onError,
    this.text = 'Sign in with Microsoft',
    this.backgroundColor = const Color(0xFF0078D4),
    this.textColor = Colors.white,
    this.borderRadius = 4.0,
    this.width = double.infinity,
    this.height = 48.0,
    this.textStyle,
    this.logo,
  });

  final Config config;
  final void Function(String accessToken) onSuccess;
  final void Function(Object error)? onError;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double width;
  final double height;
  final TextStyle? textStyle;

  /// Override the default Microsoft logo with any widget (e.g. an [Image]).
  final Widget? logo;

  @override
  Widget build(BuildContext context) {
    return OAuthLoginButton(
      config: config,
      onSuccess: onSuccess,
      onError: onError,
      width: width,
      height: height,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logo ?? const _MicrosoftLogo(),
          const SizedBox(width: 12),
          Text(
            text,
            style: textStyle ??
                TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google convenience button
// ─────────────────────────────────────────────────────────────────────────────

/// Pre-styled "Sign in with Google" button.
///
/// You must supply a [Config] with [Config.authorizationUrl] and
/// [Config.tokenUrl] pointing to Google's OAuth2 endpoints, since Google
/// does not use Azure AD tenant URLs.
///
/// ```dart
/// GoogleLoginButton(
///   config: Config(
///     clientId: 'your-google-client-id',
///     redirectUri: 'com.example.app:/oauth2redirect',
///     scope: 'openid email profile',
///     authorizationUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
///     tokenUrl: 'https://oauth2.googleapis.com/token',
///     navigatorKey: myNavigatorKey,
///   ),
///   onSuccess: (token) => _onLogin(token),
/// )
/// ```
class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({
    super.key,
    required this.config,
    required this.onSuccess,
    this.onError,
    this.text = 'Sign in with Google',
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF3C4043),
    this.borderRadius = 4.0,
    this.width = double.infinity,
    this.height = 48.0,
    this.textStyle,
    this.logo,
  });

  final Config config;
  final void Function(String accessToken) onSuccess;
  final void Function(Object error)? onError;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double width;
  final double height;
  final TextStyle? textStyle;
  final Widget? logo;

  @override
  Widget build(BuildContext context) {
    return OAuthLoginButton(
      config: config,
      onSuccess: onSuccess,
      onError: onError,
      width: width,
      height: height,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 1,
      ),
      loadingWidget: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logo ?? const _GoogleLogo(),
          const SizedBox(width: 12),
          Text(
            text,
            style: textStyle ??
                TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo painters
// ─────────────────────────────────────────────────────────────────────────────

class _MicrosoftLogo extends StatelessWidget {
  const _MicrosoftLogo();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(20, 20), painter: _MicrosoftLogoPainter());
}

class _MicrosoftLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final half = size.width / 2;
    final gap = size.width * 0.05;
    final sq = half - gap;

    final rects = [
      Rect.fromLTWH(0, 0, sq, sq),
      Rect.fromLTWH(half, 0, sq, sq),
      Rect.fromLTWH(0, half, sq, sq),
      Rect.fromLTWH(half, half, sq, sq),
    ];
    final colors = [
      const Color(0xFFF25022),
      const Color(0xFF7FBA00),
      const Color(0xFF00A4EF),
      const Color(0xFFFFB900),
    ];
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(rects[i], Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(20, 20), painter: _GoogleLogoPainter());
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Outer circle segments (simplified coloured arcs)
    final colors = [
      const Color(0xFF4285F4), // blue  — top right
      const Color(0xFF34A853), // green — bottom right
      const Color(0xFFFBBC05), // yellow — bottom left
      const Color(0xFFEA4335), // red   — top left
    ];
    const sweeps = [1.6, 1.6, 1.6, 1.6]; // ~90° each in radians
    final starts = [-0.4, 1.2, 2.8, 4.4];

    for (var i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72),
        starts[i],
        sweeps[i],
        false,
        paint,
      );
    }

    // White inner circle to fake the "G" cutout
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.5,
      Paint()..color = Colors.white,
    );

    // Blue right-arm of the "G"
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - size.height * 0.1, r * 0.85, size.height * 0.2),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
