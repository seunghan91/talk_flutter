import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Main scaffold with bottom navigation - 보이스팅 design system
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.surfaceColor,
              context.accentColor,
            ],
          ),
        ),
        child: SafeArea(child: child),
      ),
      bottomNavigationBar: _BoistingNavBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/chats') || location.startsWith('/messages')) {
      return 1;
    }
    if (location.startsWith('/wallet') || location.startsWith('/market')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/chats');
        break;
      case 2:
        context.go('/wallet');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

/// Custom bottom navigation bar matching the 보이스팅 design system.
/// Active items show primary color for icon + label with no background pill.
/// Inactive items use mutedForeground. White background with top border.
class _BoistingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _BoistingNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _destinations = [
    _NavDestination(icon: Icons.home_outlined, selectedIcon: Icons.home, label: '홈'),
    _NavDestination(icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble, label: '대화'),
    _NavDestination(icon: Icons.shopping_bag_outlined, selectedIcon: Icons.shopping_bag, label: '마켓'),
    _NavDestination(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: '설정'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          top: BorderSide(color: context.borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_destinations.length, (index) {
              final dest = _destinations[index];
              final isSelected = index == selectedIndex;
              return Expanded(
                child: _NavItem(
                  destination: dest,
                  isSelected: isSelected,
                  onTap: () => onDestinationSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : context.mutedForegroundColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? destination.selectedIcon : destination.icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
