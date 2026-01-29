import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Loading indicator widget with various styles
class AppLoading extends StatelessWidget {
  /// Loading message
  final String? message;

  /// Size of the loading indicator
  final double size;

  /// Stroke width for circular indicator
  final double strokeWidth;

  /// Loading style
  final AppLoadingStyle style;

  const AppLoading({
    super.key,
    this.message,
    this.size = 40,
    this.strokeWidth = 3,
    this.style = AppLoadingStyle.circular,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget indicator;

    switch (style) {
      case AppLoadingStyle.circular:
        indicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
          ),
        );
        break;

      case AppLoadingStyle.dots:
        indicator = _DotsLoading(size: size);
        break;

      case AppLoadingStyle.pulse:
        indicator = _PulseLoading(size: size);
        break;
    }

    if (message == null) {
      return Center(child: indicator);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          AppSpacing.verticalMd,
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============ Factory Constructors ============

  /// Full screen loading overlay
  factory AppLoading.fullScreen({String? message}) {
    return AppLoading(
      message: message,
      size: 48,
      style: AppLoadingStyle.circular,
    );
  }

  /// Inline loading indicator
  factory AppLoading.inline({double size = 20}) {
    return AppLoading(
      size: size,
      strokeWidth: 2,
      style: AppLoadingStyle.circular,
    );
  }

  /// Button loading indicator
  factory AppLoading.button({Color? color}) {
    return const AppLoading(
      size: 20,
      strokeWidth: 2,
      style: AppLoadingStyle.circular,
    );
  }
}

/// Loading style options
enum AppLoadingStyle {
  circular,
  dots,
  pulse,
}

/// Dots loading animation
class _DotsLoading extends StatefulWidget {
  final double size;

  const _DotsLoading({required this.size});

  @override
  State<_DotsLoading> createState() => _DotsLoadingState();
}

class _DotsLoadingState extends State<_DotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotSize = widget.size / 4;

    return SizedBox(
      width: widget.size,
      height: dotSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (_controller.value - delay).clamp(0.0, 1.0);
              final scale = 0.5 + (0.5 * (1 - (2 * value - 1).abs()));

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Pulse loading animation
class _PulseLoading extends StatefulWidget {
  final double size;

  const _PulseLoading({required this.size});

  @override
  State<_PulseLoading> createState() => _PulseLoadingState();
}

class _PulseLoadingState extends State<_PulseLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse
            Transform.scale(
              scale: 1.0 + (_controller.value * 0.3),
              child: Opacity(
                opacity: 1.0 - _controller.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Inner circle
            Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Loading overlay widget
class AppLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: AppLoading.fullScreen(message: message),
            ),
          ),
      ],
    );
  }
}
