import '../models/vaccine.dart';
import '../theme/app_theme.dart';

extension VaccineDisplay on Vaccine {
  VaccineStatus get uiStatus {
    switch (status) {
      case 'completed':
        return VaccineStatus.completed;
      case 'missed':
        return VaccineStatus.overdue;
      case 'pending':
      default:
        return dueDate.isBefore(DateTime.now())
            ? VaccineStatus.overdue
            : VaccineStatus.pending;
    }
  }

  String get statusLabel => status == 'missed' ? 'Missed' : uiStatus.label;

  String get dueDateText {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dueDate.day} ${months[dueDate.month - 1]} ${dueDate.year}';
  }

  String get baseName => vaccineName.replaceAll(RegExp(r'\s?\d+$'), '');

  void markCompleted() {
    status = 'completed';
    completedDate = DateTime.now();
  }
}
