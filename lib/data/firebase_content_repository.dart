import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/baby.dart';
import '../models/emergency_contact.dart';
import '../models/growth_record.dart';
import '../models/moh_clinic.dart';
import '../models/mother.dart';
import '../models/parenting_tip.dart';
import '../models/reminder.dart';
import '../models/vaccine.dart';
import '../utils/app_language.dart';
import '../utils/firebase_service.dart';

class LocalizedText {
  final String en;
  final String si;
  final String ta;

  const LocalizedText({required this.en, required this.si, required this.ta});

  factory LocalizedText.fromMap(Map<String, dynamic>? map) {
    return LocalizedText(
      en: map?['en'] as String? ?? '',
      si: map?['si'] as String? ?? map?['en'] as String? ?? '',
      ta: map?['ta'] as String? ?? map?['en'] as String? ?? '',
    );
  }

  String get current {
    switch (AppLanguage.current) {
      case 'si':
        return si.isEmpty ? en : si;
      case 'ta':
        return ta.isEmpty ? en : ta;
      default:
        return en;
    }
  }
}

class FirebaseVaccineItem {
  final String id;
  final LocalizedText name;
  final int doseNumber;
  final int ageInDays;
  final LocalizedText ageLabel;
  final bool femaleOnly;
  final LocalizedText description;
  final int order;

  const FirebaseVaccineItem({
    required this.id,
    required this.name,
    required this.doseNumber,
    required this.ageInDays,
    required this.ageLabel,
    required this.femaleOnly,
    required this.description,
    required this.order,
  });

  factory FirebaseVaccineItem.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return FirebaseVaccineItem(
      id: doc.id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      doseNumber: data['doseNumber'] as int? ?? 1,
      ageInDays: data['ageInDays'] as int? ?? 0,
      ageLabel: LocalizedText.fromMap(
        data['ageLabel'] as Map<String, dynamic>?,
      ),
      femaleOnly: data['femaleOnly'] as bool? ?? false,
      description: LocalizedText.fromMap(
        data['description'] as Map<String, dynamic>?,
      ),
      order: data['order'] as int? ?? 0,
    );
  }
}

class FirebaseVaccineInfo {
  final String id;
  final LocalizedText purpose;
  final List<LocalizedText> sideEffects;
  final LocalizedText advice;

  const FirebaseVaccineInfo({
    required this.id,
    required this.purpose,
    required this.sideEffects,
    required this.advice,
  });

  factory FirebaseVaccineInfo.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final rawEffects = data['sideEffects'] as List<dynamic>? ?? const [];
    return FirebaseVaccineInfo(
      id: doc.id,
      purpose: LocalizedText.fromMap(data['purpose'] as Map<String, dynamic>?),
      sideEffects: rawEffects
          .map((item) => LocalizedText.fromMap(item as Map<String, dynamic>?))
          .toList(),
      advice: LocalizedText.fromMap(data['advice'] as Map<String, dynamic>?),
    );
  }
}

class FirebaseContentRepository {
  FirebaseContentRepository._();

  static FirebaseFirestore? get _db =>
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  static DocumentReference<Map<String, dynamic>>? get _userDoc {
    final db = _db;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (db == null || uid == null) return null;
    return db.collection('users').doc(uid);
  }

