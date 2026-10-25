import 'package:flutter/material.dart';

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothPageRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(curved);

            final scaleAnimation = Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(curved);

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curved);

            return SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                ),
              ),
            );
          },
        );
}
