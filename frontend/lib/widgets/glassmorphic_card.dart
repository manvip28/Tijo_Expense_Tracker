import 'package:flutter/material.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final List<Color>? gradientColors;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.padding,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Premium Slate 800 matte finish
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1.0,
        ),
      ),
      child: child,
    );
  }
}
