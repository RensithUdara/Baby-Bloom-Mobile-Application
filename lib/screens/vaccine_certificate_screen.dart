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
            const Icon(Icons.child_care_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              context.l10n.noBabyProfileFound,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.addBabyForCertificate,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto(String? photoPath) {
    if (photoPath == null || photoPath.trim().isEmpty) {
      return CircleAvatar(
        radius: 36,
        backgroundColor: AppColors.softSurface,
        child: Icon(
          Icons.child_care_rounded,
          size: 36,
          color: AppColors.primary,
        ),
      );
    }
    return CircleAvatar(
      radius: 36,
      backgroundColor: AppColors.softSurface,
      backgroundImage: FileImage(File(photoPath)),
    );
  }

  Widget _buildCertificate(Baby baby) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(Icons.verified_rounded, color: AppColors.primary, size: 32),
              const SizedBox(height: 6),
              Text(
                'Child Immunization Certificate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
                  ].join(' ? '),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              if (completedVaccines.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    context.l10n.noVaccinesCompletedYet,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                )
              else
                Column(
                  children: completedVaccines
                      .map(
                        (v) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.vaccineDose(
                                        v.vaccineName,
                                        v.doseNumber,
                                      ),
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      context.l10n.givenOn(
                                        _formatDate(
                                          v.completedDate ?? v.dueDate,
                                        ),
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
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 4),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.vaccinesCompletedCount(
                      completedVaccines.length,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (pendingCount > 0)
                    Text(
                      '$pendingCount pending',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'This certificate is generated from records entered in this app. Please carry your official MOH child health record book for clinic visits.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
