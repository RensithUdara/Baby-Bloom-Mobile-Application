import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/baby.dart';
import '../models/moh_clinic.dart';
import '../models/mother.dart';
import '../models/parenting_tip.dart';
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

  static Future<List<FirebaseVaccineItem>> getVaccineSchedule({
    required String gender,
  }) async {
    final db = _db;
    if (db == null) return const [];

    try {
      final snapshot = await db
          .collection('vaccine_schedule')
          .orderBy('order')
          .get();
      final items = snapshot.docs.map(FirebaseVaccineItem.fromDoc).toList();
      return _filterByGender(items, gender);
    } catch (_) {
      return const [];
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
          icon: IconData(
            data['icon'] as int? ?? Icons.favorite_rounded.codePoint,
            fontFamily: 'MaterialIcons',
          ),
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

  static Future<void> saveBaby(Baby baby) async {
    final userDoc = _userDoc;
    if (userDoc == null || baby.id == null) return;
    await userDoc.collection('babies').doc('${baby.id}').set(baby.toMap());
  }

  static Future<void> saveMother(Mother mother) async {
    final userDoc = _userDoc;
    if (userDoc == null || mother.id == null) return;
    await userDoc.collection('mothers').doc('${mother.id}').set(mother.toMap());
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
