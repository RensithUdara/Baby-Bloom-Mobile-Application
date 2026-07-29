import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/vaccine.dart';
import '../theme/app_theme.dart';
import '../utils/vaccine_extensions.dart';
import '../data/firebase_content_repository.dart';
import '../widgets/app_top_bar.dart';

class VaccineDetailsScreen extends StatefulWidget {
  final Vaccine vaccine;

  const VaccineDetailsScreen({super.key, required this.vaccine});

  @override
  State<VaccineDetailsScreen> createState() => _VaccineDetailsScreenState();
}

class _VaccineDetailsScreenState extends State<VaccineDetailsScreen> {
  late Vaccine _vaccine;
  late final Future<FirebaseVaccineInfo?> _infoFuture;

  @override
  void initState() {
    super.initState();
    _vaccine = widget.vaccine;
    _infoFuture = FirebaseContentRepository.getVaccineInfo(
      (_vaccine.vaccineCode ?? _vaccine.baseName).toLowerCase(),
    );
  }

  void _markAsDone() {
    setState(() {
      _vaccine.markCompleted();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.markedAsDone(_vaccine.vaccineName)),
        backgroundColor: AppColors.completed,
      ),
    );
    Navigator.of(context).pop(_vaccine);
  }

  @override
  Widget build(BuildContext context) {
    final status = _vaccine.uiStatus;
    final isCompleted = status == VaccineStatus.completed;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: _vaccine.vaccineName),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.vaccines_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _vaccine.vaccineName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.lightColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.vaccineStatusLabel(status),
                      style: TextStyle(
                        color: status.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _card(
              child: Column(
                children: [
                  _kv(
                    context.l10n.dueDate,
                    context.formatShortDate(_vaccine.dueDate),
                  ),
                  Divider(height: 24, color: AppColors.divider),
                  _kv(
                    context.l10n.status,
                    context.vaccineStatusLabel(status),
                    valueColor: status.color,
                  ),
                ],
              ),
            ),
            FutureBuilder<FirebaseVaccineInfo?>(
              future: _infoFuture,
              builder: (context, snapshot) {
                final info = snapshot.data;
                if (info == null) return const SizedBox.shrink();

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.purpose,
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            info.purpose.current,
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.possibleSideEffects,
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 8),
                          ...info.sideEffects.map(
                            (effect) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '-  ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      effect.current,
                                      style: AppTextStyles.subtitle.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.advice,
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            info.advice.current,
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            if (status == VaccineStatus.overdue) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.overdueLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_rounded, color: AppColors.overdue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.reminder,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.overdue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.overdueAdvice,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _markAsDone,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(context.l10n.markAsDone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _kv(String key, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: AppTextStyles.subtitle),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
