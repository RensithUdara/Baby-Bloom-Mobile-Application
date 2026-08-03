// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appName => 'BabyBloom';

  @override
  String get home => 'Home';

  @override
  String get vaccines => 'Vaccines';

  @override
  String get calendar => 'Calendar';

  @override
  String get progress => 'Progress';

  @override
  String get more => 'More';

  @override
  String get babyProfile => 'Baby Profile';

  @override
  String get motherProfile => 'Mother Profile';

  @override
  String get mohClinic => 'MOH Clinic';

  @override
  String get mohClinicDetails => 'MOH Clinic Details';

  @override
  String get parentingTips => 'Parenting Tips';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String get notificationHistory => 'Notification History';

  @override
  String get noNotificationsYet => 'No notifications yet.';

  @override
  String get history => 'History';

  @override
  String get vaccineCertificate => 'Vaccine Certificate';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get settings => 'Settings';

  @override
  String get aboutApp => 'About App';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'Sinhala';

  @override
  String get tamil => 'Tamil';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get versionLabel => 'Version 1.0.0';

  @override
  String get goodEvening => 'Good Evening,';

  @override
  String get ammaGreeting => 'Amma';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String dobShort(String date) {
    return 'DOB: $date';
  }

  @override
  String get gender => 'Gender';

  @override
  String get female => 'Female';

  @override
  String get male => 'Male';

  @override
  String get bloodGroup => 'Blood Group';

  @override
  String get birthWeight => 'Birth Weight';

  @override
  String get birthWeightKg => 'Birth Weight (kg)';

  @override
  String get hospital => 'Hospital';

  @override
  String get basicDetails => 'Basic Details';

  @override
  String get additionalDetailsOptional => 'Additional Details (Optional)';

  @override
  String get babyName => 'Baby\'s Name';

  @override
  String get addBaby => 'Add Baby';

  @override
  String get editBaby => 'Edit Baby';

  @override
  String get saveBaby => 'Save Baby';

  @override
  String get updateBaby => 'Update Baby';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectDateOfBirth => 'Select Date of Birth';

  @override
  String get pleaseSelectDob => 'Please select date of birth';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String somethingWentWrong(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String get noBabyAddedYet => 'No baby added yet';

  @override
  String get noBabyAddedMessage =>
      'Add your baby\'s details to start tracking vaccines and reminders.';

  @override
  String get addYourBaby => 'Add Your Baby';

  @override
  String get babyProfileNotFound => 'Baby profile not found';

  @override
  String get deleteBaby => 'බබා ඉවත් කරන්න';

  @override
  String get deleteBabyTitle => 'බබාගේ පැතිකඩ ඉවත් කරන්නද?';

  @override
  String deleteBabyMessage(String name) {
    return '$nameගේ පැතිකඩ, එන්නත් වාර්තා, මතක් කිරීම් සහ වර්ධන වාර්තා ඉවත් කරන්නද? මෙම ක්‍රියාව නැවත හැරවිය නොහැක.';
  }

  @override
  String babyDeleted(String name) {
    return '$nameගේ පැතිකඩ ඉවත් කරන ලදී';
  }

  @override
  String photoSaveFailed(String error) {
    return 'Could not save photo: $error';
  }

  @override
  String get viewGrowthChart => 'View Growth Chart';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Days',
      one: '1 Day',
    );
    return '$_temp0';
  }

  @override
  String monthCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Months',
      one: '1 Month',
    );
    return '$_temp0';
  }

  @override
  String yearCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Years',
      one: '1 Year',
    );
    return '$_temp0';
  }

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get overdue => 'Overdue';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get missed => 'Missed';

  @override
  String get all => 'All';

  @override
  String markedAsDone(String name) {
    return '$name marked as done';
  }

  @override
  String get confirmMarkVaccineDoneTitle =>
      'එන්නත සම්පූර්ණ කළ ලෙස සලකුණු කරන්නද?';

  @override
  String confirmMarkVaccineDoneMessage(String name) {
    return '$name එන්නත බබාට ලැබී ඇති බව ඔබට විශ්වාසද? මෙම ක්‍රියාව නැවත හැරවිය නොහැක.';
  }

  @override
  String get confirmMarkDone => 'සම්පූර්ණයි';

  @override
  String get deleteVaccineTitle => 'එන්නත ඉවත් කරන්නද?';

  @override
  String deleteVaccineMessage(String name) {
    return 'මෙම බබාගේ එන්නත් ලැයිස්තුවෙන් $name ඉවත් කරන්නද? මෙහි මතක් කිරීම්ද ඉවත් වේ.';
  }

  @override
  String get deleteVaccine => 'එන්නත ඉවත් කරන්න';

  @override
  String get dueDate => 'Due Date';

  @override
  String due(String date) {
    return 'Due: $date';
  }

  @override
  String get status => 'Status';

  @override
  String get markAsDone => 'Mark as Done';

  @override
  String get noVaccinesInCategory => 'No vaccines in this category';

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get vaccineProgress => 'Vaccine Progress';

  @override
  String get noVaccineRecordsYet => 'No vaccine records yet';

  @override
  String get todaysReminder => 'Today\'s Reminder';

  @override
  String vaccineOverdueMessage(String name) {
    return '$name is overdue.';
  }

  @override
  String get visitClinicSoon => 'Please visit the clinic as soon as possible.';

  @override
  String get nextVaccine => 'Next Vaccine';

  @override
  String get seeAll => 'See All';

  @override
  String get vaccineDetails => 'Vaccine Details';

  @override
  String get purpose => 'Purpose';

  @override
  String get possibleSideEffects => 'Possible Side Effects';

  @override
  String get advice => 'Advice';

  @override
  String get reminder => 'Reminder';

  @override
  String get overdueAdvice =>
      'This vaccine is overdue. Please visit the clinic as soon as possible.';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get reminderTitle => 'Reminder title';

  @override
  String get reminderHint => 'e.g. Doctor appointment';

  @override
  String get date => 'Date';

  @override
  String get saveReminder => 'Save Reminder';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get noEventsYet => 'No events yet';

  @override
  String get required => 'Required';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get addGrowthEntry => 'Add Growth Entry';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get bmi => 'BMI';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get saveEntry => 'Save Entry';

  @override
  String get growthChart => 'Growth Chart';

  @override
  String get noGrowthRecordsYet =>
      'No growth records yet.\nTap + to add the first entry.';

  @override
  String get allEntries => 'All Entries';

  @override
  String get backupNow => 'Backup Now';

  @override
  String get restoreFromBackup => 'Restore from Backup';

  @override
  String get previousBackups => 'Previous Backups';

  @override
  String get restoreConfirm => 'Restore Confirm';

  @override
  String get restoreConfirmMessage =>
      'Your current data will be replaced with the selected backup file. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get restore => 'Restore';

  @override
  String backupSuccess(String path) {
    return 'Backup successful!\n$path';
  }

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get restoreSuccess => 'Restore successful! Please restart the app.';

  @override
  String restoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get noBackupsYet => 'No backups yet';

  @override
  String get name => 'Name';

  @override
  String get fullName => 'Full Name';

  @override
  String get nic => 'NIC';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get mohArea => 'MOH Area';

  @override
  String get mohAreaHint => 'MOH Area (eg: Colombo, Kandy, Badulla)';

  @override
  String get nearestClinic => 'Nearest Clinic';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get save => 'Save';

  @override
  String get setUpYourProfile => 'Set up your profile';

  @override
  String get motherSetupMessage =>
      'Enter your details so we can show your nearest MOH clinic.';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get nationalEmergencyNumbers => 'National Emergency Numbers';

  @override
  String get myEmergencyContacts => 'My Emergency Contacts';

  @override
  String get addEmergencyContact => 'Add Emergency Contact';

  @override
  String get saveContact => 'Save Contact';

  @override
  String get relationHint => 'Relation (eg: Husband, Doctor)';

  @override
  String get removeContactQuestion => 'Remove contact?';

  @override
  String removeContactMessage(String name) {
    return 'Remove $name from your emergency contacts?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get couldNotOpenDialer => 'Could not open dialer';

  @override
  String get couldNotOpenMaps => 'Could not open maps';

  @override
  String get couldNotOpenEmail => 'Could not open email app';

  @override
  String get noPersonalContacts =>
      'No personal contacts added yet. Tap + to add family, doctor, or midwife numbers.';

  @override
  String get mohNotFoundTitle =>
      'Your MOH area clinic details are not available yet.';

  @override
  String get mohNotFoundMessage =>
      'Please check your MOH Area in Mother Profile, or contact your local health office.';

  @override
  String distanceKm(String distance) {
    return 'Distance: $distance km';
  }

  @override
  String get nextClinicDate => 'Next Clinic Date';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get call => 'Call';

  @override
  String get map => 'Map';

  @override
  String get directions => 'Directions';

  @override
  String get childImmunizationCertificate => 'Child Immunization Certificate';

  @override
  String get noBabyProfileFound => 'No baby profile found yet.';

  @override
  String get addBabyForCertificate =>
      'Add your baby\'s profile first to generate a vaccine certificate.';

  @override
  String bornOn(String gender, String date) {
    return '$gender • Born $date';
  }

  @override
  String bloodGroupValue(String bloodGroup) {
    return 'Blood group: $bloodGroup';
  }

  @override
  String bornAt(String hospital) {
    return 'Born at: $hospital';
  }

  @override
  String get noVaccinesCompletedYet => 'No vaccines completed yet.';

  @override
  String vaccineDose(String name, int dose) {
    return '$name — Dose $dose';
  }

  @override
  String givenOn(String date) {
    return 'Given on $date';
  }

  @override
  String vaccinesCompletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vaccines completed',
      one: '1 vaccine completed',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    return '$count pending';
  }

  @override
  String get certificateDisclaimer =>
      'This certificate is generated from records entered in this app. Please carry your official MOH child health record book for clinic visits.';

  @override
  String get aboutBody =>
      'BabyBloom is an app that helps parents in Sri Lanka track their child\'s health records and receive vaccine reminders based on the official MOH (Ministry of Health) immunization schedule.\n\nThe app allows you to keep track of your baby\'s growth, vaccination progress, mother\'s health details, and important emergency contacts — all in one place, right on your phone.';

  @override
  String get privacyBody =>
      'All data you enter into BabyBloom — including baby profiles, mother profiles, and vaccination records — is stored locally on your phone only.\n\nThis app does not upload, share, or transmit your data to any server. Your information stays private and fully under your control, on your own device.';

  @override
  String get helpBody =>
      'Need help with the app, found a bug, or have a suggestion? We\'d love to hear from you.';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get vaccineRemindersEnabled => 'Vaccine reminders enabled';

  @override
  String get vaccineRemindersOff => 'Vaccine reminders turned off';

  @override
  String get careTagline => 'Care for Every Mother\nProtect Every Child';

  @override
  String get versionShort => 'Version 1.0';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get sun => 'Sun';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';
}
