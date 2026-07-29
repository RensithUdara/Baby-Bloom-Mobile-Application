import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.softSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.cardTitle)),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
