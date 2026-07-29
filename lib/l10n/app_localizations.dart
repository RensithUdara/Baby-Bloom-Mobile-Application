import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  String get appName;

  String get home;

  String get vaccines;

  String get calendar;

  String get progress;

  String get more;

  String get babyProfile;

  String get motherProfile;

  String get mohClinic;

  String get mohClinicDetails;

  String get parentingTips;

  String get emergencyContacts;

  String get notificationHistory;

  String get noNotificationsYet;

  String get history;

  String get vaccineCertificate;

  String get backupRestore;

  String get settings;

  String get aboutApp;

  String get helpSupport;

  String get privacyPolicy;

  String get language;

  String get english;

  String get sinhala;

  String get tamil;

  String get darkMode;

  String get notifications;

  String get reminderTime;

  String get versionLabel;

  String get goodEvening;

  String get ammaGreeting;

  String get dateOfBirth;

  String dobShort(String date);

  String get gender;

  String get female;

  String get male;

  String get bloodGroup;

  String get birthWeight;

  String get birthWeightKg;

  String get hospital;

  String get basicDetails;

  String get additionalDetailsOptional;

  String get babyName;

  String get addBaby;

  String get editBaby;

  String get saveBaby;

  String get updateBaby;

  String get selectDate;

  String get selectDateOfBirth;

  String get pleaseSelectDob;

  String get pleaseEnterName;

  String somethingWentWrong(String error);

  String get noBabyAddedYet;

  String get noBabyAddedMessage;

  String get addYourBaby;

  String get babyProfileNotFound;

  String photoSaveFailed(String error);

  String get viewGrowthChart;

  String dayCount(int count);

  String monthCount(int count);

  String yearCount(int count);

  String get pending;

  String get completed;

  String get overdue;

  String get upcoming;

  String get missed;

  String get all;

  String markedAsDone(String name);

  String get dueDate;

  String due(String date);

  String get status;

  String get markAsDone;

  String get noVaccinesInCategory;

  String get overallProgress;

  String get vaccineProgress;

  String get noVaccineRecordsYet;

  String get todaysReminder;

  String vaccineOverdueMessage(String name);

  String get visitClinicSoon;

  String get nextVaccine;

  String get seeAll;

  String get vaccineDetails;

  String get purpose;

  String get possibleSideEffects;

  String get advice;

  String get reminder;

  String get overdueAdvice;

  String get addReminder;

  String get reminderTitle;

  String get reminderHint;

  String get date;

  String get saveReminder;

  String get upcomingEvents;

  String get noEventsYet;

  String get required;

  String get invalidNumber;

  String get addGrowthEntry;

  String get weight;

  String get height;

  String get bmi;

  String get weightKg;

  String get heightCm;

  String get saveEntry;

  String get growthChart;

  String get noGrowthRecordsYet;

  String get allEntries;

  String get backupNow;

  String get restoreFromBackup;

  String get previousBackups;

  String get restoreConfirm;

  String get restoreConfirmMessage;

  String get cancel;

  String get restore;

  String backupSuccess(String path);

  String backupFailed(String error);

  String get restoreSuccess;

  String restoreFailed(String error);

  String get noBackupsYet;

  String get name;

  String get fullName;

  String get nic;

  String get phone;

  String get address;

  String get mohArea;

  String get mohAreaHint;

  String get nearestClinic;

  String get editProfile;

  String get profileUpdated;

  String get save;

  String get setUpYourProfile;

  String get motherSetupMessage;

  String get saveProfile;

  String get nationalEmergencyNumbers;

  String get myEmergencyContacts;

  String get addEmergencyContact;

  String get saveContact;

  String get relationHint;

  String get removeContactQuestion;

  String removeContactMessage(String name);

  String get remove;

  String get couldNotOpenDialer;

  String get couldNotOpenMaps;

  String get couldNotOpenEmail;

  String get noPersonalContacts;

  String get mohNotFoundTitle;

  String get mohNotFoundMessage;

  String distanceKm(String distance);

  String get nextClinicDate;

  String get workingHours;

  String get call;

  String get map;

  String get directions;

  String get childImmunizationCertificate;

  String get noBabyProfileFound;

  String get addBabyForCertificate;

  String bornOn(String gender, String date);

  String bloodGroupValue(String bloodGroup);

  String bornAt(String hospital);

  String get noVaccinesCompletedYet;

  String vaccineDose(String name, int dose);

  String givenOn(String date);

  String vaccinesCompletedCount(int count);

  String pendingCount(int count);

  String get certificateDisclaimer;

  String get aboutBody;

  String get privacyBody;

  String get helpBody;

  String get emailSupport;

  String get vaccineRemindersEnabled;

  String get vaccineRemindersOff;

  String get careTagline;

  String get versionShort;

  String get january;

  String get february;

  String get march;

  String get april;

  String get may;

  String get june;

  String get july;

  String get august;

  String get september;

  String get october;

  String get november;

  String get december;

  String get sun;

  String get mon;

  String get tue;

  String get wed;

  String get thu;

  String get fri;

  String get sat;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
