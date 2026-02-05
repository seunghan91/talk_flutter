import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Badge widget for status indicators and counts
class AppBadge extends StatelessWidget {
  /// Badge text
  final String text;

  /// Badge color
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  /// Badge style
  final AppBadgeStyle style;

  /// Icon to display before text
  final IconData? icon;

  /// Badge size
  final AppBadgeSize size;

  const AppBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.style = AppBadgeStyle.filled,
    this.icon,
    this.size = AppBadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = backgroundColor ??
        (style == AppBadgeStyle.filled
            ? theme.colorScheme.primary
            : theme.colorScheme.primaryContainer);

    final effectiveTextColor = textColor ??
        (style == AppBadgeStyle.filled
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onPrimaryContainer);

    final padding = switch (size) {
      AppBadgeSize.small => const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs + 2,
          vertical: 2,
        ),
      AppBadgeSize.medium => const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
      AppBadgeSize.large => const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs + 2,
        ),
    };

    final fontSize = switch (size) {
      AppBadgeSize.small => 10.0,
      AppBadgeSize.medium => 12.0,
      AppBadgeSize.large => 14.0,
    };

    final iconSize = switch (size) {
      AppBadgeSize.small => 10.0,
      AppBadgeSize.medium => 12.0,
      AppBadgeSize.large => 16.0,
    };

    return Semantics(
      label: text,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: style == AppBadgeStyle.outlined
              ? Colors.transparent
              : effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(fontSize),
          border: style == AppBadgeStyle.outlined
              ? Border.all(color: effectiveBackgroundColor)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: style == AppBadgeStyle.outlined
                    ? effectiveBackgroundColor
                    : effectiveTextColor,
              ),
              SizedBox(width: size == AppBadgeSize.small ? 2 : AppSpacing.xxs),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: style == AppBadgeStyle.outlined
                    ? effectiveBackgroundColor
                    : effectiveTextColor,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ Factory Constructors ============

  /// Count badge (e.g., unread messages)
  factory AppBadge.count(int count, {Color? color}) {
    return AppBadge(
      text: count > 99 ? '99+' : '$count',
      backgroundColor: color ?? AppColors.error,
      size: AppBadgeSize.small,
    );
  }

  /// Status badge (new, updated, etc.)
  factory AppBadge.status(String text, {required Color color}) {
    return AppBadge(
      text: text,
      backgroundColor: color,
      size: AppBadgeSize.small,
    );
  }

  /// New badge
  factory AppBadge.newItem() {
    return const AppBadge(
      text: 'NEW',
      backgroundColor: AppColors.error,
      size: AppBadgeSize.small,
    );
  }

  /// Expiring soon badge
  factory AppBadge.expiring() {
    return const AppBadge(
      text: '곧 만료',
      backgroundColor: AppColors.warning,
      size: AppBadgeSize.small,
      icon: Icons.schedule,
    );
  }

  /// Success badge
  factory AppBadge.success(String text) {
    return AppBadge(
      text: text,
      backgroundColor: AppColors.success,
      size: AppBadgeSize.small,
    );
  }

  /// Warning badge
  factory AppBadge.warning(String text) {
    return AppBadge(
      text: text,
      backgroundColor: AppColors.warning,
      size: AppBadgeSize.small,
    );
  }

  /// Error badge
  factory AppBadge.error(String text) {
    return AppBadge(
      text: text,
      backgroundColor: AppColors.error,
      size: AppBadgeSize.small,
    );
  }

  /// Info badge
  factory AppBadge.info(String text) {
    return AppBadge(
      text: text,
      backgroundColor: AppColors.info,
      size: AppBadgeSize.small,
    );
  }

  /// Outlined badge
  factory AppBadge.outlined(String text, {Color? color}) {
    return AppBadge(
      text: text,
      backgroundColor: color,
      style: AppBadgeStyle.outlined,
    );
  }

  /// Soft/Tonal badge
  factory AppBadge.soft(String text, {Color? color}) {
    return AppBadge(
      text: text,
      backgroundColor: color,
      style: AppBadgeStyle.soft,
    );
  }
}

/// Badge style options
enum AppBadgeStyle {
  filled,
  outlined,
  soft,
}

/// Badge size options
enum AppBadgeSize {
  small,
  medium,
  large,
}

/// Dot indicator for unread/new items
class AppDotIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  final bool animate;

  const AppDotIndicator({
    super.key,
    this.color,
    this.size = 8,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    Widget dot = Semantics(
      label: '새 항목 표시',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: effectiveColor,
          shape: BoxShape.circle,
        ),
      ),
    );

    if (animate) {
      dot = _AnimatedDot(color: effectiveColor, size: size);
    }

    return dot;
  }
}

class _AnimatedDot extends StatefulWidget {
  final Color color;
  final double size;

  const _AnimatedDot({required this.color, required this.size});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    return Semantics(
      label: '새 항목 표시',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulse ring
              Transform.scale(
                scale: 1.0 + (_controller.value * 0.5),
                child: Opacity(
                  opacity: 1.0 - _controller.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // Core dot
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
