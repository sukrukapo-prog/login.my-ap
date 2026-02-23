import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const FitMetricsApp());
}

class FitMetricsApp extends StatelessWidget {
  const FitMetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMetrics',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const WelcomeScreen(),
    );
  }
}