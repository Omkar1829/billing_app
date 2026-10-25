import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? tintColor;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 16,
    this.opacity = 0.09,
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.tintColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = border ??
        Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.2,
        );

    final cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: (tintColor ?? const Color(0xFF6366F1)).withValues(alpha: 0.06),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: effectiveBorder,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (tintColor ?? Colors.white).withValues(alpha: opacity + 0.07),
                  (tintColor ?? Colors.white).withValues(alpha: opacity),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
