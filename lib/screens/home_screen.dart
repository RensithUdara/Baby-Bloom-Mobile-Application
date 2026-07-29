import 'package:flutter/material.dart';
import '../models/baby.dart';
import '../models/vaccine.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/vaccine_extensions.dart';
import '../utils/vaccine_stats.dart';
import '../database/db_helper.dart';
import '../widgets/progress_donut.dart';
import '../widgets/stat_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/empty_baby_state.dart';
import '../widgets/app_top_bar.dart';
import 'vaccines_screen.dart';
import 'baby_profile_screen.dart';
import 'notification_history_screen.dart';
import 'mother_profile_screen.dart';
import 'moh_clinic_screen.dart';
import 'emergency_contacts_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  Baby? _baby;
  List<Vaccine> _vaccines = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final baby = await DBHelper().getActiveBaby();
    List<Vaccine> vaccines = [];
    if (baby != null && baby.id != null) {
      vaccines = await DBHelper().getVaccinesForBaby(baby.id!);
    }
    if (!mounted) return;
    setState(() {
      _baby = baby;
      _vaccines = vaccines;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'BabyBloom',
        subtitle: context.l10n.ammaGreeting,
        showBack: false,
        actions: [
          AppBarActionButton(
            icon: Icons.notifications_none_rounded,
            tooltip: context.l10n.notificationHistory,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _baby == null
            ? const EmptyBabyState()
            : _buildContent(_baby!),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildContent(Baby baby) {
    final stats = VaccineStats.from(_vaccines);

    final pendingVaccines =
        _vaccines.where((v) => v.uiStatus == VaccineStatus.pending).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final overdueVaccines =
        _vaccines.where((v) => v.uiStatus == VaccineStatus.overdue).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final nextVaccine = pendingVaccines.isNotEmpty
        ? pendingVaccines.first
        : null;
    final overdueVaccine = overdueVaccines.isNotEmpty
        ? overdueVaccines.first
        : null;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildBabyCard(baby),
          const SizedBox(height: 16),
          _buildQuickAccess(),
          const SizedBox(height: 16),
          _buildStatsGrid(stats),
          const SizedBox(height: 16),
          if (overdueVaccine != null)
            _buildTodaysReminder(context, overdueVaccine),
          if (overdueVaccine != null) const SizedBox(height: 12),
          if (nextVaccine != null) _buildNextVaccineCard(nextVaccine),
          if (nextVaccine != null) const SizedBox(height: 16),
          _buildProgressCard(context, stats),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildBabyCard(Baby baby) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.goodEvening, style: AppTextStyles.subtitle),
          const SizedBox(height: 2),
          Text(l10n.ammaGreeting, style: AppTextStyles.greeting),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BabyProfileScreen(babyId: baby.id!),
                    ),
                  );
                  _loadData();
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.pendingLight,
                        child: Text(
                          baby.name.characters.first,
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(baby.name, style: AppTextStyles.cardTitle),
                            const SizedBox(height: 2),
                            Text(
                              context.ageLabel(baby.dob),
                              style: AppTextStyles.subtitle,
                            ),
                            Text(
                              l10n.dobShort(
                                context.formatNumericDate(baby.dob),
                              ),
                              style: AppTextStyles.subtitle,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    final l10n = context.l10n;
    final items = [
      _QuickAction(
        icon: Icons.person_rounded,
        label: l10n.motherProfile,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MotherProfileScreen())),
      ),
      _QuickAction(
        icon: Icons.local_hospital_rounded,
        label: l10n.mohClinic,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MohClinicScreen())),
      ),
      _QuickAction(
        icon: Icons.calendar_month_rounded,
        label: l10n.calendar,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CalendarScreen())),
      ),
      _QuickAction(
        icon: Icons.emergency_rounded,
        label: l10n.emergencyContacts,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 82,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: AppColors.primary, size: 22),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(VaccineStats stats) {
    final l10n = context.l10n;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 76,
      ),
      children: [
        StatCard(
          icon: Icons.hourglass_top_rounded,
          color: AppColors.pending,
          backgroundColor: AppColors.pendingLight,
          label: l10n.pending,
          value: stats.pending,
        ),
        StatCard(
          icon: Icons.check_circle_rounded,
          color: AppColors.completed,
          backgroundColor: AppColors.completedLight,
          label: l10n.completed,
          value: stats.completed,
        ),
        StatCard(
          icon: Icons.error_rounded,
          color: AppColors.overdue,
          backgroundColor: AppColors.overdueLight,
          label: l10n.overdue,
          value: stats.overdue,
        ),
        StatCard(
          icon: Icons.event_rounded,
          color: AppColors.upcoming,
          backgroundColor: AppColors.upcomingLight,
          label: l10n.upcoming,
          value: stats.upcoming,
        ),
      ],
    );
  }

  Widget _buildTodaysReminder(BuildContext context, Vaccine vaccine) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.overdueLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.todaysReminder, style: AppTextStyles.cardTitle),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.error_rounded,
                      color: AppColors.overdue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.vaccineOverdueMessage(vaccine.vaccineName),
                      style: TextStyle(
                        color: AppColors.overdue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(l10n.visitClinicSoon, style: AppTextStyles.subtitle),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const VaccinesScreen()));
              _loadData();
            },
            icon: Icon(Icons.chevron_right_rounded, color: AppColors.overdue),
          ),
        ],
      ),
    );
  }

  Widget _buildNextVaccineCard(Vaccine vaccine) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEBFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE0D6F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_bottom_rounded,
              color: Color(0xFF7C5FD6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.nextVaccine, style: AppTextStyles.subtitle),
                Text(vaccine.vaccineName, style: AppTextStyles.cardTitle),
                Text(
                  context.formatShortDate(vaccine.dueDate),
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          const Icon(Icons.shield_rounded, color: Color(0xFF7C5FD6)),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, VaccineStats stats) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.vaccineProgress, style: AppTextStyles.sectionTitle),
              TextButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VaccinesScreen()),
                  );
                  _loadData();
                },
                child: Text(
                  l10n.seeAll,
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          Row(
            children: [
              ProgressDonut(
                completed: stats.completed,
                pending: stats.pending,
                overdue: stats.overdue,
                size: 110,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendRow(
                      AppColors.completed,
                      l10n.completed,
                      stats.completed,
                    ),
                    const SizedBox(height: 8),
                    _legendRow(AppColors.pending, l10n.pending, stats.pending),
                    const SizedBox(height: 8),
                    _legendRow(AppColors.overdue, l10n.overdue, stats.overdue),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label, int value) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.subtitle),
        const Spacer(),
        Text('$value', style: AppTextStyles.cardTitle),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
