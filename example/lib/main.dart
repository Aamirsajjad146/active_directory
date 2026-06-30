import 'package:flutter/material.dart';

import 'login_screen.dart';

// A single GlobalKey<NavigatorState> shared across the whole app.
// Pass it to BOTH MaterialApp.navigatorKey AND every Config you create.
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'msl_oauth_login example',
      navigatorKey: navigatorKey, // ← same key passed to each Config
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0078D4),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