  static Future<void> saveUserAccount({String? displayName}) async {
    final userDoc = _userDoc;
    final user = FirebaseAuth.instance.currentUser;
    if (userDoc == null || user == null) return;

    await userDoc.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': displayName?.trim().isNotEmpty == true
          ? displayName!.trim()
          : user.displayName,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<List<FirebaseVaccineItem>> getVaccineSchedule({
    required String gender,
  }) async {
    final db = _db;
    if (db == null) return _localVaccineSchedule(gender);

    try {
      final snapshot = await db
          .collection('vaccine_schedule')
          .orderBy('order')
          .get();
      final items = snapshot.docs.map(FirebaseVaccineItem.fromDoc).toList();
      if (items.isEmpty) return _localVaccineSchedule(gender);
      return _filterByGender(items, gender);
    } catch (_) {
      return _localVaccineSchedule(gender);
    }
  }

  static DateTime getDueDate(DateTime dob, FirebaseVaccineItem vaccine) {
    return dob.add(Duration(days: vaccine.ageInDays));
  }

  static Future<FirebaseVaccineInfo?> getVaccineInfo(String vaccineCode) async {
    final db = _db;
    if (db == null) return null;

    try {
      final doc = await db
          .collection('vaccine_info')
          .doc(_infoKey(vaccineCode))
          .get();
      if (!doc.exists) return null;
      return FirebaseVaccineInfo.fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  static Future<List<ParentingTipCategory>> getParentingTips() async {
    final db = _db;
    if (db == null) return const [];

    try {
      final snapshot = await db
          .collection('parenting_tip_categories')
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final rawTips = data['tips'] as List<dynamic>? ?? const [];
        return ParentingTipCategory(
          title: LocalizedText.fromMap(
            data['title'] as Map<String, dynamic>?,
          ).current,
          icon: _materialIconFromCodePoint(data['icon'] as int?),
          tips: rawTips
              .map(
                (tip) =>
                    LocalizedText.fromMap(tip as Map<String, dynamic>?).current,
              )
              .toList(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<MohClinic?> findMohClinic(String mohArea) async {
    final db = _db;
    final normalized = mohArea.trim().toLowerCase();
    if (db == null || normalized.isEmpty) return null;

    try {
      final exact = await db.collection('moh_clinics').doc(normalized).get();
      if (exact.exists) return _clinicFromMap(exact.data()!);

      final all = await db.collection('moh_clinics').get();
      for (final doc in all.docs) {
        final clinic = _clinicFromMap(doc.data());
        if (normalized.contains(clinic.mohArea.toLowerCase())) return clinic;
      }
    } catch (_) {}

    return null;
  }

  static Future<List<MohClinic>> getMohClinics() async {
    final db = _db;
    if (db == null) return const [];

    try {
      final snapshot = await db.collection('moh_clinics').get();
      final clinics = snapshot.docs
          .map((doc) => _clinicFromMap(doc.data()))
          .toList();
      clinics.sort((a, b) => a.mohArea.compareTo(b.mohArea));
      return clinics;
    } catch (_) {
      return const [];
    }
  }

  static Future<void> saveBaby(Baby baby) async {
    final userDoc = _userDoc;
    if (userDoc == null || baby.id == null) return;
    await userDoc.collection('babies').doc('${baby.id}').set(baby.toMap());
  }

  static Future<void> deleteBaby(int babyId) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('babies').doc('$babyId').delete();

    final vaccines = await userDoc
        .collection('vaccines')
        .where('babyId', isEqualTo: babyId)
        .get();
    for (final doc in vaccines.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> saveMother(Mother mother) async {
    final userDoc = _userDoc;
    if (userDoc == null || mother.id == null) return;
    await userDoc.collection('mothers').doc('${mother.id}').set(mother.toMap());
  }

  static Future<void> deleteMother(int id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('mothers').doc('$id').delete();
  }

  static Future<void> saveVaccine(Vaccine vaccine) async {
    final userDoc = _userDoc;
    if (userDoc == null || vaccine.id == null) return;
    await userDoc
        .collection('vaccines')
        .doc('${vaccine.id}')
        .set(vaccine.toMap());
  }

  static Future<void> updateVaccineStatus({
    required int vaccineId,
    required String status,
    required DateTime? completedDate,
  }) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('vaccines').doc('$vaccineId').set({
      'id': vaccineId,
      'status': status,
      'completedDate': completedDate?.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> saveEmergencyContact(EmergencyContact contact) async {
    final userDoc = _userDoc;
    if (userDoc == null || contact.id == null) return;
    await userDoc
        .collection('emergency_contacts')
        .doc('${contact.id}')
        .set(contact.toMap());
  }

  static Future<void> deleteEmergencyContact(int id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('emergency_contacts').doc('$id').delete();
  }

  static Future<void> saveGrowthRecord(GrowthRecord record) async {
    final userDoc = _userDoc;
    if (userDoc == null || record.id == null) return;
    await userDoc
        .collection('growth_records')
        .doc('${record.id}')
        .set(record.toMap());
  }

  static Future<void> deleteGrowthRecord(int id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('growth_records').doc('$id').delete();
  }

  static Future<void> saveReminder(Reminder reminder) async {
    final userDoc = _userDoc;
    if (userDoc == null || reminder.id == null) return;
    await userDoc
        .collection('reminders')
        .doc('${reminder.id}')
        .set(reminder.toMap());
  }

  static Future<void> deleteReminder(int id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('reminders').doc('$id').delete();
  }

  static Future<void> saveNotificationHistory({
    required int id,
    required int? babyId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('notification_history').doc('$id').set({
      'id': id,
      'babyId': babyId,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
    });
  }

  static Future<void> deleteUpcomingNotificationHistory() async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final now = DateTime.now().toIso8601String();
    final snapshot = await userDoc
        .collection('notification_history')
        .where('scheduledDate', isGreaterThan: now)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Future<Baby?> fetchBaby(int id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    try {
      final doc = await userDoc.collection('babies').doc('$id').get();
      if (!doc.exists) return null;
      return Baby.fromMap({...doc.data()!, 'id': id});
    } catch (_) {
      return null;
    }
  }

  static Future<Mother?> fetchMother(int id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    try {
      final doc = await userDoc.collection('mothers').doc('$id').get();
      if (!doc.exists) return null;
      return Mother.fromMap({...doc.data()!, 'id': id});
    } catch (_) {
      return null;
    }
  }

  static Future<Baby?> fetchFirstBaby() async {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    try {
      final snapshot = await userDoc.collection('babies').limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return Baby.fromMap({...doc.data(), 'id': int.tryParse(doc.id)});
    } catch (_) {
      return null;
    }
  }

  static Future<Mother?> fetchFirstMother() async {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    try {
      final snapshot = await userDoc.collection('mothers').limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return Mother.fromMap({...doc.data(), 'id': int.tryParse(doc.id)});
    } catch (_) {
      return null;
    }
  }

  static List<FirebaseVaccineItem> _filterByGender(
    List<FirebaseVaccineItem> items,
    String gender,
  ) {
    if (gender.toLowerCase() == 'male') {
      return items.where((v) => !v.femaleOnly).toList();
    }
    return items;
  }

  static IconData _materialIconFromCodePoint(int? codePoint) {
    switch (codePoint) {
      case 0xe25a:
        return Icons.child_care_rounded;
      case 0xe3f1:
        return Icons.favorite_rounded;
      case 0xf055f:
        return Icons.health_and_safety_rounded;
      case 0xe3f3:
        return Icons.local_hospital_rounded;
      case 0xf05a6:
        return Icons.vaccines_rounded;
      case 0xe56c:
        return Icons.restaurant_rounded;
      case 0xe549:
        return Icons.bedtime_rounded;
      case 0xf07f1:
        return Icons.tips_and_updates_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  static List<FirebaseVaccineItem> _localVaccineSchedule(String gender) {
    return _filterByGender(const [
      FirebaseVaccineItem(
        id: 'bcg',
        name: LocalizedText(en: 'BCG', si: 'BCG', ta: 'BCG'),
        doseNumber: 1,
        ageInDays: 0,
        ageLabel: LocalizedText(en: 'At birth', si: 'At birth', ta: 'At birth'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 1,
      ),
      FirebaseVaccineItem(
        id: 'opv_0',
        name: LocalizedText(en: 'OPV 0', si: 'OPV 0', ta: 'OPV 0'),
        doseNumber: 0,
        ageInDays: 0,
        ageLabel: LocalizedText(en: 'At birth', si: 'At birth', ta: 'At birth'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 2,
      ),
      FirebaseVaccineItem(
        id: 'pentavalent_1',
        name: LocalizedText(
          en: 'Pentavalent 1',
          si: 'Pentavalent 1',
          ta: 'Pentavalent 1',
        ),
        doseNumber: 1,
        ageInDays: 60,
        ageLabel: LocalizedText(en: '2 months', si: '2 months', ta: '2 months'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 3,
      ),
      FirebaseVaccineItem(
        id: 'opv_1',
        name: LocalizedText(en: 'OPV 1', si: 'OPV 1', ta: 'OPV 1'),
        doseNumber: 1,
        ageInDays: 60,
        ageLabel: LocalizedText(en: '2 months', si: '2 months', ta: '2 months'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 4,
      ),
      FirebaseVaccineItem(
        id: 'fipv_1',
        name: LocalizedText(en: 'fIPV 1', si: 'fIPV 1', ta: 'fIPV 1'),
        doseNumber: 1,
        ageInDays: 60,
        ageLabel: LocalizedText(en: '2 months', si: '2 months', ta: '2 months'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 5,
      ),
      FirebaseVaccineItem(
        id: 'pentavalent_2',
        name: LocalizedText(
          en: 'Pentavalent 2',
          si: 'Pentavalent 2',
          ta: 'Pentavalent 2',
        ),
        doseNumber: 2,
        ageInDays: 120,
        ageLabel: LocalizedText(en: '4 months', si: '4 months', ta: '4 months'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 6,
      ),
      FirebaseVaccineItem(
        id: 'opv_2',
        name: LocalizedText(en: 'OPV 2', si: 'OPV 2', ta: 'OPV 2'),
        doseNumber: 2,
        ageInDays: 120,
        ageLabel: LocalizedText(en: '4 months', si: '4 months', ta: '4 months'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 7,
      ),
      FirebaseVaccineItem(
        id: 'fipv_2',
        name: LocalizedText(en: 'fIPV 2', si: 'fIPV 2', ta: 'fIPV 2'),
        doseNumber: 2,
        ageInDays: 120,
        ageLabel: LocalizedText(en: '4 months', si: '4 months', ta: '4 months'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 8,
      ),
      FirebaseVaccineItem(
        id: 'pentavalent_3',
        name: LocalizedText(
          en: 'Pentavalent 3',
          si: 'Pentavalent 3',
          ta: 'Pentavalent 3',
        ),
        doseNumber: 3,
        ageInDays: 180,
        ageLabel: LocalizedText(en: '6 months', si: '6 months', ta: '6 months'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 9,
      ),
      FirebaseVaccineItem(
        id: 'opv_3',
        name: LocalizedText(en: 'OPV 3', si: 'OPV 3', ta: 'OPV 3'),
        doseNumber: 3,
        ageInDays: 180,
        ageLabel: LocalizedText(en: '6 months', si: '6 months', ta: '6 months'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 10,
      ),
      FirebaseVaccineItem(
        id: 'mmr_1',
        name: LocalizedText(en: 'MMR 1', si: 'MMR 1', ta: 'MMR 1'),
        doseNumber: 1,
        ageInDays: 270,
        ageLabel: LocalizedText(en: '9 months', si: '9 months', ta: '9 months'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 11,
      ),
      FirebaseVaccineItem(
        id: 'je',
        name: LocalizedText(en: 'JE', si: 'JE', ta: 'JE'),
        doseNumber: 1,
        ageInDays: 365,
        ageLabel: LocalizedText(en: '1 year', si: '1 year', ta: '1 year'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 12,
      ),
      FirebaseVaccineItem(
        id: 'mmr_2',
        name: LocalizedText(en: 'MMR 2', si: 'MMR 2', ta: 'MMR 2'),
        doseNumber: 2,
        ageInDays: 1095,
        ageLabel: LocalizedText(en: '3 years', si: '3 years', ta: '3 years'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 13,
      ),
      FirebaseVaccineItem(
        id: 'dpt_1',
        name: LocalizedText(en: 'DPT 1', si: 'DPT 1', ta: 'DPT 1'),
        doseNumber: 1,
        ageInDays: 1825,
        ageLabel: LocalizedText(en: '5 years', si: '5 years', ta: '5 years'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 14,
      ),
      FirebaseVaccineItem(
        id: 'opv_4',
        name: LocalizedText(en: 'OPV 4', si: 'OPV 4', ta: 'OPV 4'),
        doseNumber: 4,
        ageInDays: 1825,
        ageLabel: LocalizedText(en: '5 years', si: '5 years', ta: '5 years'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 15,
      ),
      FirebaseVaccineItem(
        id: 'hpv_1',
        name: LocalizedText(en: 'HPV 1', si: 'HPV 1', ta: 'HPV 1'),
        doseNumber: 1,
        ageInDays: 3650,
        ageLabel: LocalizedText(en: '10 years', si: '10 years', ta: '10 years'),
        femaleOnly: true,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 16,
      ),
      FirebaseVaccineItem(
        id: 'hpv_2',
        name: LocalizedText(en: 'HPV 2', si: 'HPV 2', ta: 'HPV 2'),
        doseNumber: 2,
        ageInDays: 3830,
        ageLabel: LocalizedText(en: '10 years', si: '10 years', ta: '10 years'),
        femaleOnly: true,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 17,
      ),
      FirebaseVaccineItem(
        id: 'atd',
        name: LocalizedText(en: 'aTd', si: 'aTd', ta: 'aTd'),
        doseNumber: 1,
        ageInDays: 4015,
        ageLabel: LocalizedText(en: '11 years', si: '11 years', ta: '11 years'),
        femaleOnly: false,
        description: LocalizedText(en: '', si: '', ta: ''),
        order: 18,
      ),
    ], gender);
  }

  static String _infoKey(String rawCode) {
    final code = rawCode.toLowerCase().replaceAll(' ', '_');
    if (code.startsWith('penta') || code.startsWith('pentavalent')) {
      return 'penta';
    }
    if (code.startsWith('opv')) return 'opv';
    if (code.startsWith('fipv')) return 'fipv';
    if (code.startsWith('mmr')) return 'mmr';
    if (code.contains('je')) return 'je';
    if (code.startsWith('dpt')) return 'dpt';
    if (code == 'dt') return 'dt';
    if (code.startsWith('hpv')) return 'hpv';
    if (code == 'atd') return 'atd';
    return code.replaceAll(RegExp(r'\d+$'), '');
  }

  static MohClinic _clinicFromMap(Map<String, dynamic> data) {
    final rawDate = data['nextClinicDate'];
    return MohClinic(
      mohArea: data['mohArea'] as String? ?? '',
      name: data['name'] as String? ?? '',
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0,
      nextClinicDate: rawDate is Timestamp
          ? rawDate.toDate()
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      phone: data['phone'] as String? ?? '',
      workingHours: data['workingHours'] as String? ?? '',
      address: data['address'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
    );
  }
}
