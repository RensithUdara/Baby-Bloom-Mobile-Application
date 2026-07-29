import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/baby.dart';
import '../models/vaccine.dart';
import '../theme/app_theme.dart';
import '../utils/vaccine_extensions.dart';
import '../utils/vaccine_stats.dart';
import '../database/db_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/progress_bar_row.dart';
import '../widgets/progress_donut.dart';
import '../widgets/section_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/empty_baby_state.dart';
import '../widgets/app_top_bar.dart';
import 'vaccine_details_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: l10n.progress,
        subtitle: l10n.vaccineProgress,
        actions: [
          AppBarActionButton(
            tooltip: 'Options',
            onPressed: () {},
            icon: Icons.more_vert_rounded,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _baby == null
          ? const EmptyBabyState()
          : _buildContent(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildContent() {
    final stats = VaccineStats.from(_vaccines);
    final l10n = context.l10n;

    final groups = <String, List<Vaccine>>{};
    for (final v in _vaccines) {
      final base = v.baseName;
      groups.putIfAbsent(base, () => []).add(v);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            child: Column(
              children: [
                Text(l10n.overallProgress, style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                ProgressDonut(
                  completed: stats.completed,
                  pending: stats.pending,
                  overdue: stats.overdue,
                  size: 140,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.check_circle_rounded,
                        color: AppColors.completed,
                        backgroundColor: AppColors.completedLight,
                        label: l10n.completed,
                        value: stats.completed,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        icon: Icons.hourglass_top_rounded,
                        color: AppColors.pending,
                        backgroundColor: AppColors.pendingLight,
                        label: l10n.pending,
                        value: stats.pending,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        icon: Icons.error_rounded,
                        color: AppColors.overdue,
                        backgroundColor: AppColors.overdueLight,
                        label: l10n.overdue,
                        value: stats.overdue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.vaccineProgress, style: AppTextStyles.sectionTitle),
                const SizedBox(height: 6),
                if (groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l10n.noVaccineRecordsYet,
                      style: AppTextStyles.subtitle,
                    ),
                  )
                else
                  ...groups.entries.map((entry) {
                    final list = entry.value;
                    final done = list
                        .where((v) => v.uiStatus == VaccineStatus.completed)
                        .length;
                    final ratio = list.isEmpty ? 0.0 : done / list.length;
                    final color =
                        list.any((v) => v.uiStatus == VaccineStatus.overdue)
                        ? AppColors.overdue
                        : list.any((v) => v.uiStatus == VaccineStatus.pending)
                        ? AppColors.pending
                        : AppColors.completed;
                    return ProgressBarRow(
                      label: entry.key,
                      progress: ratio,
                      color: color,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                VaccineDetailsScreen(vaccine: list.first),
                          ),
                        );
                        _loadData();
                      },
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
