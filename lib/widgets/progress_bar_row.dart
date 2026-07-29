import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressBarRow extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;
  final VoidCallback? onTap;

  const ProgressBarRow({
    super.key,
    required this.label,
    required this.progress,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              child: Text(
                label,
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
