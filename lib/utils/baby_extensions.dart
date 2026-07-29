import '../models/baby.dart';

extension BabyDisplay on Baby {
  String get ageText {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    int days = now.day - dob.day;
    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(now.year, now.month - 1, dob.day);
      days = now.difference(prevMonth).inDays;
    }
    final parts = <String>[];
    if (months > 0) parts.add('$months Month${months == 1 ? '' : 's'}');
    parts.add('$days Day${days == 1 ? '' : 's'}');
    return parts.join(' ');
  }

  String get genderLabel {
    if (gender.isEmpty) return gender;
    return gender[0].toUpperCase() + gender.substring(1);
  }

  String get dobText => '${dob.day}/${dob.month}/${dob.year}';
}
