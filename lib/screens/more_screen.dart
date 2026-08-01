import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/baby.dart';
import '../theme/app_theme.dart';
import '../database/db_helper.dart';
import '../l10n/l10n.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_confirm_dialog.dart';
import 'baby_profile_screen.dart';
import 'mother_profile_screen.dart';
import 'moh_clinic_screen.dart';
import 'parenting_tips_screen.dart';
import 'emergency_contacts_screen.dart';
import 'vaccine_certificate_screen.dart';
import 'settings_screen.dart';
import 'add_baby_screen.dart';
import 'notification_history_screen.dart';
import 'help_support_screen.dart';
import 'auth_gate.dart';
import 'home_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _loading = true;
  Baby? _baby;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final baby = await DBHelper().getActiveBaby();
    if (!mounted) return;
    setState(() {
      _baby = baby;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopBar(title: 'More Settings', onBack: _goHome),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _profileHeader(l10n),
                    const SizedBox(height: 18),
                    _quickGrid(l10n),
                    const SizedBox(height: 20),
                    _sectionTitle('Records'),
                    const SizedBox(height: 10),
                    _menuGroup([
                      _MoreAction(
                        icon: Icons.notifications_none_rounded,
                        label: l10n.notificationHistory,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationHistoryScreen(),
                          ),
                        ),
                      ),
                      _MoreAction(
                        icon: Icons.verified_rounded,
                        label: l10n.vaccineCertificate,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VaccineCertificateScreen(),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle('App'),
                    const SizedBox(height: 10),
                    _menuGroup([
                      _MoreAction(
                        icon: Icons.settings_rounded,
                        label: l10n.settings,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                      ),
                      _MoreAction(
                        icon: Icons.help_outline_rounded,
                        label: l10n.helpSupport,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle('Account'),
                    const SizedBox(height: 10),
                    _menuGroup([
                      _MoreAction(
                        icon: Icons.logout_rounded,
                        label: 'Sign Out',
                        onTap: _signOut,
                      ),
                    ]),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      ),
    );
  }

  void _goHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Widget _profileHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardBackground, AppColors.softSurface],
        ),
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
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                (_baby?.name.isNotEmpty ?? false)
                    ? _baby!.name.characters.first.toUpperCase()
                    : 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _baby?.name ?? l10n.ammaGreeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _baby == null ? l10n.addBaby : l10n.babyProfile,
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _openBabyProfile,
            icon: const Icon(Icons.edit_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: AppColors.divider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickGrid(AppLocalizations l10n) {
    final actions = [
      _MoreAction(
        icon: Icons.child_care_rounded,
        label: l10n.babyProfile,
        onTap: _openBabyProfile,
      ),
      _MoreAction(
        icon: Icons.person_rounded,
        label: l10n.motherProfile,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MotherProfileScreen())),
      ),
      _MoreAction(
        icon: Icons.local_hospital_rounded,
        label: l10n.mohClinic,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MohClinicScreen())),
      ),
      _MoreAction(
        icon: Icons.emergency_rounded,
        label: l10n.emergencyContacts,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
        ),
      ),
      _MoreAction(
        icon: Icons.favorite_rounded,
        label: l10n.parentingTips,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ParentingTipsScreen())),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 92,
      ),
      itemBuilder: (context, index) => _quickTile(actions[index], index),
    );
  }

  Widget _quickTile(_MoreAction action, int index) {
    final accent = [
      AppColors.primary,
      AppColors.upcoming,
      AppColors.completed,
      AppColors.overdue,
      AppColors.pending,
    ][index % 5];

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: accent, size: 20),
            ),
            Text(
              action.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _menuGroup(List<_MoreAction> actions) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            _groupRow(actions[i]),
            if (i != actions.length - 1)
              Divider(height: 1, indent: 58, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  Widget _groupRow(_MoreAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(action.icon, color: AppColors.primary, size: 21),
            const SizedBox(width: 14),
            Expanded(child: Text(action.label, style: AppTextStyles.cardTitle)),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _openBabyProfile() async {
    if (_baby == null) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AddBabyScreen()));
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BabyProfileScreen(babyId: _baby!.id!),
        ),
      );
    }
    _loadData();
  }

  Future<void> _signOut() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      cancelLabel: 'Cancel',
      confirmLabel: 'Sign Out',
      icon: Icons.logout_rounded,
      confirmColor: AppColors.primaryDark,
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }
}

class _MoreAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
