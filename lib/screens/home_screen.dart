import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Home Page\n(Coming soon)",
        style: TextStyle(color: Colors.white70, fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }
}