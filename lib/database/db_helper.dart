import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/baby.dart';
import '../models/vaccine.dart';
import '../models/mother.dart';
import '../models/emergency_contact.dart';
import '../models/growth_record.dart';
import '../models/reminder.dart';
import '../data/firebase_content_repository.dart';
import '../data/notification_helper.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static const _activeBabyKey = 'active_baby_id';

  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'babybloom.db');

    return await openDatabase(
      path,
      version: 9,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE babies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        gender TEXT NOT NULL,
        photoPath TEXT,
        bloodGroup TEXT,
        birthWeightKg REAL,
        hospital TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE vaccines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        vaccineName TEXT NOT NULL,
        vaccineCode TEXT,
        doseNumber INTEGER NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL,
        completedDate TEXT,
        cardPhotoPath TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notification_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        scheduledDate TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mothers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        nic TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        mohArea TEXT NOT NULL,
        nearestClinic TEXT NOT NULL,
        photoUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE clinic_photos (
        mohArea TEXT PRIMARY KEY,
        photoPath TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE emergency_contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        relation TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE growth_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        recordedDate TEXT NOT NULL,
        weightKg REAL NOT NULL,
        heightCm REAL NOT NULL,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE babies ADD COLUMN bloodGroup TEXT');
      await db.execute('ALTER TABLE babies ADD COLUMN birthWeightKg REAL');
      await db.execute('ALTER TABLE babies ADD COLUMN hospital TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notification_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          babyId INTEGER,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          scheduledDate TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS mothers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          nic TEXT NOT NULL,
          phone TEXT NOT NULL,
          address TEXT NOT NULL,
          mohArea TEXT NOT NULL,
          nearestClinic TEXT NOT NULL,
          photoUrl TEXT
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS clinic_photos (
          mohArea TEXT PRIMARY KEY,
          photoPath TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS emergency_contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          relation TEXT
        )
      ''');
    }
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS growth_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          babyId INTEGER NOT NULL,
          recordedDate TEXT NOT NULL,
          weightKg REAL NOT NULL,
          heightCm REAL NOT NULL,
          FOREIGN KEY (babyId) REFERENCES babies (id)
        )
      ''');
    }
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          date TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 9) {
      await db.execute('ALTER TABLE vaccines ADD COLUMN vaccineCode TEXT');
    }
  }

  Future<int> insertMother(Mother mother) async {
    final db = await database;
    final id = await db.insert('mothers', mother.toMap()..remove('id'));
    await FirebaseContentRepository.saveMother(mother.copyWith(id: id));
    return id;
  }

  Future<Mother?> getActiveMother() async {
    final db = await database;
    final result = await db.query('mothers', limit: 1);
    if (result.isEmpty) return FirebaseContentRepository.fetchFirstMother();
    return Mother.fromMap(result.first);
  }

  Future<Mother?> getMother(int id) async {
    final db = await database;
    final result = await db.query('mothers', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Mother.fromMap(result.first);
  }

  Future<int> saveMother(Mother mother) async {
    if (mother.id == null) {
      return await insertMother(mother);
    }
    final db = await database;
    final result = await db.update(
      'mothers',
      mother.toMap(),
      where: 'id = ?',
      whereArgs: [mother.id],
    );
    await FirebaseContentRepository.saveMother(mother);
    return result;
  }

  Future<int> deleteMother(int id) async {
    final db = await database;
    final result = await db.delete('mothers', where: 'id = ?', whereArgs: [id]);
    await FirebaseContentRepository.deleteMother(id);
    return result;
  }

  Future<void> setClinicPhoto(String mohArea, String photoPath) async {
    final db = await database;
    await db.insert('clinic_photos', {
      'mohArea': mohArea,
      'photoPath': photoPath,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getClinicPhoto(String mohArea) async {
    final db = await database;
    final result = await db.query(
      'clinic_photos',
      where: 'mohArea = ?',
      whereArgs: [mohArea],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first['photoPath'] as String?;
  }

  Future<int> insertEmergencyContact(EmergencyContact contact) async {
    final db = await database;
    final id = await db.insert(
      'emergency_contacts',
      contact.toMap()..remove('id'),
    );
    await FirebaseContentRepository.saveEmergencyContact(
      EmergencyContact(
        id: id,
        name: contact.name,
        phone: contact.phone,
        relation: contact.relation,
      ),
    );
    return id;
  }

  Future<List<EmergencyContact>> getAllEmergencyContacts() async {
    final db = await database;
    final result = await db.query('emergency_contacts', orderBy: 'id DESC');
    return result.map((map) => EmergencyContact.fromMap(map)).toList();
  }

  Future<int> deleteEmergencyContact(int id) async {
    final db = await database;
    final result = await db.delete(
      'emergency_contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    await FirebaseContentRepository.deleteEmergencyContact(id);
    return result;
  }

  Future<int> insertBaby(Baby baby) async {
    final db = await database;
    final babyId = await db.insert('babies', baby.toMap());

    final savedBaby = Baby(
      id: babyId,
      name: baby.name,
      dob: baby.dob,
      gender: baby.gender,
      photoPath: baby.photoPath,
      bloodGroup: baby.bloodGroup,
      birthWeightKg: baby.birthWeightKg,
      hospital: baby.hospital,
    );
    await FirebaseContentRepository.saveBaby(savedBaby);

    final applicableVaccines =
        await FirebaseContentRepository.getVaccineSchedule(gender: baby.gender);

    for (var v in applicableVaccines) {
      final dueDate = FirebaseContentRepository.getDueDate(baby.dob, v);

      final vaccine = Vaccine(
        babyId: babyId,
        vaccineName: v.name.current,
        vaccineCode: v.id,
        doseNumber: v.doseNumber,
        dueDate: dueDate,
        status: 'pending',
      );

      final vaccineId = await db.insert('vaccines', vaccine.toMap());

      vaccine.id = vaccineId;
      await FirebaseContentRepository.saveVaccine(vaccine);
      await NotificationHelper().scheduleVaccineReminders(vaccine, baby.name);
    }

    await setActiveBaby(babyId);
    return babyId;
  }

  Future<List<Baby>> getAllBabies() async {
    final db = await database;
    final result = await db.query('babies');
    return result.map((map) => Baby.fromMap(map)).toList();
  }

  Future<Baby?> getBaby(int babyId) async {
    final db = await database;
    final result = await db.query(
      'babies',
      where: 'id = ?',
      whereArgs: [babyId],
    );
    if (result.isEmpty) {
      return FirebaseContentRepository.fetchBaby(babyId);
    }
    return Baby.fromMap(result.first);
  }

  Future<Baby?> getActiveBaby() async {
    final babies = await getAllBabies();
    if (babies.isEmpty) return FirebaseContentRepository.fetchFirstBaby();
    final selectedId = await getActiveBabyId();
    if (selectedId != null) {
      for (final baby in babies) {
        if (baby.id == selectedId) return baby;
      }
    }
    return babies.first;
  }

  Future<int?> getActiveBabyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activeBabyKey);
  }

  Future<void> setActiveBaby(int babyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeBabyKey, babyId);
  }

  Future<int> updateBaby(Baby baby) async {
    final db = await database;
    final result = await db.update(
      'babies',
      baby.toMap(),
      where: 'id = ?',
      whereArgs: [baby.id],
    );
    await FirebaseContentRepository.saveBaby(baby);
    return result;
  }

  Future<int> deleteBaby(int babyId) async {
    final db = await database;
    await db.delete('vaccines', where: 'babyId = ?', whereArgs: [babyId]);
    final result = await db.delete(
      'babies',
      where: 'id = ?',
      whereArgs: [babyId],
    );
    final selectedId = await getActiveBabyId();
    if (selectedId == babyId) {
      final remaining = await getAllBabies();
      final prefs = await SharedPreferences.getInstance();
      if (remaining.isEmpty || remaining.first.id == null) {
        await prefs.remove(_activeBabyKey);
      } else {
        await prefs.setInt(_activeBabyKey, remaining.first.id!);
      }
    }
    await FirebaseContentRepository.deleteBaby(babyId);
    return result;
  }

  Future<int> insertVaccine(Vaccine vaccine) async {
    final db = await database;
    final id = await db.insert('vaccines', vaccine.toMap());
    vaccine.id = id;
    await FirebaseContentRepository.saveVaccine(vaccine);
    return id;
  }

  Future<List<Vaccine>> getVaccinesForBaby(int babyId) async {
    final db = await database;
    final result = await db.query(
      'vaccines',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'dueDate ASC',
    );
    return result.map((map) => Vaccine.fromMap(map)).toList();
  }

  Future<Vaccine?> getNextPendingVaccine(int babyId) async {
    final db = await database;
    final result = await db.query(
      'vaccines',
      where: 'babyId = ? AND status = ?',
      whereArgs: [babyId, 'pending'],
      orderBy: 'dueDate ASC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Vaccine.fromMap(result.first);
  }

  Future<int> updateVaccineStatus(
    int vaccineId,
    String status,
    DateTime? completedDate,
  ) async {
    final db = await database;
    final result = await db.update(
      'vaccines',
      {'status': status, 'completedDate': completedDate?.toIso8601String()},
      where: 'id = ?',
      whereArgs: [vaccineId],
    );

    if (status == 'completed') {
      await NotificationHelper().cancelVaccineReminders(vaccineId);
    }

    await FirebaseContentRepository.updateVaccineStatus(
      vaccineId: vaccineId,
      status: status,
      completedDate: completedDate,
    );

    return result;
  }

  Future<List<Map<String, dynamic>>>
  getAllPendingVaccinesWithBabyNames() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT vaccines.*, babies.name as babyName
      FROM vaccines
      INNER JOIN babies ON babies.id = vaccines.babyId
      WHERE vaccines.status = 'pending'
    ''');
  }

  Future<int> insertGrowthRecord(GrowthRecord record) async {
    final db = await database;
    final id = await db.insert('growth_records', record.toMap()..remove('id'));
    record.id = id;
    await FirebaseContentRepository.saveGrowthRecord(record);
    return id;
  }

  Future<List<GrowthRecord>> getGrowthRecordsForBaby(int babyId) async {
    final db = await database;
    final result = await db.query(
      'growth_records',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'recordedDate ASC',
    );
    return result.map((map) => GrowthRecord.fromMap(map)).toList();
  }

  Future<int> deleteGrowthRecord(int id) async {
    final db = await database;
    final result = await db.delete(
      'growth_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    await FirebaseContentRepository.deleteGrowthRecord(id);
    return result;
  }

  Future<int> insertReminder(Reminder reminder) async {
    final db = await database;
    final id = await db.insert('reminders', reminder.toMap()..remove('id'));
    reminder.id = id;
    await FirebaseContentRepository.saveReminder(reminder);
    return id;
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final result = await db.query('reminders', orderBy: 'date ASC');
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    final result = await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
    await FirebaseContentRepository.deleteReminder(id);
    return result;
  }

  Future<int> insertNotificationHistory({
    required int? babyId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final db = await database;
    final id = await db.insert('notification_history', {
      'babyId': babyId,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
    });
    await FirebaseContentRepository.saveNotificationHistory(
      id: id,
      babyId: babyId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
    return id;
  }

  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    final db = await database;
    return await db.query('notification_history', orderBy: 'scheduledDate ASC');
  }

  Future<void> deleteUpcomingNotificationHistory() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      'notification_history',
      where: 'scheduledDate > ?',
      whereArgs: [now],
    );
    await FirebaseContentRepository.deleteUpcomingNotificationHistory();
  }

  Future<void> closeDB() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
