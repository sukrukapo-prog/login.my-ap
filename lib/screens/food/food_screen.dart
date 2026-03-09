import 'package:flutter/material.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Food Page\n(Coming soon)",
        style: TextStyle(color: Colors.white70, fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }
}