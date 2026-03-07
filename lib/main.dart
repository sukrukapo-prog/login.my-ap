import 'package:flutter/material.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/core/audio_service.dart';
import 'package:fitmetrics/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService().init();
  final isLoggedIn = await AuthService.isLoggedIn();
  final String startRoute = isLoggedIn ? AppRoutes.main : AppRoutes.welcome;
  runApp(FitMetricsApp(initialRoute: startRoute));
}

class FitMetricsApp extends StatelessWidget {
  final String? initialRoute;
  const FitMetricsApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMetrics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1624),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withAlpha(20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),
      initialRoute: initialRoute ?? AppRoutes.welcome,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}