import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Custom avatar widget with various styles and states
class AppAvatar extends StatelessWidget {
  /// Display name (used for initials)
  final String? name;

  /// Image URL
  final String? imageUrl;

  /// Avatar radius
  final double radius;

  /// Background color (if no image)
  final Color? backgroundColor;

  /// Text color for initials
  final Color? textColor;

  /// Border color
  final Color? borderColor;

  /// Border width
  final double borderWidth;

  /// Whether to show online indicator
  final bool showOnlineIndicator;

  /// Whether user is online
  final bool isOnline;

  /// Badge count (e.g., unread messages)
  final int? badgeCount;

  /// Badge color
  final Color? badgeColor;

  /// On tap callback
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.radius = AppAvatarSize.md,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 0,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.badgeCount,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.primaryContainer;
    final effectiveTextColor =
        textColor ?? theme.colorScheme.onPrimaryContainer;

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBackgroundColor,
      backgroundImage: imageUrl != null ? _buildNetworkImage() : null,
      onBackgroundImageError: imageUrl != null
          ? (exception, stackTrace) {
              // Error is handled silently - fallback to initials will be shown
            }
          : null,
      child: imageUrl == null
          ? Text(
              _getInitials(name),
              style: TextStyle(
                color: effectiveTextColor,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.7,
              ),
            )
          : null,
    );

    // Add border if specified
    if (borderWidth > 0 && borderColor != null) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor!,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    // Add online indicator and/or badge
    if (showOnlineIndicator || badgeCount != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,

          // Online indicator
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: Semantics(
                label: isOnline ? '온라인' : '오프라인',
                child: Container(
                  width: radius * 0.4,
                  height: radius * 0.4,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.online : AppColors.offline,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

          // Badge count
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: -4,
              top: -4,
              child: _buildBadge(context),
            ),
        ],
      );
    }

    // Wrap with Semantics for accessibility
    avatar = Semantics(
      label: _buildSemanticLabel(),
      image: imageUrl != null,
      child: avatar,
    );

    // Add tap handler
    if (onTap != null) {
      avatar = Tooltip(
        message: name ?? '사용자 프로필',
        child: GestureDetector(
          onTap: onTap,
          child: avatar,
        ),
      );
    }

    return avatar;
  }

  ImageProvider _buildNetworkImage() {
    return NetworkImage(imageUrl!);
  }

  String _buildSemanticLabel() {
    final parts = <String>[];

    if (name != null && name!.isNotEmpty) {
      parts.add('$name 프로필');
    } else {
      parts.add('사용자 프로필');
    }

    if (showOnlineIndicator) {
      parts.add(isOnline ? '온라인' : '오프라인');
    }

    if (badgeCount != null && badgeCount! > 0) {
      parts.add('읽지 않은 메시지 $badgeCount개');
    }

    return parts.join(', ');
  }

  Widget _buildBadge(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBadgeColor = badgeColor ?? theme.colorScheme.error;
    final displayCount = badgeCount! > 99 ? '99+' : '$badgeCount';

    return Semantics(
      label: '읽지 않은 메시지 $badgeCount개',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs + 2,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: effectiveBadgeColor,
          borderRadius: BorderRadius.circular(AppRadius.sm + 2),
          border: Border.all(
            color: theme.colorScheme.surface,
            width: 2,
          ),
        ),
        constraints: const BoxConstraints(
          minWidth: 18,
          minHeight: 18,
        ),
        child: Text(
          displayCount,
          style: AppTypography.badge(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // ============ Factory Constructors ============

  /// Small avatar (24px radius)
  factory AppAvatar.small({
    String? name,
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    return AppAvatar(
      name: name,
      imageUrl: imageUrl,
      radius: AppAvatarSize.sm,
      onTap: onTap,
    );
  }

  /// Medium avatar (28px radius) - Default
  factory AppAvatar.medium({
    String? name,
    String? imageUrl,
    int? badgeCount,
    VoidCallback? onTap,
  }) {
    return AppAvatar(
      name: name,
      imageUrl: imageUrl,
      radius: AppAvatarSize.md,
      badgeCount: badgeCount,
      onTap: onTap,
    );
  }

  /// Large avatar (40px radius)
  factory AppAvatar.large({
    String? name,
    String? imageUrl,
    bool showOnlineIndicator = false,
    bool isOnline = false,
    VoidCallback? onTap,
  }) {
    return AppAvatar(
      name: name,
      imageUrl: imageUrl,
      radius: AppAvatarSize.xl,
      showOnlineIndicator: showOnlineIndicator,
      isOnline: isOnline,
      onTap: onTap,
    );
  }

  /// Hero avatar for profile pages (64px radius)
  factory AppAvatar.hero({
    String? name,
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    return AppAvatar(
      name: name,
      imageUrl: imageUrl,
      radius: AppAvatarSize.hero,
      onTap: onTap,
    );
  }

  /// Avatar with unread badge
  factory AppAvatar.withBadge({
    String? name,
    String? imageUrl,
    required int badgeCount,
    double radius = AppAvatarSize.md,
  }) {
    return AppAvatar(
      name: name,
      imageUrl: imageUrl,
      radius: radius,
      badgeCount: badgeCount,
    );
  }
}
