import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopWidgetDateSurface extends StatefulWidget {
  const DesktopWidgetDateSurface({
    required this.child,
    required this.accentColor,
    super.key,
    this.surfaceKey,
    this.isToday = false,
    this.isMuted = false,
    this.size = 28,
    this.shape = BoxShape.circle,
    this.todayHighlightStyle = DesktopWidgetTodayHighlightStyle.glowOutline,
  });

  final Widget child;
  final Color accentColor;
  final Key? surfaceKey;
  final bool isToday;
  final bool isMuted;
  final double size;
  final BoxShape shape;
  final DesktopWidgetTodayHighlightStyle todayHighlightStyle;

  @override
  State<DesktopWidgetDateSurface> createState() =>
      _DesktopWidgetDateSurfaceState();
}

class _DesktopWidgetDateSurfaceState extends State<DesktopWidgetDateSurface>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  bool get _usesGlowOutline =>
      widget.isToday &&
      widget.todayHighlightStyle ==
          DesktopWidgetTodayHighlightStyle.glowOutline;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _glowController.duration = context.tokens.motion.ambient;
    _syncGlowAnimation();
  }

  @override
  void didUpdateWidget(covariant DesktopWidgetDateSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isToday != widget.isToday ||
        oldWidget.todayHighlightStyle != widget.todayHighlightStyle) {
      _syncGlowAnimation();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;
    final style = tokens.visualStyle;
    final scale = _pressed
        ? 0.96
        : _hovered
        ? 1.04
        : 1.0;
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final decoration = _decoration(
          tokens,
          brightness,
          style,
          _glowAnimation.value,
        );
        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() {
            _hovered = false;
            _pressed = false;
          }),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: scale,
              duration: tokens.motion.fast,
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                key: widget.surfaceKey,
                width: widget.size,
                height: widget.size,
                alignment: Alignment.center,
                duration: _usesGlowOutline ? Duration.zero : tokens.motion.fast,
                curve: Curves.easeOutCubic,
                decoration: decoration,
                child: Opacity(
                  opacity: widget.isMuted ? 0.46 : 1,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _decoration(
    AppTokens tokens,
    Brightness brightness,
    AppVisualStyle style,
    double glowProgress,
  ) {
    final isDark = brightness == Brightness.dark;
    final usesFilledHighlight =
        widget.isToday &&
        widget.todayHighlightStyle == DesktopWidgetTodayHighlightStyle.filled;
    final accentTint = widget.accentColor.withValues(
      alpha: usesFilledHighlight
          ? 1
          : style == AppVisualStyle.flat
          ? 0.16
          : 0.12,
    );
    final surfaceColor = switch (style) {
      AppVisualStyle.classic =>
        usesFilledHighlight
            ? widget.accentColor
            : Color.alphaBlend(accentTint, tokens.colors.surface),
      AppVisualStyle.flat =>
        usesFilledHighlight
            ? widget.accentColor
            : Color.alphaBlend(accentTint, tokens.colors.surface),
      AppVisualStyle.neumorphic =>
        usesFilledHighlight ? widget.accentColor : tokens.colors.surface,
      AppVisualStyle.glass =>
        usesFilledHighlight
            ? widget.accentColor.withValues(alpha: 0.88)
            : tokens.colors.surfaceElevated.withValues(
                alpha: isDark ? 0.68 : 0.58,
              ),
      AppVisualStyle.paper =>
        usesFilledHighlight
            ? widget.accentColor
            : Color.alphaBlend(
                widget.accentColor.withValues(alpha: 0.07),
                tokens.colors.surfaceElevated,
              ),
    };
    final neumorphicTodayGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(
          widget.accentColor,
          isDark ? Colors.black : Colors.white,
          0.18,
        )!,
        widget.accentColor,
        Color.lerp(widget.accentColor, Colors.black, isDark ? 0.22 : 0.14)!,
      ],
      stops: const [0, 0.42, 1],
    );
    final glassGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [tokens.surfaceHighlight, surfaceColor],
    );

    return BoxDecoration(
      color:
          style == AppVisualStyle.glass ||
              (style == AppVisualStyle.neumorphic && usesFilledHighlight)
          ? null
          : surfaceColor,
      gradient: switch (style) {
        AppVisualStyle.neumorphic when usesFilledHighlight =>
          neumorphicTodayGradient,
        AppVisualStyle.glass => glassGradient,
        _ => null,
      },
      shape: widget.shape,
      borderRadius: widget.shape == BoxShape.rectangle
          ? BorderRadius.circular(tokens.radius.xs)
          : null,
      border: _usesGlowOutline
          ? _glowBorder(tokens, glowProgress)
          : switch (style) {
              AppVisualStyle.neumorphic when !usesFilledHighlight => null,
              AppVisualStyle.flat => Border.all(
                color: usesFilledHighlight
                    ? widget.accentColor
                    : tokens.colors.border,
                width: tokens.borderWidth,
              ),
              _ => Border.all(
                color: usesFilledHighlight
                    ? Colors.white.withValues(alpha: isDark ? 0.20 : 0.34)
                    : tokens.colors.border,
                width: tokens.borderWidth == 0 ? 1 : tokens.borderWidth,
              ),
            },
      boxShadow: _shadows(tokens, style, glowProgress),
    );
  }

  Border _glowBorder(AppTokens tokens, double glowProgress) {
    final baseWidth = tokens.borderWidth < 1 ? 1.0 : tokens.borderWidth;
    return Border.all(
      color: tokens.colors.primary.withValues(
        alpha: 0.52 + (glowProgress * 0.40),
      ),
      width: baseWidth + (glowProgress * 0.45),
    );
  }

  List<BoxShadow> _shadows(
    AppTokens tokens,
    AppVisualStyle style,
    double glowProgress,
  ) {
    if (_pressed) return const [];
    if (_usesGlowOutline) {
      final intensity = 0.56 + (glowProgress * 0.44);
      return [
        if (style != AppVisualStyle.flat) ...tokens.shadows.low,
        ...tokens.shadows.todayGlow.map(
          (shadow) => BoxShadow(
            color: shadow.color.withValues(
              alpha: (shadow.color.a * intensity).clamp(0, 1),
            ),
            offset: shadow.offset,
            blurRadius: shadow.blurRadius * (0.78 + glowProgress * 0.30),
            spreadRadius: shadow.spreadRadius + glowProgress * 0.45,
            blurStyle: shadow.blurStyle,
          ),
        ),
      ];
    }
    if (style == AppVisualStyle.flat) return const [];
    if (widget.isToday) {
      return style == AppVisualStyle.neumorphic
          ? tokens.shadows.todayGlow
          : [...tokens.shadows.low, ...tokens.shadows.todayGlow];
    }
    return _hovered ? tokens.shadows.medium : tokens.shadows.low;
  }

  void _syncGlowAnimation() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_usesGlowOutline && !reduceMotion) {
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
      return;
    }
    _glowController.stop();
    _glowController.value = _usesGlowOutline ? 0.55 : 0;
  }
}
