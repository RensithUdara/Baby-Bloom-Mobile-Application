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

  Map<String, dynamic> toMap() => {'en': en, 'si': si, 'ta': ta};

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
    this.femaleOnly = false,
    this.description = const LocalizedText(en: '', si: '', ta: ''),
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

  Map<String, dynamic> toMap() => {
    'name': name.toMap(),
    'doseNumber': doseNumber,
    'ageInDays': ageInDays,
    'ageLabel': ageLabel.toMap(),
    'femaleOnly': femaleOnly,
    'description': description.toMap(),
    'order': order,
  };
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

  Map<String, dynamic> toMap() => {
    'purpose': purpose.toMap(),
    'sideEffects': sideEffects.map((item) => item.toMap()).toList(),
    'advice': advice.toMap(),
  };
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

  static Future<void> seedDefaultContent() async {
    final db = _db;
    if (db == null) return;

    try {
      final batch = db.batch();

      for (final vaccine in _seedVaccines) {
        batch.set(
          db.collection('vaccine_schedule').doc(vaccine.id),
          vaccine.toMap(),
          SetOptions(merge: true),
        );
      }
      for (final info in _seedVaccineInfo) {
        batch.set(
          db.collection('vaccine_info').doc(info.id),
          info.toMap(),
          SetOptions(merge: true),
        );
      }
      for (final category in _seedTips) {
        batch.set(
          db.collection('parenting_tip_categories').doc(category.title),
          {
            'title': {
              'en': category.title,
              'si': category.title,
              'ta': category.title,
            },
            'icon': category.icon.codePoint,
            'tips': category.tips
                .map((tip) => {'en': tip, 'si': tip, 'ta': tip})
                .toList(),
            'order': _seedTips.indexOf(category),
          },
          SetOptions(merge: true),
        );
      }
      for (final clinic in _seedClinics) {
        batch.set(
          db.collection('moh_clinics').doc(clinic.mohArea.toLowerCase()),
          {
            'mohArea': clinic.mohArea,
            'name': clinic.name,
            'distanceKm': clinic.distanceKm,
            'nextClinicDate': Timestamp.fromDate(clinic.nextClinicDate),
            'phone': clinic.phone,
            'workingHours': clinic.workingHours,
            'address': clinic.address,
            'photoUrl': clinic.photoUrl,
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } catch (_) {
      // Content seeding is best-effort; app reads local seed data if Firestore
      // rules or project config are not ready yet.
    }
  }

  static Future<List<FirebaseVaccineItem>> getVaccineSchedule({
    required String gender,
  }) async {
    final db = _db;
    if (db != null) {
      try {
        final snapshot = await db
            .collection('vaccine_schedule')
            .orderBy('order')
            .get();
        final items = snapshot.docs.map(FirebaseVaccineItem.fromDoc).toList();
        if (items.isNotEmpty) return _filterByGender(items, gender);
      } catch (_) {}
    }
    return _filterByGender(_seedVaccines, gender);
  }

  static DateTime getDueDate(DateTime dob, FirebaseVaccineItem vaccine) {
    return dob.add(Duration(days: vaccine.ageInDays));
  }

  static Future<FirebaseVaccineInfo?> getVaccineInfo(String vaccineCode) async {
    final code = _infoKey(vaccineCode);
    final db = _db;
    if (db != null) {
      try {
        final doc = await db.collection('vaccine_info').doc(code).get();
        if (doc.exists) return FirebaseVaccineInfo.fromDoc(doc);
      } catch (_) {}
    }
    return _seedVaccineInfo.where((info) => info.id == code).firstOrNull;
  }

  static Future<List<ParentingTipCategory>> getParentingTips() async {
    final db = _db;
    if (db != null) {
      try {
        final snapshot = await db
            .collection('parenting_tip_categories')
            .orderBy('order')
            .get();
        final categories = snapshot.docs.map((doc) {
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
                  (tip) => LocalizedText.fromMap(
                    tip as Map<String, dynamic>?,
                  ).current,
                )
                .toList(),
          );
        }).toList();
        if (categories.isNotEmpty) return categories;
      } catch (_) {}
    }
    return _seedTips;
  }

  static Future<MohClinic?> findMohClinic(String mohArea) async {
    final normalized = mohArea.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final db = _db;
    if (db != null) {
      try {
        final exact = await db.collection('moh_clinics').doc(normalized).get();
        if (exact.exists) return _clinicFromMap(exact.data()!);

        final all = await db.collection('moh_clinics').get();
        for (final doc in all.docs) {
          final clinic = _clinicFromMap(doc.data());
          if (normalized.contains(clinic.mohArea.toLowerCase())) return clinic;
        }
      } catch (_) {}
    }

    for (final clinic in _seedClinics) {
      if (clinic.mohArea.toLowerCase() == normalized) return clinic;
    }
    for (final clinic in _seedClinics) {
      if (normalized.contains(clinic.mohArea.toLowerCase())) return clinic;
    }
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

const _seedVaccines = [
  FirebaseVaccineItem(
    id: 'bcg',
    name: LocalizedText(en: 'BCG', si: 'බී.සී.ජී.', ta: 'பி.சி.ஜி.'),
    doseNumber: 1,
    ageInDays: 0,
    ageLabel: LocalizedText(en: 'At birth', si: 'උපතේදී', ta: 'பிறந்தபோது'),
    description: LocalizedText(
      en: 'Given soon after birth to protect against severe tuberculosis.',
      si: 'තද ක්ෂය රෝගයෙන් ආරක්ෂා වීමට උපතේදී ලබා දෙයි.',
      ta: 'கடுமையான காசநோயிலிருந்து பாதுகாக்க பிறந்தபோது வழங்கப்படுகிறது.',
    ),
    order: 0,
  ),
  FirebaseVaccineItem(
    id: 'penta1',
    name: LocalizedText(
      en: 'Pentavalent 1',
      si: 'පෙන්ටාවැලන්ට් 1',
      ta: 'பென்டாவாலென்ட் 1',
    ),
    doseNumber: 1,
    ageInDays: 60,
    ageLabel: LocalizedText(en: '2 months', si: 'මාස 2', ta: '2 மாதங்கள்'),
    order: 10,
  ),
  FirebaseVaccineItem(
    id: 'opv1',
    name: LocalizedText(en: 'OPV 1', si: 'ඕ.පී.වී. 1', ta: 'ஓ.பி.வி. 1'),
    doseNumber: 1,
    ageInDays: 60,
    ageLabel: LocalizedText(en: '2 months', si: 'මාස 2', ta: '2 மாதங்கள்'),
    order: 11,
  ),
  FirebaseVaccineItem(
    id: 'fipv1',
    name: LocalizedText(
      en: 'fIPV 1',
      si: 'එෆ්-අයි.පී.වී. 1',
      ta: 'எஃப்-ஐ.பி.வி. 1',
    ),
    doseNumber: 1,
    ageInDays: 60,
    ageLabel: LocalizedText(en: '2 months', si: 'මාස 2', ta: '2 மாதங்கள்'),
    order: 12,
  ),
  FirebaseVaccineItem(
    id: 'penta2',
    name: LocalizedText(
      en: 'Pentavalent 2',
      si: 'පෙන්ටාවැලන්ට් 2',
      ta: 'பென்டாவாலென்ட் 2',
    ),
    doseNumber: 2,
    ageInDays: 120,
    ageLabel: LocalizedText(en: '4 months', si: 'මාස 4', ta: '4 மாதங்கள்'),
    order: 20,
  ),
  FirebaseVaccineItem(
    id: 'opv2',
    name: LocalizedText(en: 'OPV 2', si: 'ඕ.පී.වී. 2', ta: 'ஓ.பி.வி. 2'),
    doseNumber: 2,
    ageInDays: 120,
    ageLabel: LocalizedText(en: '4 months', si: 'මාස 4', ta: '4 மாதங்கள்'),
    order: 21,
  ),
  FirebaseVaccineItem(
    id: 'fipv2',
    name: LocalizedText(
      en: 'fIPV 2',
      si: 'එෆ්-අයි.පී.වී. 2',
      ta: 'எஃப்-ஐ.பி.வி. 2',
    ),
    doseNumber: 2,
    ageInDays: 120,
    ageLabel: LocalizedText(en: '4 months', si: 'මාස 4', ta: '4 மாதங்கள்'),
    order: 22,
  ),
  FirebaseVaccineItem(
    id: 'penta3',
    name: LocalizedText(
      en: 'Pentavalent 3',
      si: 'පෙන්ටාවැලන්ට් 3',
      ta: 'பென்டாவாலென்ட் 3',
    ),
    doseNumber: 3,
    ageInDays: 180,
    ageLabel: LocalizedText(en: '6 months', si: 'මාස 6', ta: '6 மாதங்கள்'),
    order: 30,
  ),
  FirebaseVaccineItem(
    id: 'opv3',
    name: LocalizedText(en: 'OPV 3', si: 'ඕ.පී.වී. 3', ta: 'ஓ.பி.வி. 3'),
    doseNumber: 3,
    ageInDays: 180,
    ageLabel: LocalizedText(en: '6 months', si: 'මාස 6', ta: '6 மாதங்கள்'),
    order: 31,
  ),
  FirebaseVaccineItem(
    id: 'mmr1',
    name: LocalizedText(
      en: 'MMR 1',
      si: 'එම්.එම්.ආර්. 1',
      ta: 'எம்.எம்.ஆர். 1',
    ),
    doseNumber: 1,
    ageInDays: 270,
    ageLabel: LocalizedText(en: '9 months', si: 'මාස 9', ta: '9 மாதங்கள்'),
    order: 40,
  ),
  FirebaseVaccineItem(
    id: 'je',
    name: LocalizedText(
      en: 'Live JE',
      si: 'ජපන් එන්සෙෆලයිටිස්',
      ta: 'ஜப்பானிய மூளை அழற்சி',
    ),
    doseNumber: 1,
    ageInDays: 365,
    ageLabel: LocalizedText(en: '12 months', si: 'මාස 12', ta: '12 மாதங்கள்'),
    order: 50,
  ),
  FirebaseVaccineItem(
    id: 'dpt_booster',
    name: LocalizedText(en: 'DPT', si: 'ඩී.පී.ටී.', ta: 'டி.பி.டி.'),
    doseNumber: 1,
    ageInDays: 548,
    ageLabel: LocalizedText(en: '18 months', si: 'මාස 18', ta: '18 மாதங்கள்'),
    order: 60,
  ),
  FirebaseVaccineItem(
    id: 'opv4',
    name: LocalizedText(en: 'OPV 4', si: 'ඕ.පී.වී. 4', ta: 'ஓ.பி.வி. 4'),
    doseNumber: 4,
    ageInDays: 548,
    ageLabel: LocalizedText(en: '18 months', si: 'මාස 18', ta: '18 மாதங்கள்'),
    order: 61,
  ),
  FirebaseVaccineItem(
    id: 'mmr2',
    name: LocalizedText(
      en: 'MMR 2',
      si: 'එම්.එම්.ආර්. 2',
      ta: 'எம்.எம்.ஆர். 2',
    ),
    doseNumber: 2,
    ageInDays: 1095,
    ageLabel: LocalizedText(en: '3 years', si: 'අවුරුදු 3', ta: '3 ஆண்டுகள்'),
    order: 70,
  ),
  FirebaseVaccineItem(
    id: 'dt',
    name: LocalizedText(en: 'DT', si: 'ඩී.ටී.', ta: 'டி.டி.'),
    doseNumber: 1,
    ageInDays: 1825,
    ageLabel: LocalizedText(en: '5 years', si: 'අවුරුදු 5', ta: '5 ஆண்டுகள்'),
    order: 80,
  ),
  FirebaseVaccineItem(
    id: 'opv5',
    name: LocalizedText(en: 'OPV 5', si: 'ඕ.පී.වී. 5', ta: 'ஓ.பி.வி. 5'),
    doseNumber: 5,
    ageInDays: 1825,
    ageLabel: LocalizedText(en: '5 years', si: 'අවුරුදු 5', ta: '5 ஆண்டுகள்'),
    order: 81,
  ),
  FirebaseVaccineItem(
    id: 'hpv1',
    name: LocalizedText(en: 'HPV 1', si: 'එච්.පී.වී. 1', ta: 'எச்.பி.வி. 1'),
    doseNumber: 1,
    ageInDays: 3650,
    ageLabel: LocalizedText(
      en: '10 years',
      si: 'අවුරුදු 10',
      ta: '10 ஆண்டுகள்',
    ),
    femaleOnly: true,
    order: 90,
  ),
  FirebaseVaccineItem(
    id: 'hpv2',
    name: LocalizedText(en: 'HPV 2', si: 'එච්.පී.වී. 2', ta: 'எச்.பி.வி. 2'),
    doseNumber: 2,
    ageInDays: 3832,
    ageLabel: LocalizedText(
      en: '6 months after HPV 1',
      si: 'HPV 1 න් මාස 6කට පසු',
      ta: 'HPV 1 க்கு 6 மாதங்கள் பின்',
    ),
    femaleOnly: true,
    order: 91,
  ),
  FirebaseVaccineItem(
    id: 'atd',
    name: LocalizedText(en: 'aTd', si: 'ඒ.ටී.ඩී.', ta: 'ஏ.டி.டி.'),
    doseNumber: 1,
    ageInDays: 4015,
    ageLabel: LocalizedText(
      en: '11 years',
      si: 'අවුරුදු 11',
      ta: '11 ஆண்டுகள்',
    ),
    order: 100,
  ),
];

const _seedVaccineInfo = [
  FirebaseVaccineInfo(
    id: 'bcg',
    purpose: LocalizedText(
      en: 'Protects against severe forms of tuberculosis.',
      si: 'තද ක්ෂය රෝග ආකාරවලින් ආරක්ෂා කරයි.',
      ta: 'கடுமையான காசநோய் வடிவங்களிலிருந்து பாதுகாக்கிறது.',
    ),
    sideEffects: [
      LocalizedText(
        en: 'Small swelling or scar at injection site',
        si: 'ඉන්ජෙක්ෂන් තැන කුඩා ගැටිල්ලක් හෝ කැළලක්',
        ta: 'ஊசி இடத்தில் சிறிய வீக்கம் அல்லது தழும்பு',
      ),
      LocalizedText(en: 'Mild fever', si: 'සැහැල්ලු උණ', ta: 'லேசான காய்ச்சல்'),
    ],
    advice: LocalizedText(
      en: 'Keep the injection site clean and dry. Visit a clinic if swelling is severe.',
      si: 'ඉන්ජෙක්ෂන් තැන පිරිසිදු සහ වියළිව තබන්න. වැඩි ඉදිමීමක් නම් සායනයට යන්න.',
      ta: 'ஊசி இடத்தை சுத்தமாகவும் உலர்வாகவும் வைத்திருங்கள். அதிக வீக்கம் இருந்தால் கிளினிக்கிற்கு செல்லுங்கள்.',
    ),
  ),
  FirebaseVaccineInfo(
    id: 'penta',
    purpose: LocalizedText(
      en: 'Protects against diphtheria, pertussis, tetanus, hepatitis B and Hib.',
      si: 'ඩිප්තීරියා, කක්කල් කැස්ස, ටෙටනස්, හෙපටයිටිස් B සහ Hib වලින් ආරක්ෂා කරයි.',
      ta: 'டிப்தீரியா, பெர்டுசிஸ், டெட்டனஸ், ஹெபடைட்டிஸ் B மற்றும் Hib இல் இருந்து பாதுகாக்கிறது.',
    ),
    sideEffects: [
      LocalizedText(en: 'Fever', si: 'උණ', ta: 'காய்ச்சல்'),
      LocalizedText(
        en: 'Soreness at injection site',
        si: 'ඉන්ජෙක්ෂන් තැන වේදනාව',
        ta: 'ஊசி இடத்தில் வலி',
      ),
      LocalizedText(en: 'Irritability', si: 'අසහනය', ta: 'எரிச்சல்'),
    ],
    advice: LocalizedText(
      en: 'Mild fever for a day or two is common. Seek care if symptoms are severe.',
      si: 'දවසක් දෙකක් සැහැල්ලු උණ සාමාන්‍යය. තද ලක්ෂණ ඇති නම් උපදෙස් ගන්න.',
      ta: 'ஒரு அல்லது இரண்டு நாட்கள் லேசான காய்ச்சல் சாதாரணம். கடுமையான அறிகுறிகள் இருந்தால் ஆலோசனை பெறுங்கள்.',
    ),
  ),
  FirebaseVaccineInfo(
    id: 'opv',
    purpose: LocalizedText(
      en: 'Protects against poliomyelitis.',
      si: 'පෝලියෝ රෝගයෙන් ආරක්ෂා කරයි.',
      ta: 'போலியோமையலிடிஸிலிருந்து பாதுகாக்கிறது.',
    ),
    sideEffects: [
      LocalizedText(
        en: 'Usually no side effects',
        si: 'සාමාන්‍යයෙන් අතුරු ආබාධ නැත',
        ta: 'பொதுவாக பக்கவிளைவுகள் இல்லை',
      ),
    ],
    advice: LocalizedText(
      en: 'Given by mouth. Follow clinic instructions after the dose.',
      si: 'මුඛයෙන් ලබා දෙයි. මාත්‍රාවෙන් පසු සායන උපදෙස් පිළිපදින්න.',
      ta: 'வாய் வழியாக வழங்கப்படுகிறது. மருந்தளவுக்குப் பிறகு கிளினிக் அறிவுறுத்தல்களைப் பின்பற்றவும்.',
    ),
  ),
  FirebaseVaccineInfo(
    id: 'fipv',
    purpose: LocalizedText(
      en: 'Injectable polio vaccine given with OPV.',
      si: 'OPV සමඟ ලබාදෙන ඉන්ජෙක්ෂන් පෝලියෝ එන්නත.',
      ta: 'OPV உடன் வழங்கப்படும் ஊசி போலியோ தடுப்பூசி.',
    ),
    sideEffects: [
      LocalizedText(
        en: 'Mild soreness at injection site',
        si: 'ඉන්ජෙක්ෂන් තැන සුළු වේදනාව',
        ta: 'ஊசி இடத்தில் லேசான வலி',
      ),
    ],
    advice: LocalizedText(
      en: 'Monitor the injection site for redness or swelling.',
      si: 'රතු වීම හෝ ඉදිමීම තිබේද බලන්න.',
      ta: 'சிவத்தல் அல்லது வீக்கம் உள்ளதா கண்காணிக்கவும்.',
    ),
  ),
  FirebaseVaccineInfo(
    id: 'mmr',
    purpose: LocalizedText(
      en: 'Protects against measles, mumps and rubella.',
      si: 'සරම්ප, කම්මුල්ගාය සහ රුබෙල්ලා වලින් ආරක්ෂා කරයි.',
      ta: 'சின்னம்மை, மம்ப்ஸ் மற்றும் ரூபெல்லாவிலிருந்து பாதுகாக்கிறது.',
    ),
    sideEffects: [
      LocalizedText(en: 'Mild fever', si: 'සැහැල්ලු උණ', ta: 'லேசான காய்ச்சல்'),
      LocalizedText(en: 'Mild rash', si: 'සැහැල්ලු රෑෂ්', ta: 'லேசான சிரங்கு'),
    ],
    advice: LocalizedText(
      en: 'Fever can appear several days after the vaccine. Seek care if it is high or prolonged.',
      si: 'එන්නතෙන් දින කිහිපයකට පසු උණ ඇති විය හැක. වැඩි හෝ දිගු උණ නම් උපදෙස් ගන්න.',
      ta: 'தடுப்பூசிக்குப் பிறகு சில நாட்களில் காய்ச்சல் வரலாம். அதிகமாக அல்லது நீடித்தால் ஆலோசனை பெறுங்கள்.',
    ),
  ),
  FirebaseVaccineInfo(
    id: 'je',
    purpose: LocalizedText(
      en: 'Protects against Japanese encephalitis.',
      si: 'ජපන් එන්සෙෆලයිටිස් රෝගයෙන් ආරක්ෂා කරයි.',
      ta: 'ஜப்பானிய மூளை அழற்சியிலிருந்து பாதுகாக்கிறது.',
    ),
    sideEffects: [
      LocalizedText(
        en: 'Fever or redness at injection site',
        si: 'උණ හෝ ඉන්ජෙක්ෂන් තැන රතු වීම',
        ta: 'காய்ச்சல் அல்லது ஊசி இடத்தில் சிவத்தல்',
      ),
    ],
    advice: LocalizedText(
      en: 'Contact your clinic if fever lasts more than two days.',
      si: 'උණ දින දෙකකට වැඩි නම් සායනය අමතන්න.',
      ta: 'காய்ச்சல் இரண்டு நாட்களுக்கு மேல் நீடித்தால் கிளினிக்குடன் தொடர்புகொள்ளுங்கள்.',
    ),
  ),
  FirebaseVaccineInfo(
    id: 'dpt',
    purpose: LocalizedText(
      en: 'Booster protection against diphtheria, pertussis and tetanus.',
      si: 'ඩිප්තීරියා, කක්කල් කැස්ස සහ ටෙටනස් සඳහා බූස්ටර් ආරක්ෂාව ලබා දෙයි.',
      ta: 'டிப்தீரியா, பெர்டுசிஸ் மற்றும் டெட்டனஸுக்கு பூஸ்டர் பாதுகாப்பு அளிக்கிறது.',
    ),
    sideEffects: [
      LocalizedText(en: 'Fever', si: 'උණ', ta: 'காய்ச்சல்'),
      LocalizedText(
        en: 'Soreness at injection site',
        si: 'ඉන්ජෙක්ෂන් තැන වේදනාව',
        ta: 'ஊசி இடத்தில் வலி',
      ),
    ],
    advice: LocalizedText(
      en: 'Mild fever and soreness are common. Contact the clinic if symptoms are severe.',
      si: 'සැහැල්ලු උණ සහ වේදනාව සාමාන්‍යයි. තද ලක්ෂණ ඇති නම් සායනය අමතන්න.',
      ta: 'லேசான காய்ச்சலும் வலியும் சாதாரணம். கடுமையாக இருந்தால் கிளினிக்குடன் தொடர்புகொள்ளுங்கள்.',
    ),
  ),
  FirebaseVaccineInfo(
    id: 'dt',
    purpose: LocalizedText(
      en: 'Booster protection against diphtheria and tetanus.',
      si: 'ඩිප්තීරියා සහ ටෙටනස් සඳහා බූස්ටර් ආරක්ෂාව ලබා දෙයි.',
      ta: 'டிப்தீரியா மற்றும் டெட்டனஸுக்கு பூஸ்டர் பாதுகாப்பு அளிக்கிறது.',
    ),
    sideEffects: [
      LocalizedText(
        en: 'Pain or redness at injection site',
        si: 'ඉන්ජෙක්ෂන් තැන වේදනාව හෝ රතු වීම',
        ta: 'ஊசி இடத்தில் வலி அல்லது சிவத்தல்',
      ),
    ],
    advice: LocalizedText(
      en: 'Keep the vaccination record updated after the dose.',
      si: 'මාත්‍රාවෙන් පසු එන්නත් වාර්තාව යාවත්කාලීන කරගන්න.',
      ta: 'மருந்தளவுக்குப் பிறகு தடுப்பூசி பதிவை புதுப்பிக்கவும்.',
    ),
  ),
  FirebaseVaccineInfo(
    id: 'hpv',
    purpose: LocalizedText(
      en: 'Helps protect girls against HPV infections that can lead to cervical cancer.',
      si: 'ගැබ්ගෙල පිළිකාවට හේතු විය හැකි HPV ආසාදන වලින් ගැහැණු ළමුන් ආරක්ෂා කිරීමට උදව් කරයි.',
      ta: 'கருப்பை வாய்ப் புற்றுநோய்க்கு வழிவகுக்கும் HPV தொற்றுகளிலிருந்து சிறுமிகளைப் பாதுகாக்க உதவுகிறது.',
    ),
    sideEffects: [
      LocalizedText(
        en: 'Soreness at injection site',
        si: 'ඉන්ජෙක්ෂන් තැන වේදනාව',
        ta: 'ஊசி இடத்தில் வலி',
      ),
      LocalizedText(
        en: 'Mild fever or headache',
        si: 'සැහැල්ලු උණ හෝ හිසරදය',
        ta: 'லேசான காய்ச்சல் அல்லது தலைவலி',
      ),
    ],
    advice: LocalizedText(
      en: 'Complete both doses as advised by the clinic or school health programme.',
      si: 'සායන හෝ පාසල් සෞඛ්‍ය වැඩසටහනෙන් උපදෙස් දෙන පරිදි මාත්‍රා දෙකම සම්පූර්ණ කරන්න.',
      ta: 'கிளினிக் அல்லது பள்ளி சுகாதாரத் திட்டம் அறிவுறுத்தும் படி இரு மருந்தளவுகளையும் முடிக்கவும்.',
    ),
  ),
  FirebaseVaccineInfo(
    id: 'atd',
    purpose: LocalizedText(
      en: 'Adolescent booster protection against tetanus and diphtheria.',
      si: 'යෞවන වයස සඳහා ටෙටනස් සහ ඩිප්තීරියා බූස්ටර් ආරක්ෂාව.',
      ta: 'இளம்வயதிற்கான டெட்டனஸ் மற்றும் டிப்தீரியா பூஸ்டர் பாதுகாப்பு.',
    ),
    sideEffects: [
      LocalizedText(
        en: 'Mild pain or swelling at injection site',
        si: 'ඉන්ජෙක්ෂන් තැන සුළු වේදනාව හෝ ඉදිමීම',
        ta: 'ஊசி இடத்தில் லேசான வலி அல்லது வீக்கம்',
      ),
    ],
    advice: LocalizedText(
      en: 'Record the dose and follow clinic guidance for any symptoms.',
      si: 'මාත්‍රාව වාර්තා කර ලක්ෂණ තිබේ නම් සායන උපදෙස් පිළිපදින්න.',
      ta: 'மருந்தளவை பதிவு செய்து அறிகுறிகள் இருந்தால் கிளினிக் வழிகாட்டுதலைப் பின்பற்றவும்.',
    ),
  ),
];

final _seedTips = [
  ParentingTipCategory(
    title: 'Pregnancy Care',
    icon: Icons.pregnant_woman_rounded,
    tips: [
      'Register with your PHM/MOH clinic early in pregnancy.',
      'Attend antenatal clinic visits on the advised dates.',
      'Take iron, folic acid and other supplements as advised by your clinic.',
      'Seek urgent care for bleeding, severe headache, blurred vision, fits, reduced baby movements, fever or severe abdominal pain.',
    ],
  ),
  ParentingTipCategory(
    title: 'Breastfeeding',
    icon: Icons.child_care_rounded,
    tips: [
      'Start breastfeeding within the first hour after birth if possible.',
      'Exclusive breastfeeding is recommended for the first 6 months.',
      'If feeding is painful or difficult, ask your PHM or clinic team for help.',
    ],
  ),
  ParentingTipCategory(
    title: 'Nutrition',
    icon: Icons.restaurant_rounded,
    tips: [
      'Introduce complementary foods around 6 months while continuing breastfeeding.',
      'Offer varied foods including grains, vegetables, fruits and protein sources.',
      'Avoid added salt, sugar and honey for babies under 1 year.',
    ],
  ),
  ParentingTipCategory(
    title: 'Warning Signs',
    icon: Icons.warning_amber_rounded,
    tips: [
      'Seek medical help for high fever, poor feeding, difficulty breathing, persistent vomiting or unusual drowsiness.',
      'For newborns, very few wet diapers or worsening jaundice needs urgent advice.',
    ],
  ),
];

final _seedClinics = [
  MohClinic(
    mohArea: 'Colombo',
    name: 'Colombo MOH Office',
    distanceKm: 1,
    nextClinicDate: DateTime(2026, 8, 1),
    phone: '011 222 3333',
    workingHours: '8.00 AM - 4.00 PM',
    address: 'MOH Office, Colombo',
  ),
  MohClinic(
    mohArea: 'Gampaha',
    name: 'Gampaha MOH Office',
    distanceKm: 1.5,
    nextClinicDate: DateTime(2026, 8, 1),
    phone: '033 222 3333',
    workingHours: '8.00 AM - 4.00 PM',
    address: 'MOH Office, Gampaha',
  ),
  MohClinic(
    mohArea: 'Kandy',
    name: 'Kandy MOH Office',
    distanceKm: 1.8,
    nextClinicDate: DateTime(2026, 8, 1),
    phone: '081 222 3333',
    workingHours: '8.00 AM - 4.00 PM',
    address: 'MOH Office, Kandy',
  ),
];
