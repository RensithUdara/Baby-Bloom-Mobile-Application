import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String formatShortDate(DateTime date) {
    return DateFormat.yMMMd(l10n.localeName).format(date);
  }

  String formatNumericDate(DateTime date) {
    return DateFormat.yMd(l10n.localeName).format(date);
  }

  String vaccineStatusLabel(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.overdue:
        return l10n.overdue;
      case VaccineStatus.pending:
        return l10n.pending;
      case VaccineStatus.completed:
        return l10n.completed;
      case VaccineStatus.upcoming:
        return l10n.upcoming;
    }
  }

  String genderLabel(String gender) {
    switch (gender.toLowerCase()) {
      case 'female':
        return l10n.female;
      case 'male':
        return l10n.male;
      default:
        return gender;
    }
  }

  String ageLabel(DateTime dob) {
    final now = DateTime.now();
    final diff = now.difference(dob);
    if (diff.inDays < 31) {
      final days = diff.inDays;
      return l10n.dayCount(days);
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return l10n.monthCount(months);
    }
    final years = (diff.inDays / 365).floor();
    return l10n.yearCount(years);
  }

  List<String> get monthNames => [
    l10n.january,
    l10n.february,
    l10n.march,
    l10n.april,
    l10n.may,
    l10n.june,
    l10n.july,
    l10n.august,
    l10n.september,
    l10n.october,
    l10n.november,
    l10n.december,
  ];

  List<String> get weekdayShortNames => [
    l10n.sun,
    l10n.mon,
    l10n.tue,
    l10n.wed,
    l10n.thu,
    l10n.fri,
    l10n.sat,
  ];
}
