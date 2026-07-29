import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
