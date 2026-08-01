import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/baby.dart';
import '../models/vaccine.dart';
import '../theme/app_theme.dart';
import '../utils/vaccine_extensions.dart';
import '../database/db_helper.dart';
import '../widgets/vaccine_tile.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/empty_baby_state.dart';
import '../widgets/app_top_bar.dart';
import 'add_vaccine_screen.dart';
import 'vaccine_details_screen.dart';
import 'home_screen.dart';

class VaccinesScreen extends StatefulWidget {
  const VaccinesScreen({super.key});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  bool _loading = true;
  Baby? _baby;
  List<Vaccine> _vaccines = [];
  VaccineStatus? _filter;

  final _filters = <VaccineStatus?>[
    null,
    VaccineStatus.overdue,
    VaccineStatus.pending,
    VaccineStatus.completed,
  ];

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

  Future<void> _markAsDone(Vaccine vaccine) async {
    await DBHelper().updateVaccineStatus(
      vaccine.id!,
      'completed',
      DateTime.now(),
    );
    if (!mounted) return;
    setState(() {
      vaccine.markCompleted();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.markedAsDone(vaccine.vaccineName)),
        backgroundColor: AppColors.completed,
        duration: const Duration(seconds: 2),
      ),
    );
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
        appBar: AppTopBar(
          title: _baby == null ? l10n.vaccines : '${_baby!.name} Vaccines',
          onBack: _goHome,
          actions: [
            AppBarActionButton(
              tooltip: 'Add vaccine',
              onPressed: _baby == null ? null : _addVaccine,
              icon: Icons.add_rounded,
            ),
          ],
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _baby == null
            ? const EmptyBabyState()
            : _buildContent(),
        floatingActionButton: _baby == null || _loading
            ? null
            : FloatingActionButton(
                onPressed: _addVaccine,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add_rounded),
              ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      ),
    );
  }

  void _goHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Future<void> _addVaccine() async {
    final baby = _baby;
    if (baby == null || baby.id == null) return;

    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddVaccineScreen(baby: baby)),
    );
    if (added == true) {
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vaccine added with reminders')),
      );
    }
  }

  Widget _buildContent() {
    final filtered = _filter == null
        ? _vaccines
        : _vaccines.where((v) => v.uiStatus == _filter).toList();

    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final vaccine = filtered[index];
                      return VaccineTile(
                        vaccine: vaccine,
                        onMarkDone: vaccine.uiStatus == VaccineStatus.completed
                            ? null
                            : () => _markAsDone(vaccine),
                        onTap: () async {
                          final updated = await Navigator.of(context)
                              .push<Vaccine>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VaccineDetailsScreen(vaccine: vaccine),
                                ),
                              );
                          if (updated != null) {
                            _loadData();
                          }
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((status) {
            final isSelected = _filter == status;
            final label = status == null
                ? context.l10n.all
                : context.vaccineStatusLabel(status);
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => setState(() => _filter = status),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.cardBackground,
                disabledColor: AppColors.elevatedSurface,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.vaccines_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.noVaccinesInCategory,
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
}
