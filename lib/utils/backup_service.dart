import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

class BackupService {
  static const String dbName = 'babybloom.db';

  static Future<String> _getCurrentDbPath() async {
    final dbFolder = await getDatabasesPath();
    return join(dbFolder, dbName);
  }

  static Future<Directory> _getBackupFolder() async {
    final extDir = await getExternalStorageDirectory();
    final backupDir = Directory('${extDir!.path}/Backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  static Future<String> backupDatabase() async {
    await DBHelper().closeDB();

    final dbPath = await _getCurrentDbPath();
    final currentDb = File(dbPath);

    if (!await currentDb.exists()) {
      throw Exception('Database file එක හම්බුනේ නෑ');
    }

    final backupFolder = await _getBackupFolder();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final backupPath = '${backupFolder.path}/backup_$timestamp.db';

    await currentDb.copy(backupPath);
    return backupPath;
  }

  static Future<bool> restoreDatabase() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result == null || result.files.single.path == null) {
      return false;
    }

    final pickedPath = result.files.single.path!;
    if (!pickedPath.toLowerCase().endsWith('.db')) {
      throw Exception(
        '.db file එකක් තෝරන්න (ඔයා තෝරපු file එක backup file එකක් නෙවෙයි)',
      );
    }

    final pickedFile = File(pickedPath);

    await DBHelper().closeDB();

    final dbPath = await _getCurrentDbPath();
    await pickedFile.copy(dbPath);

    return true;
  }

  static Future<List<File>> listBackups() async {
    final backupFolder = await _getBackupFolder();
    final files = backupFolder
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList();
    files.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );
    return files;
  }
}
