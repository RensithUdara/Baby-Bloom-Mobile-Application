import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/vaccine.dart';
import '../theme/app_theme.dart';
import '../utils/vaccine_extensions.dart';

class VaccineTile extends StatelessWidget {
  final Vaccine vaccine;
  final VoidCallback? onMarkDone;
  final VoidCallback? onTap;

  const VaccineTile({
    super.key,
    required this.vaccine,
    this.onMarkDone,
    this.onTap,
  });

  IconData _statusIcon(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.completed:
        return Icons.check_circle_rounded;
      case VaccineStatus.overdue:
        return Icons.error_rounded;
      case VaccineStatus.pending:
        return Icons.hourglass_top_rounded;
      case VaccineStatus.upcoming:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = vaccine.uiStatus;
    final isCompleted = status == VaccineStatus.completed;
    final l10n = context.l10n;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: status.lightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.vaccines_rounded,
                color: status.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vaccine.vaccineName, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    l10n.due(context.formatShortDate(vaccine.dueDate)),
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(_statusIcon(status), size: 14, color: status.color),
                      const SizedBox(width: 4),
                      Text(
                        context.vaccineStatusLabel(status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isCompleted)
              ElevatedButton(
                onPressed: onMarkDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(l10n.markAsDone),
              ),
          ],
        ),
      ),
    );
  }
}
