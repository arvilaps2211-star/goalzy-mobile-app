import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/module_theme.dart';
import '../../../core/theme/module_theme_registry.dart';
import '../../../core/theme/module_theme_scope.dart';

/// Extremely subtle, module-tinted decorative backdrop.
///
/// Meant to sit behind a screen's scrollable content — typically as the
/// first child of a [Stack], with the real content in a `Positioned.fill`
/// or plain child on top. Never bold enough to compete with content; every
/// painter below stays in roughly the 0.04–0.18 alpha range.
///
/// Reads its [ModuleDecorationStyle] and colors from the ambient
/// [ModuleScope] unless [module] is explicitly provided.
class ModuleBackground extends StatelessWidget {
  const ModuleBackground({super.key, this.module});

  /// Overrides the ambient module. Normally left null so it inherits from
  /// the nearest [ModuleScope] via `context.moduleTheme`.
  final GoalzyModule? module;

  @override
  Widget build(BuildContext context) {
    final theme = module != null
        ? GoalzyModuleTheme.resolve(module!, Theme.of(context).brightness)
        : context.moduleTheme;

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _painterFor(theme),
          size: Size.infinite,
        ),
      ),
    );
  }

  _ModuleBackgroundPainter _painterFor(ModuleThemeData theme) {
    switch (theme.decoration) {
      case ModuleDecorationStyle.blurredCircles:
        return _BlurredCirclesPainter(theme.primary, theme.accent);
      case ModuleDecorationStyle.abstractWaves:
        return _AbstractWavesPainter(theme.primary, theme.accent);
      case ModuleDecorationStyle.dottedGrid:
        return _DottedGridPainter(theme.primary);
      case ModuleDecorationStyle.organicBlobs:
        return _OrganicBlobsPainter(theme.primary, theme.accent);
      case ModuleDecorationStyle.timelineAccents:
        return _TimelineAccentsPainter(theme.primary, theme.accent);
      case ModuleDecorationStyle.graphLines:
        return _GraphLinesPainter(theme.primary, theme.accent);
      case ModuleDecorationStyle.neuralParticles:
        return _NeuralParticlesPainter(theme.primary, theme.accent);
      case ModuleDecorationStyle.radialGlow:
        return _RadialGlowPainter(theme.primary);
      case ModuleDecorationStyle.texturedWhite:
        return _TexturedWhitePainter(theme.accent);
      case ModuleDecorationStyle.cleanGray:
        return _CleanGrayPainter(theme.primary);
    }
  }
}

/// Base class for all module background painters. Every pattern here is
/// static (derived only from the theme colors, no external state), so the
/// default is to never repaint once laid out.
abstract class _ModuleBackgroundPainter extends CustomPainter {
  @override
  bool shouldRepaint(covariant _ModuleBackgroundPainter oldDelegate) => false;
}

/// Dashboard — soft blurred lavender circles floating near the edges.
class _BlurredCirclesPainter extends _ModuleBackgroundPainter {
  _BlurredCirclesPainter(this.primary, this.accent);
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    void blob(Offset center, double radius, Color color) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    blob(Offset(size.width * 0.15, size.height * 0.08), size.width * 0.55, primary);
    blob(Offset(size.width * 0.95, size.height * 0.28), size.width * 0.45, accent);
    blob(Offset(size.width * 0.2, size.height * 0.85), size.width * 0.5, accent);
  }
}

/// Goals — soft indigo abstract wave washed across the top of the screen.
class _AbstractWavesPainter extends _ModuleBackgroundPainter {
  _AbstractWavesPainter(this.primary, this.accent);
  final Color primary;
  final Color accent;

  Path _wave(Size size, double baseY, double amplitude) {
    final path = Path()..moveTo(0, baseY);
    path.cubicTo(
      size.width * 0.3,
      baseY - amplitude,
      size.width * 0.7,
      baseY + amplitude,
      size.width,
      baseY,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_wave(size, size.height * 0.18, 24), Paint()..color = primary.withValues(alpha: 0.06));
    canvas.drawPath(_wave(size, size.height * 0.3, 18), Paint()..color = accent.withValues(alpha: 0.05));
  }
}

