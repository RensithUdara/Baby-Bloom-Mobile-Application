import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.privacyPolicy),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: const [
            _PrivacyHero(),
            SizedBox(height: 16),
            _PolicyCard(
              icon: Icons.phone_android_rounded,
              title: 'Your Records Stay With You',
              body:
                  'Baby profiles, vaccine records, growth entries, reminders, and contact details are used to help you manage care inside the app.',
            ),
            SizedBox(height: 12),
            _PolicyCard(
              icon: Icons.lock_rounded,
              title: 'Privacy First',
              body:
                  'Do not enter information you are not comfortable storing on your device. Keep your phone protected with a passcode or biometric lock.',
            ),
            SizedBox(height: 12),
            _PolicyCard(
              icon: Icons.medical_information_rounded,
              title: 'Health Disclaimer',
              body:
                  'BabyBloom is a record keeping and reminder tool. For medical decisions, vaccine timing questions, or urgent symptoms, contact your MOH clinic or a qualified health professional.',
            ),
            SizedBox(height: 12),
            _PolicyCard(
              icon: Icons.update_rounded,
              title: 'App Updates',
              body:
                  'Future versions may improve storage, syncing, or safety features. Any important privacy change should be explained clearly in the app.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.privacy_tip_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clear, simple, and focused on mother and baby records.',
                  style: AppTextStyles.subtitle.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PolicyCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: AppTextStyles.subtitle.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
