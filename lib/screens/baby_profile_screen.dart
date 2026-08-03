import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../database/db_helper.dart';
import '../l10n/l10n.dart';
import '../models/baby.dart';
import '../theme/app_theme.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/app_top_bar.dart';
import 'add_baby_screen.dart';
import 'growth_chart_screen.dart';
import 'home_screen.dart';

class BabyProfileScreen extends StatefulWidget {
  final int babyId;

  const BabyProfileScreen({super.key, required this.babyId});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  Baby? _baby;
  bool _loading = true;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadBaby();
  }

  Future<void> _loadBaby() async {
    final baby = await DBHelper().getBaby(widget.babyId);
    if (!mounted) return;
    setState(() {
      _baby = baby;
      _loading = false;
    });
  }

  Future<void> _pickAndSavePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null || _baby == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'baby_${_baby!.id}_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
      final savedPath = p.join(appDir.path, fileName);
      await File(picked.path).copy(savedPath);

      _baby!.photoPath = savedPath;
      await DBHelper().updateBaby(_baby!);

      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.photoSaveFailed(e.toString()))),
      );
    }
  }

  Future<void> _goToEditScreen() async {
    if (_baby == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddBabyScreen(babyToEdit: _baby)),
    );
    _loadBaby();
  }

  void _goToGrowthChart() {
    if (_baby == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GrowthChartScreen(babyId: _baby!.id!)),
    );
  }

  Future<void> _deleteBaby() async {
    final baby = _baby;
    if (baby == null || baby.id == null) return;

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: context.l10n.deleteBabyTitle,
      message: context.l10n.deleteBabyMessage(baby.name),
      cancelLabel: context.l10n.cancel,
      confirmLabel: context.l10n.deleteBaby,
      icon: Icons.delete_outline_rounded,
      confirmColor: AppColors.overdue,
    );
    if (confirmed != true || !mounted) return;

    await DBHelper().deleteBaby(baby.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.babyDeleted(baby.name)),
        backgroundColor: AppColors.overdue,
      ),
    );
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: _baby == null ? l10n.babyProfile : '${_baby!.name} Profile',
        actions: [
          AppBarActionButton(
            icon: Icons.edit_rounded,
            tooltip: l10n.editBaby,
            onPressed: _goToEditScreen,
          ),
          AppBarActionButton(
            icon: Icons.delete_outline_rounded,
            tooltip: l10n.deleteBaby,
            onPressed: _deleteBaby,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _baby == null
            ? Center(child: Text(l10n.babyProfileNotFound))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildAvatar(_baby!),
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      icon: Icons.cake_rounded,
                      label: l10n.dateOfBirth,
                      value: context.formatNumericDate(_baby!.dob),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoCard(
                      icon: Icons.wc_rounded,
                      label: l10n.gender,
                      value: context.genderLabel(_baby!.gender),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoCard(
                      icon: Icons.water_drop_rounded,
                      label: l10n.bloodGroup,
                      value: _baby!.bloodGroup ?? '-',
                    ),
                    const SizedBox(height: 14),
                    _buildInfoCard(
                      icon: Icons.monitor_weight_rounded,
                      label: l10n.birthWeight,
                      value: _baby!.birthWeightKg != null
                          ? '${_baby!.birthWeightKg} kg'
                          : '-',
                    ),
                    const SizedBox(height: 14),
                    _buildInfoCard(
                      icon: Icons.local_hospital_rounded,
                      label: l10n.hospital,
                      value: _baby!.hospital ?? '-',
                    ),
                    const SizedBox(height: 24),
                    _buildGrowthChartButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAvatar(Baby baby) {
    final hasPhoto =
        baby.photoPath != null && File(baby.photoPath!).existsSync();

    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.softSurface,
                backgroundImage: hasPhoto
                    ? FileImage(File(baby.photoPath!))
                    : null,
                child: !hasPhoto
                    ? Text(
                        baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: GestureDetector(
                  onTap: _uploadingPhoto ? null : _pickAndSavePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _uploadingPhoto
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            baby.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.ageLabel(baby.dob),
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChartButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _goToGrowthChart,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: AppColors.softSurface,
        ),
        icon: Icon(Icons.show_chart_rounded, color: AppColors.primary),
        label: Text(
          context.l10n.growthChart,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
