import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.aboutApp),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            _Hero(
              icon: Icons.favorite_rounded,
              title: context.l10n.appName,
              subtitle: 'Care for every mother. Protect every child.',
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'What BabyBloom Does',
              body:
                  'BabyBloom helps Sri Lankan mothers keep baby health records, vaccine progress, growth details, clinic information, and reminders in one calm place.',
            ),
            const SizedBox(height: 12),
            _FeatureGrid(
              items: const [
                _Feature(Icons.vaccines_rounded, 'Vaccine tracking'),
                _Feature(Icons.notifications_active_rounded, 'Due reminders'),
                _Feature(Icons.monitor_weight_rounded, 'Growth records'),
                _Feature(Icons.local_hospital_rounded, 'MOH details'),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Important Note',
              body:
                  'This app supports daily care and record keeping. It does not replace advice from your MOH clinic, doctor, midwife, or the official child health development record.',
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                context.l10n.versionLabel,
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Hero({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, const Color(0xFFFF8A65)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.subtitle.copyWith(height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final List<_Feature> items;

  const _FeatureGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 82,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(item.label, style: AppTextStyles.cardTitle)),
            ],
          ),
        );
      },
    );
  }
}

class _Feature {
  final IconData icon;
  final String label;

  const _Feature(this.icon, this.label);
}
