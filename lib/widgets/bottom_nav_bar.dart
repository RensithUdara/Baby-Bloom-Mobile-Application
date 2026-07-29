import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/vaccines_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/more_screen.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    late final Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const VaccinesScreen();
        break;
      case 2:
        screen = const CalendarScreen();
        break;
      case 3:
        screen = const ProgressScreen();
        break;
      default:
        screen = const MoreScreen();
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final items = [
      _NavItem(Icons.home_rounded, l10n.home),
      _NavItem(Icons.vaccines_rounded, l10n.vaccines),
      _NavItem(Icons.calendar_month_rounded, l10n.calendar),
      _NavItem(Icons.pie_chart_rounded, l10n.progress),
      _NavItem(Icons.grid_view_rounded, l10n.more),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _BottomNavItem(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => _navigate(context, i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}

class _BottomNavItem extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.26),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 21,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
