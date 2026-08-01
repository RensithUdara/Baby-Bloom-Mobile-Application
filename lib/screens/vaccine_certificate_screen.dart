import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../l10n/l10n.dart';
import '../models/baby.dart';
import '../models/vaccine.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';

class VaccineCertificateScreen extends StatefulWidget {
  const VaccineCertificateScreen({super.key});

  @override
  State<VaccineCertificateScreen> createState() =>
      _VaccineCertificateScreenState();
}

class _VaccineCertificateScreenState extends State<VaccineCertificateScreen> {
  Baby? baby;
  List<Vaccine> completedVaccines = [];
  int pendingCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final activeBaby = await DBHelper().getActiveBaby();

    if (activeBaby == null || activeBaby.id == null) {
      setState(() {
        baby = null;
        loading = false;
      });
      return;
    }

    final vaccines = await DBHelper().getVaccinesForBaby(activeBaby.id!);
    final completed = vaccines.where((v) => v.status == 'completed').toList()
      ..sort(
        (a, b) => (a.completedDate ?? a.dueDate).compareTo(
          b.completedDate ?? b.dueDate,
        ),
      );
    final pending = vaccines.where((v) => v.status != 'completed').length;

    setState(() {
      baby = activeBaby;
      completedVaccines = completed;
      pendingCount = pending;
      loading = false;
    });
  }

  String _formatDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.vaccineCertificate),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : baby == null
            ? _buildNoBaby()
            : _buildCertificate(baby!),
      ),
    );
  }

  Widget _buildNoBaby() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.softSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.child_care_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.noBabyProfileFound,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.addBabyForCertificate,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto(String? photoPath) {
    if (photoPath == null || photoPath.trim().isEmpty) {
      return CircleAvatar(
        radius: 38,
        backgroundColor: AppColors.softSurface,
        child: Icon(
          Icons.child_care_rounded,
          size: 36,
          color: AppColors.primary,
        ),
      );
    }
    return CircleAvatar(
      radius: 38,
      backgroundColor: AppColors.softSurface,
      backgroundImage: FileImage(File(photoPath)),
    );
  }

  Widget _buildCertificate(Baby baby) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Container(
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
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Child Immunization Certificate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${completedVaccines.length} completed • $pendingCount pending',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              _buildPhoto(baby.photoPath),
              const SizedBox(height: 10),
              Text(
                baby.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.bornOn(
                  context.genderLabel(baby.gender),
                  _formatDate(baby.dob),
                ),
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              if (baby.bloodGroup != null || baby.hospital != null) ...[
                const SizedBox(height: 2),
                Text(
                  [
                    if (baby.bloodGroup != null)
                      context.l10n.bloodGroupValue(baby.bloodGroup!),
                    if (baby.hospital != null)
                      context.l10n.bornAt(baby.hospital!),
                  ].join(' • '),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _statPill(
                      Icons.check_circle_rounded,
                      '${completedVaccines.length}',
                      'Completed',
                      AppColors.completed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statPill(
                      Icons.schedule_rounded,
                      '$pendingCount',
                      'Pending',
                      AppColors.pending,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 16),
              if (completedVaccines.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    context.l10n.noVaccinesCompletedYet,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Column(
                  children: completedVaccines
                      .map((v) => _completedRow(v))
                      .toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.softSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            context.l10n.certificateDisclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statPill(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _completedRow(Vaccine vaccine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.completed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppColors.completed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.vaccineDose(
                    vaccine.vaccineName,
                    vaccine.doseNumber,
                  ),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.givenOn(
                    _formatDate(vaccine.completedDate ?? vaccine.dueDate),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
