import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class AIOrb extends StatelessWidget {
  const AIOrb({
    super.key,
    this.size = 56,
    this.onTap,
    this.pulse = true,
  });

  final double size;
  final VoidCallback? onTap;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    Widget orb = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
    );

    if (pulse) {
      orb = orb
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2.seconds)
          .then()
          .shimmer(duration: 3.seconds, color: Colors.white.withValues(alpha: 0.3));
    }

    return GestureDetector(onTap: onTap, child: orb);
  }
}
