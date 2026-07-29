import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color iconBackground;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.iconBackground = const Color(0xFFFCE4E9),
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBackground == const Color(0xFFFCE4E9)
                  ? AppColors.softSurface
                  : iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: resolvedIconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.subtitle),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.cardTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
