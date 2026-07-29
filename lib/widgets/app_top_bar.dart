import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final bool centerTitle;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.centerTitle = false,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 62 : 70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      toolbarHeight: preferredSize.height,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      clipBehavior: Clip.antiAlias,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                  const Color(0xFFFF8A65),
                ],
              ),
            ),
          ),
          Positioned(
            right: -22,
            top: -28,
            child: Container(
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 14,
                ),
              ),
            ),
          ),
          Positioned(
            left: -32,
            bottom: -54,
            child: Container(
              width: 132,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
          ),
        ],
      ),
      leadingWidth: showBack ? 72 : 0,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _AppBarIconButton(
                icon: Icons.chevron_left_rounded,
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
            )
          : null,
      centerTitle: centerTitle,
      titleSpacing: showBack ? 10 : 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!showBack) ...[
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: actions == null
          ? null
          : [
              for (final action in actions!)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: action,
                ),
            ],
    );
  }
}

class AppBarActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const AppBarActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return _AppBarIconButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _AppBarIconButton({required this.icon, this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white.withValues(alpha: onPressed == null ? 0.07 : 0.14),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Icon(icon, size: 27, color: Colors.white),
        ),
      ),
    );

    return Center(
      child: tooltip == null
          ? button
          : Tooltip(message: tooltip!, child: button),
    );
  }
}
