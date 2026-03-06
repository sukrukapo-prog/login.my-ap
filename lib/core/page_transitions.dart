import 'package:flutter/material.dart';

enum SlideDirection { rightToLeft, leftToRight, bottomToTop }

/// Slide + fade transition
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.rightToLeft,
  }) : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (_, animation, __, child) {
      Offset begin;
      switch (direction) {
        case SlideDirection.rightToLeft:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.leftToRight:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.bottomToTop:
          begin = const Offset(0.0, 1.0);
          break;
      }
      final slide = Tween(begin: begin, end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      final fade = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeIn));
      return FadeTransition(
        opacity: animation.drive(fade),
        child: SlideTransition(
          position: animation.drive(slide),
          child: child,
        ),
      );
    },
  );
}

/// Fade-only transition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
      child: child,
    ),
  );
}