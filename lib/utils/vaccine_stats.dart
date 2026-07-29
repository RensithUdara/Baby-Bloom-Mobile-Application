import '../models/vaccine.dart';
import '../theme/app_theme.dart';
import 'vaccine_extensions.dart';

class VaccineStats {
  final int completed;
  final int pending;
  final int overdue;
  final int upcoming;

  const VaccineStats({
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.upcoming,
  });

  factory VaccineStats.from(List<Vaccine> vaccines) {
    final completed = vaccines
        .where((v) => v.uiStatus == VaccineStatus.completed)
        .length;
    final overdue = vaccines
        .where((v) => v.uiStatus == VaccineStatus.overdue)
        .length;
    final pending = vaccines
        .where((v) => v.uiStatus == VaccineStatus.pending)
        .length;

    final now = DateTime.now();
    final upcoming = vaccines.where((v) {
      return v.uiStatus == VaccineStatus.pending &&
          v.dueDate.isAfter(now) &&
          v.dueDate.isBefore(now.add(const Duration(days: 30)));
    }).length;

    return VaccineStats(
      completed: completed,
      pending: pending,
      overdue: overdue,
      upcoming: upcoming,
    );
  }
}
