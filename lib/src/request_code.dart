import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'model/config.dart';
import 'request/authorization_request.dart';

class RequestCode {
  final Config _config;
  final AuthorizationRequest _authorizationRequest;
  final String _redirectUriHost;
  String? _code;

  RequestCode(Config config)
      : _config = config,
        _authorizationRequest = AuthorizationRequest(config),
        _redirectUriHost = Uri.parse(config.redirectUri).host;

  Future<String?> requestCode() async {
    _code = null;

    final uri = Uri.parse(
        '${_authorizationRequest.url}?${_buildQueryString(_authorizationRequest.parameters!)}');

    final navigatorState = _config.navigatorKey.currentState;
    if (navigatorState == null) {
      throw StateError(
        'navigatorKey.currentState is null. '
        'Pass the same GlobalKey<NavigatorState> to Config and MaterialApp.navigatorKey.',
      );
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setUserAgent(_config.userAgent);

    await navigatorState.push(
      MaterialPageRoute<void>(
        builder: (_) => _WebViewPage(
          controller: controller,
          loader: _config.loader,
          onNavigationRequest: _onNavigationRequest,
          initialUri: uri,
        ),
      ),
    );

    return _code;
  }

  Future<NavigationDecision> _onNavigationRequest(
      NavigationRequest request) async {
    try {
      final uri = Uri.parse(request.url);

      if (uri.queryParameters['error'] != null) {
        _config.navigatorKey.currentState?.pop();
        return NavigationDecision.prevent;
      }

      if (uri.host == _redirectUriHost &&
          uri.queryParameters['code'] != null) {
        _code = uri.queryParameters['code'];
        _config.navigatorKey.currentState?.pop();
        return NavigationDecision.prevent;
      }
    } catch (_) {}
    return NavigationDecision.navigate;
  }

  Future<void> clearCookies() async {
    await WebViewCookieManager().clearCookies();
  }

  String _buildQueryString(Map<String, String> params) =>
      params.entries.map((e) => '${e.key}=${e.value}').join('&');
}

// ── WebView page with loader overlay ─────────────────────────────────────────

class _WebViewPage extends StatefulWidget {
  const _WebViewPage({
    required this.controller,
    required this.loader,
    required this.onNavigationRequest,
    required this.initialUri,
  });

  final WebViewController controller;
  final Widget loader;
  final NavigationRequestCallback onNavigationRequest;
  final Uri initialUri;

  @override
  State<_WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<_WebViewPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.controller
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: widget.onNavigationRequest,
      ))
      ..loadRequest(widget.initialUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) return;
          if (await widget.controller.canGoBack()) {
            widget.controller.goBack();
            return;
          }
          if (context.mounted) Navigator.of(context).pop();
        },
        child: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: widget.controller),
              if (_isLoading) widget.loader,
            ],
          ),
        ),
      ),
    );
  }
}
