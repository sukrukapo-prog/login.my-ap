import 'package:flutter/material.dart';

enum SlideDirection { rightToLeft, leftToRight, bottomToTop }

/// Slide + fade transition — used for most screen pushes
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.rightToLeft,
  }) : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      Offset begin;
      switch (direction) {
        case SlideDirection.rightToLeft:  begin = const Offset(1.0, 0.0);  break;
        case SlideDirection.leftToRight:  begin = const Offset(-1.0, 0.0); break;
        case SlideDirection.bottomToTop:  begin = const Offset(0.0, 1.0);  break;
      }
      final slide = Tween(begin: begin, end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      final fade = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeIn));
      return FadeTransition(
        opacity: animation.drive(fade),
        child: SlideTransition(position: animation.drive(slide), child: child),
      );
    },
  );
}

/// Fade-only transition — used for tab-level screens
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
      child: child,
    ),
  );
}

/// Scale + fade transition — used for detail screens (card → detail expand feel)
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      final scale = Tween<double>(begin: 0.92, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      final fade = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut));
      return FadeTransition(
        opacity: animation.drive(fade),
        child: ScaleTransition(scale: animation.drive(scale), child: child),
      );
    },
  );
}

/// Shared-axis horizontal transition — smooth left-right flow for onboarding steps
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SharedAxisPageRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      // Entering: slides in from right + fades in
      final enterSlide = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      // Exiting: slides out to left + fades out
      final exitSlide = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.08, 0),
      ).chain(CurveTween(curve: Curves.easeInCubic));

      final enterFade = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut));
      final exitFade = Tween<double>(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeIn));

      return Stack(
        children: [
          SlideTransition(
            position: secondaryAnimation.drive(exitSlide),
            child: FadeTransition(
              opacity: secondaryAnimation.drive(exitFade),
              child: child,
            ),
          ),
          SlideTransition(
            position: animation.drive(enterSlide),
            child: FadeTransition(
              opacity: animation.drive(enterFade),
              child: child,
            ),
          ),
        ],
      );
    },
  );
}