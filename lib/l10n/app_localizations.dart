import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BabyBloom'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @vaccines.
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get vaccines;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @babyProfile.
  ///
  /// In en, this message translates to:
  /// **'Baby Profile'**
  String get babyProfile;

  /// No description provided for @motherProfile.
  ///
  /// In en, this message translates to:
  /// **'Mother Profile'**
  String get motherProfile;

  /// No description provided for @mohClinic.
  ///
  /// In en, this message translates to:
  /// **'MOH Clinic'**
  String get mohClinic;

  /// No description provided for @mohClinicDetails.
  ///
  /// In en, this message translates to:
  /// **'MOH Clinic Details'**
  String get mohClinicDetails;

  /// No description provided for @parentingTips.
  ///
  /// In en, this message translates to:
  /// **'Parenting Tips'**
  String get parentingTips;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @notificationHistory.
  ///
  /// In en, this message translates to:
  /// **'Notification History'**
  String get notificationHistory;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @vaccineCertificate.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Certificate'**
  String get vaccineCertificate;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @sinhala.
  ///
  /// In en, this message translates to:
  /// **'Sinhala'**
  String get sinhala;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get versionLabel;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening,'**
  String get goodEvening;

  /// No description provided for @ammaGreeting.
  ///
  /// In en, this message translates to:
  /// **'Amma'**
  String get ammaGreeting;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @dobShort.
  ///
  /// In en, this message translates to:
  /// **'DOB: {date}'**
  String dobShort(String date);

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @birthWeight.
  ///
  /// In en, this message translates to:
  /// **'Birth Weight'**
  String get birthWeight;

  /// No description provided for @birthWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Birth Weight (kg)'**
  String get birthWeightKg;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @basicDetails.
  ///
  /// In en, this message translates to:
  /// **'Basic Details'**
  String get basicDetails;

  /// No description provided for @additionalDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional Details (Optional)'**
  String get additionalDetailsOptional;

  /// No description provided for @babyName.
  ///
  /// In en, this message translates to:
  /// **'Baby\'s Name'**
  String get babyName;

  /// No description provided for @addBaby.
  ///
  /// In en, this message translates to:
  /// **'Add Baby'**
  String get addBaby;

  /// No description provided for @editBaby.
  ///
  /// In en, this message translates to:
  /// **'Edit Baby'**
  String get editBaby;

  /// No description provided for @saveBaby.
  ///
  /// In en, this message translates to:
  /// **'Save Baby'**
  String get saveBaby;

  /// No description provided for @updateBaby.
  ///
  /// In en, this message translates to:
  /// **'Update Baby'**
  String get updateBaby;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get selectDateOfBirth;

  /// No description provided for @pleaseSelectDob.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get pleaseSelectDob;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String somethingWentWrong(String error);

  /// No description provided for @noBabyAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No baby added yet'**
  String get noBabyAddedYet;

  /// No description provided for @noBabyAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your baby\'s details to start tracking vaccines and reminders.'**
  String get noBabyAddedMessage;

  /// No description provided for @addYourBaby.
  ///
  /// In en, this message translates to:
  /// **'Add Your Baby'**
  String get addYourBaby;

  /// No description provided for @babyProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Baby profile not found'**
  String get babyProfileNotFound;

  /// No description provided for @deleteBaby.
  ///
  /// In en, this message translates to:
  /// **'Delete Baby'**
  String get deleteBaby;

  /// No description provided for @deleteBabyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete baby profile?'**
  String get deleteBabyTitle;

  /// No description provided for @deleteBabyMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}\'s profile, vaccine records, reminders, and growth records? This action cannot be undone.'**
  String deleteBabyMessage(String name);

  /// No description provided for @babyDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s profile deleted'**
  String babyDeleted(String name);

  /// No description provided for @photoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save photo: {error}'**
  String photoSaveFailed(String error);

  /// No description provided for @viewGrowthChart.
  ///
  /// In en, this message translates to:
  /// **'View Growth Chart'**
  String get viewGrowthChart;

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 Day} other{{count} Days}}'**
  String dayCount(int count);

  /// No description provided for @monthCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 Month} other{{count} Months}}'**
  String monthCount(int count);

  /// No description provided for @yearCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 Year} other{{count} Years}}'**
  String yearCount(int count);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @markedAsDone.
  ///
  /// In en, this message translates to:
  /// **'{name} marked as done'**
  String markedAsDone(String name);

  /// No description provided for @confirmMarkVaccineDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark vaccine as done?'**
  String get confirmMarkVaccineDoneTitle;

  /// No description provided for @confirmMarkVaccineDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure {name} has received this vaccine? This action cannot be undone.'**
  String confirmMarkVaccineDoneMessage(String name);

  /// No description provided for @confirmMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark Done'**
  String get confirmMarkDone;

  /// No description provided for @deleteVaccineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete vaccine?'**
  String get deleteVaccineTitle;

  /// No description provided for @deleteVaccineMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} from this baby\'s vaccine list? This will also remove its reminders.'**
  String deleteVaccineMessage(String name);

  /// No description provided for @deleteVaccine.
  ///
  /// In en, this message translates to:
  /// **'Delete Vaccine'**
  String get deleteVaccine;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String due(String date);

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get markAsDone;

  /// No description provided for @noVaccinesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No vaccines in this category'**
  String get noVaccinesInCategory;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @vaccineProgress.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Progress'**
  String get vaccineProgress;

  /// No description provided for @noVaccineRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No vaccine records yet'**
  String get noVaccineRecordsYet;

  /// No description provided for @todaysReminder.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reminder'**
  String get todaysReminder;

  /// No description provided for @vaccineOverdueMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is overdue.'**
  String vaccineOverdueMessage(String name);

  /// No description provided for @visitClinicSoon.
  ///
  /// In en, this message translates to:
  /// **'Please visit the clinic as soon as possible.'**
  String get visitClinicSoon;

  /// No description provided for @nextVaccine.
  ///
  /// In en, this message translates to:
  /// **'Next Vaccine'**
  String get nextVaccine;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @vaccineDetails.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Details'**
  String get vaccineDetails;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @possibleSideEffects.
  ///
  /// In en, this message translates to:
  /// **'Possible Side Effects'**
  String get possibleSideEffects;

  /// No description provided for @advice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get advice;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @overdueAdvice.
  ///
  /// In en, this message translates to:
  /// **'This vaccine is overdue. Please visit the clinic as soon as possible.'**
  String get overdueAdvice;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder title'**
  String get reminderTitle;

  /// No description provided for @reminderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Doctor appointment'**
  String get reminderHint;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @saveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get saveReminder;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @addGrowthEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Growth Entry'**
  String get addGrowthEntry;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @saveEntry.
  ///
  /// In en, this message translates to:
  /// **'Save Entry'**
  String get saveEntry;

  /// No description provided for @growthChart.
  ///
  /// In en, this message translates to:
  /// **'Growth Chart'**
  String get growthChart;

  /// No description provided for @noGrowthRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No growth records yet.\nTap + to add the first entry.'**
  String get noGrowthRecordsYet;

  /// No description provided for @allEntries.
  ///
  /// In en, this message translates to:
  /// **'All Entries'**
  String get allEntries;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreFromBackup;

  /// No description provided for @previousBackups.
  ///
  /// In en, this message translates to:
  /// **'Previous Backups'**
  String get previousBackups;

  /// No description provided for @restoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore Confirm'**
  String get restoreConfirm;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current data will be replaced with the selected backup file. Continue?'**
  String get restoreConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup successful!\n{path}'**
  String backupSuccess(String path);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore successful! Please restart the app.'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(String error);

  /// No description provided for @noBackupsYet.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get noBackupsYet;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @nic.
  ///
  /// In en, this message translates to:
  /// **'NIC'**
  String get nic;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @mohArea.
  ///
  /// In en, this message translates to:
  /// **'MOH Area'**
  String get mohArea;

  /// No description provided for @mohAreaHint.
  ///
  /// In en, this message translates to:
  /// **'MOH Area (eg: Colombo, Kandy, Badulla)'**
  String get mohAreaHint;

  /// No description provided for @nearestClinic.
  ///
  /// In en, this message translates to:
  /// **'Nearest Clinic'**
  String get nearestClinic;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @setUpYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile'**
  String get setUpYourProfile;

  /// No description provided for @motherSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your details so we can show your nearest MOH clinic.'**
  String get motherSetupMessage;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @nationalEmergencyNumbers.
  ///
  /// In en, this message translates to:
  /// **'National Emergency Numbers'**
  String get nationalEmergencyNumbers;

  /// No description provided for @myEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'My Emergency Contacts'**
  String get myEmergencyContacts;

  /// No description provided for @addEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Add Emergency Contact'**
  String get addEmergencyContact;

  /// No description provided for @saveContact.
  ///
  /// In en, this message translates to:
  /// **'Save Contact'**
  String get saveContact;

  /// No description provided for @relationHint.
  ///
  /// In en, this message translates to:
  /// **'Relation (eg: Husband, Doctor)'**
  String get relationHint;

  /// No description provided for @removeContactQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove contact?'**
  String get removeContactQuestion;

  /// No description provided for @removeContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your emergency contacts?'**
  String removeContactMessage(String name);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @couldNotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not open dialer'**
  String get couldNotOpenDialer;

  /// No description provided for @couldNotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open maps'**
  String get couldNotOpenMaps;

  /// No description provided for @couldNotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get couldNotOpenEmail;

  /// No description provided for @noPersonalContacts.
  ///
  /// In en, this message translates to:
  /// **'No personal contacts added yet. Tap + to add family, doctor, or midwife numbers.'**
  String get noPersonalContacts;

  /// No description provided for @mohNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Your MOH area clinic details are not available yet.'**
  String get mohNotFoundTitle;

  /// No description provided for @mohNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your MOH Area in Mother Profile, or contact your local health office.'**
  String get mohNotFoundMessage;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance} km'**
  String distanceKm(String distance);

  /// No description provided for @nextClinicDate.
  ///
  /// In en, this message translates to:
  /// **'Next Clinic Date'**
  String get nextClinicDate;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @childImmunizationCertificate.
  ///
  /// In en, this message translates to:
  /// **'Child Immunization Certificate'**
  String get childImmunizationCertificate;

  /// No description provided for @noBabyProfileFound.
  ///
  /// In en, this message translates to:
  /// **'No baby profile found yet.'**
  String get noBabyProfileFound;

  /// No description provided for @addBabyForCertificate.
  ///
  /// In en, this message translates to:
  /// **'Add your baby\'s profile first to generate a vaccine certificate.'**
  String get addBabyForCertificate;

  /// No description provided for @bornOn.
  ///
  /// In en, this message translates to:
  /// **'{gender} • Born {date}'**
  String bornOn(String gender, String date);

  /// No description provided for @bloodGroupValue.
  ///
  /// In en, this message translates to:
  /// **'Blood group: {bloodGroup}'**
  String bloodGroupValue(String bloodGroup);

  /// No description provided for @bornAt.
  ///
  /// In en, this message translates to:
  /// **'Born at: {hospital}'**
  String bornAt(String hospital);

  /// No description provided for @noVaccinesCompletedYet.
  ///
  /// In en, this message translates to:
  /// **'No vaccines completed yet.'**
  String get noVaccinesCompletedYet;

  /// No description provided for @vaccineDose.
  ///
  /// In en, this message translates to:
  /// **'{name} — Dose {dose}'**
  String vaccineDose(String name, int dose);

  /// No description provided for @givenOn.
  ///
  /// In en, this message translates to:
  /// **'Given on {date}'**
  String givenOn(String date);

  /// No description provided for @vaccinesCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 vaccine completed} other{{count} vaccines completed}}'**
  String vaccinesCompletedCount(int count);

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String pendingCount(int count);

  /// No description provided for @certificateDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This certificate is generated from records entered in this app. Please carry your official MOH child health record book for clinic visits.'**
  String get certificateDisclaimer;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'BabyBloom is an app that helps parents in Sri Lanka track their child\'s health records and receive vaccine reminders based on the official MOH (Ministry of Health) immunization schedule.\n\nThe app allows you to keep track of your baby\'s growth, vaccination progress, mother\'s health details, and important emergency contacts — all in one place, right on your phone.'**
  String get aboutBody;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'All data you enter into BabyBloom — including baby profiles, mother profiles, and vaccination records — is stored locally on your phone only.\n\nThis app does not upload, share, or transmit your data to any server. Your information stays private and fully under your control, on your own device.'**
  String get privacyBody;

  /// No description provided for @helpBody.
  ///
  /// In en, this message translates to:
  /// **'Need help with the app, found a bug, or have a suggestion? We\'d love to hear from you.'**
  String get helpBody;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @vaccineRemindersEnabled.
  ///
  /// In en, this message translates to:
  /// **'Vaccine reminders enabled'**
  String get vaccineRemindersEnabled;

  /// No description provided for @vaccineRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Vaccine reminders turned off'**
  String get vaccineRemindersOff;

  /// No description provided for @careTagline.
  ///
  /// In en, this message translates to:
  /// **'Care for Every Mother\nProtect Every Child'**
  String get careTagline;

  /// No description provided for @versionShort.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get versionShort;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
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
  // Lookup logic when only language code is specified.
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
