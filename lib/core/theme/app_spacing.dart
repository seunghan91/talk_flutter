import 'package:flutter/material.dart';

/// App spacing system - Consistent spacing tokens across the app
class AppSpacing {
  AppSpacing._();

  // ============ Base Spacing Units ============
  /// 4px - Minimal spacing
  static const double xxs = 4;

  /// 8px - Extra small spacing
  static const double xs = 8;

  /// 12px - Small spacing
  static const double sm = 12;

  /// 16px - Medium spacing (base unit)
  static const double md = 16;

  /// 20px - Medium-large spacing
  static const double lg = 20;

  /// 24px - Large spacing
  static const double xl = 24;

  /// 32px - Extra large spacing
  static const double xxl = 32;

  /// 40px - 2x extra large spacing
  static const double xxxl = 40;

  /// 48px - Section spacing
  static const double section = 48;

  /// 64px - Page spacing
  static const double page = 64;

  // ============ Common Padding Patterns ============
  /// Standard screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(md);

  /// Horizontal screen padding
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: md);

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: sm,
  );

  /// Input field padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Dialog padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl);

  /// Bottom sheet padding
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(md, xs, md, md);

  // ============ Gap Widgets ============
  /// Vertical gaps
  static const SizedBox verticalXxs = SizedBox(height: xxs);
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);

  /// Horizontal gaps
  static const SizedBox horizontalXxs = SizedBox(width: xxs);
  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
  static const SizedBox horizontalXxl = SizedBox(width: xxl);
}

/// App border radius system
class AppRadius {
  AppRadius._();

  /// 4px - Small radius
  static const double xs = 4;

  /// 8px - Medium-small radius
  static const double sm = 8;

  /// 12px - Medium radius
  static const double md = 12;

  /// 16px - Medium-large radius
  static const double lg = 16;

  /// 20px - Large radius
  static const double xl = 20;

  /// 24px - Extra large radius
  static const double xxl = 24;

  /// 9999px - Full/Circular radius
  static const double full = 9999;

  // ============ Border Radius Presets ============
  static final BorderRadius smallRadius = BorderRadius.circular(sm);
  static final BorderRadius mediumRadius = BorderRadius.circular(md);
  static final BorderRadius largeRadius = BorderRadius.circular(lg);
  static final BorderRadius extraLargeRadius = BorderRadius.circular(xl);
  static final BorderRadius circularRadius = BorderRadius.circular(full);

  /// Card radius
  static final BorderRadius cardRadius = BorderRadius.circular(md);

  /// Button radius
  static final BorderRadius buttonRadius = BorderRadius.circular(sm);

  /// Input radius
  static final BorderRadius inputRadius = BorderRadius.circular(sm);

  /// Avatar radius (circular)
  static final BorderRadius avatarRadius = BorderRadius.circular(full);

  /// Bottom sheet radius
  static final BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

/// App icon sizes
class AppIconSize {
  AppIconSize._();

  /// 12px - Extra small icon
  static const double xs = 12;

  /// 16px - Small icon
  static const double sm = 16;

  /// 20px - Medium-small icon
  static const double md = 20;

  /// 24px - Standard icon (default)
  static const double lg = 24;

  /// 32px - Large icon
  static const double xl = 32;

  /// 48px - Extra large icon
  static const double xxl = 48;

  /// 64px - Hero/empty state icon
  static const double hero = 64;

  /// 80px - Large hero icon
  static const double heroLarge = 80;
}

/// App avatar sizes
class AppAvatarSize {
  AppAvatarSize._();

  /// 24px radius - Small avatar
  static const double sm = 24;

  /// 28px radius - Medium avatar
  static const double md = 28;

  /// 32px radius - Standard avatar
  static const double lg = 32;

  /// 40px radius - Large avatar
  static const double xl = 40;

  /// 48px radius - Extra large avatar
  static const double xxl = 48;

  /// 64px radius - Hero avatar
  static const double hero = 64;
}
