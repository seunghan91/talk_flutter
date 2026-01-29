import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Shimmer effect for skeleton loading
class AppShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
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
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Base skeleton widget
class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? margin;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          borderRadius: borderRadius ?? AppRadius.smallRadius,
        ),
      ),
    );
  }

  // ============ Factory Constructors ============

  /// Line skeleton (text placeholder)
  factory AppSkeleton.line({
    double width = double.infinity,
    double height = 16,
    EdgeInsetsGeometry? margin,
  }) {
    return AppSkeleton(
      width: width,
      height: height,
      borderRadius: AppRadius.smallRadius,
      margin: margin,
    );
  }

  /// Circle skeleton (avatar placeholder)
  factory AppSkeleton.circle({
    double size = 48,
    EdgeInsetsGeometry? margin,
  }) {
    return AppSkeleton(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      margin: margin,
    );
  }

  /// Box skeleton (card/image placeholder)
  factory AppSkeleton.box({
    double? width,
    double height = 100,
    EdgeInsetsGeometry? margin,
  }) {
    return AppSkeleton(
      width: width,
      height: height,
      borderRadius: AppRadius.mediumRadius,
      margin: margin,
    );
  }
}

/// Skeleton for list item (avatar + text)
class SkeletonListTile extends StatelessWidget {
  final double avatarSize;
  final int lineCount;
  final double titleWidth;
  final double subtitleWidth;
  final bool hasTrailing;

  const SkeletonListTile({
    super.key,
    this.avatarSize = 48,
    this.lineCount = 2,
    this.titleWidth = 0.6,
    this.subtitleWidth = 0.4,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: AppSpacing.listItemPadding,
        child: Row(
          children: [
            // Avatar
            AppSkeleton.circle(size: avatarSize),

            AppSpacing.horizontalMd,

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  AppSkeleton.line(
                    width: MediaQuery.of(context).size.width * titleWidth,
                    height: 16,
                  ),

                  if (lineCount > 1) ...[
                    AppSpacing.verticalXs,
                    // Subtitle
                    AppSkeleton.line(
                      width: MediaQuery.of(context).size.width * subtitleWidth,
                      height: 14,
                    ),
                  ],
                ],
              ),
            ),

            // Trailing
            if (hasTrailing) ...[
              AppSpacing.horizontalSm,
              AppSkeleton.line(width: 40, height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton for broadcast card
class SkeletonBroadcastCard extends StatelessWidget {
  const SkeletonBroadcastCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AppSkeleton.circle(size: 48),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton.line(width: 120, height: 16),
                      AppSpacing.verticalXs,
                      AppSkeleton.line(width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),

            AppSpacing.verticalMd,

            // Audio player placeholder
            AppSkeleton.box(height: 56),

            AppSpacing.verticalMd,

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppSkeleton.line(width: 80, height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for conversation tile
class SkeletonConversationTile extends StatelessWidget {
  const SkeletonConversationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: AppSpacing.listItemPadding,
        child: Row(
          children: [
            // Avatar with badge placeholder
            Stack(
              children: [
                AppSkeleton.circle(size: 56),
              ],
            ),

            AppSpacing.horizontalMd,

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton.line(width: 100, height: 16),
                  AppSpacing.verticalXs,
                  Row(
                    children: [
                      AppSkeleton.line(width: 16, height: 14),
                      AppSpacing.horizontalXs,
                      Expanded(
                        child: AppSkeleton.line(height: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            AppSpacing.horizontalSm,

            // Trailing
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppSkeleton.line(width: 50, height: 12),
                AppSpacing.verticalXs,
                AppSkeleton.circle(size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list builder
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;

  const SkeletonList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  /// Skeleton list for broadcasts
  factory SkeletonList.broadcasts({int count = 3}) {
    return SkeletonList(
      itemCount: count,
      padding: AppSpacing.screenPadding,
      itemBuilder: (context, index) => const SkeletonBroadcastCard(),
    );
  }

  /// Skeleton list for conversations
  factory SkeletonList.conversations({int count = 5}) {
    return SkeletonList(
      itemCount: count,
      itemBuilder: (context, index) => const SkeletonConversationTile(),
    );
  }

  /// Skeleton list for notifications
  factory SkeletonList.notifications({int count = 5}) {
    return SkeletonList(
      itemCount: count,
      itemBuilder: (context, index) => const SkeletonListTile(
        avatarSize: 40,
        lineCount: 2,
        hasTrailing: true,
      ),
    );
  }

  /// Skeleton list for transactions
  factory SkeletonList.transactions({int count = 5}) {
    return SkeletonList(
      itemCount: count,
      padding: AppSpacing.screenPadding,
      itemBuilder: (context, index) => const SkeletonListTile(
        avatarSize: 40,
        lineCount: 2,
        hasTrailing: true,
      ),
    );
  }
}