/// Tasks — very light, evenly spaced dot grid.
class _DottedGridPainter extends _ModuleBackgroundPainter {
  _DottedGridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.10);
    const spacing = 28.0;
    const dotRadius = 1.4;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }
}

/// Habits — organic, leaf-inspired blobs near the top corners.
class _OrganicBlobsPainter extends _ModuleBackgroundPainter {
  _OrganicBlobsPainter(this.primary, this.accent);
  final Color primary;
  final Color accent;

  Path _blob(Offset center, double r) {
    final path = Path();
    const points = 10;
    for (var i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * math.pi;
      final wobble = r * (0.85 + 0.15 * math.sin(angle * 3));
      final point = Offset(center.dx + wobble * math.cos(angle), center.dy + wobble * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _blob(Offset(size.width * 0.12, size.height * 0.1), size.width * 0.32),
      Paint()..color = primary.withValues(alpha: 0.08),
    );
    canvas.drawPath(
      _blob(Offset(size.width * 0.9, size.height * 0.35), size.width * 0.26),
      Paint()..color = accent.withValues(alpha: 0.07),
    );
  }
}

/// Calendar — faint dashed timeline with a few event dots down the left.
class _TimelineAccentsPainter extends _ModuleBackgroundPainter {
  _TimelineAccentsPainter(this.primary, this.accent);
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = primary.withValues(alpha: 0.10)
      ..strokeWidth = 2;
    const dashHeight = 6.0;
    const gap = 6.0;
    final x = size.width * 0.08;
    double y = size.height * 0.06;
    while (y < size.height * 0.5) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashHeight), linePaint);
      y += dashHeight + gap;
    }

    final dotPaint = Paint()..color = accent.withValues(alpha: 0.14);
    for (final t in [0.08, 0.2, 0.34, 0.46]) {
      canvas.drawCircle(Offset(x, size.height * t), 3.2, dotPaint);
    }
  }
}

/// Analytics — faint trend lines, like graphs drawn in the background.
class _GraphLinesPainter extends _ModuleBackgroundPainter {
  _GraphLinesPainter(this.primary, this.accent);
  final Color primary;
  final Color accent;

  Path _trend(Size size, double baseY, double amplitude, double frequency) {
    final path = Path();
    for (double x = 0; x <= size.width; x += 4) {
      final y = baseY + amplitude * math.sin((x / size.width) * frequency * math.pi);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _trend(size, size.height * 0.14, 14, 2.2),
      Paint()
        ..color = primary.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawPath(
      _trend(size, size.height * 0.22, 10, 3.1),
      Paint()
        ..color = accent.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }
}

/// AI Assistant — faint neural-net style dots and connecting lines.
class _NeuralParticlesPainter extends _ModuleBackgroundPainter {
  _NeuralParticlesPainter(this.primary, this.accent);
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    // Fixed seed so the layout is stable across rebuilds instead of
    // jittering every time the widget repaints.
    final random = math.Random(7);
    final points = List.generate(
      14,
      (_) => Offset(random.nextDouble() * size.width, random.nextDouble() * size.height * 0.4),
    );

    final linePaint = Paint()
      ..color = primary.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        if ((points[i] - points[j]).distance < size.width * 0.16) {
          canvas.drawLine(points[i], points[j], linePaint);
        }
      }
    }

    final dotPaint = Paint()..color = accent.withValues(alpha: 0.18);
    for (final p in points) {
      canvas.drawCircle(p, 2, dotPaint);
    }
  }
}

/// Focus Mode — single soft centered radial glow.
class _RadialGlowPainter extends _ModuleBackgroundPainter {
  _RadialGlowPainter(this.primary);
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.32);
    final radius = size.width * 0.8;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [primary.withValues(alpha: 0.18), primary.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }
}

/// Profile — minimal, textured white: a whisper-soft glow from the top.
class _TexturedWhitePainter extends _ModuleBackgroundPainter {
  _TexturedWhitePainter(this.accent);
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, 0);
    final radius = size.width * 0.9;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: 0.10), accent.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }
}

/// Settings — clean gray wash, barely-there gradient at the top.
class _CleanGrayPainter extends _ModuleBackgroundPainter {
  _CleanGrayPainter(this.primary);
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.3);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [primary.withValues(alpha: 0.04), primary.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
