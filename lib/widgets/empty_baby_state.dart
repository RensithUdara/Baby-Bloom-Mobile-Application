import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../screens/add_baby_screen.dart';

class EmptyBabyState extends StatelessWidget {
  const EmptyBabyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pendingLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.child_friendly_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.noBabyAddedYet, style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text(
              l10n.noBabyAddedMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddBabyScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addYourBaby),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
