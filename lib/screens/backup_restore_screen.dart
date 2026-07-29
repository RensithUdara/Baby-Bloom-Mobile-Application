import 'dart:io';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/backup_service.dart';
import '../widgets/app_top_bar.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isLoading = false;
  List<File> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final files = await BackupService.listBackups();
    setState(() => _backups = files);
  }

  Future<void> _handleBackup() async {
    setState(() => _isLoading = true);
    try {
      final path = await BackupService.backupDatabase();
      _showMessage(context.l10n.backupSuccess(path));
      await _loadBackups();
    } catch (e) {
      _showMessage(context.l10n.backupFailed(e.toString()), isError: true);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleRestore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.restoreConfirm),
        content: Text(context.l10n.restoreConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.restore),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await BackupService.restoreDatabase();
      if (success) {
        _showMessage(context.l10n.restoreSuccess);
      }
    } catch (e) {
      _showMessage(context.l10n.restoreFailed(e.toString()), isError: true);
    }
    setState(() => _isLoading = false);
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.backupRestore),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.cloud_done_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.backupRestore,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              context.l10n.previousBackups,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _handleBackup,
                        icon: const Icon(Icons.backup_rounded),
                        label: Text(context.l10n.backupNow),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleRestore,
                        icon: const Icon(Icons.restore_rounded),
                        label: Text(context.l10n.restoreFromBackup),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.previousBackups,
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 10),
                if (_backups.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_off_rounded,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.l10n.noBackupsYet,
                            style: AppTextStyles.subtitle,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._backups.map(
                    (f) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.softSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.description_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.path.split('/').last,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.cardTitle,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  f.statSync().modified.toString(),
                                  style: AppTextStyles.subtitle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
