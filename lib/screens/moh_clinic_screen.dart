import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/db_helper.dart';
import '../data/firebase_content_repository.dart';
import '../l10n/l10n.dart';
import '../models/moh_clinic.dart';
import '../theme/app_theme.dart';
import '../widgets/info_row.dart';
import '../widgets/app_top_bar.dart';
import 'mother_profile_screen.dart';

class MohClinicScreen extends StatefulWidget {
  const MohClinicScreen({super.key});

  @override
  State<MohClinicScreen> createState() => _MohClinicScreenState();
}

class _MohClinicScreenState extends State<MohClinicScreen> {
  MohClinic? clinic;
  String? savedPhotoPath;
  bool loading = true;
  bool notFound = false;

  @override
  void initState() {
    super.initState();
    _loadClinic();
  }

  Future<void> _loadClinic() async {
    final mother = await DBHelper().getActiveMother();

    if (mother == null) {
      setState(() {
        clinic = null;
        notFound = true;
        loading = false;
      });
      return;
    }

    final found = await FirebaseContentRepository.findMohClinic(mother.mohArea);

    String? photoPath;
    if (found != null) {
      photoPath = await DBHelper().getClinicPhoto(found.mohArea);
    }

    setState(() {
      clinic = found;
      savedPhotoPath = photoPath;
      notFound = found == null;
      loading = false;
    });
  }

  Future<void> _pickClinicPhoto() async {
    if (clinic == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    await DBHelper().setClinicPhoto(clinic!.mohArea, picked.path);

    if (!mounted) return;
    setState(() => savedPhotoPath = picked.path);
  }

  Future<void> _call() async {
    if (clinic == null) return;
    final uri = Uri(scheme: 'tel', path: clinic!.phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.couldNotOpenDialer)));
    }
  }

  Future<void> _openMap({bool directions = false}) async {
    if (clinic == null) return;
    final query = Uri.encodeComponent(clinic!.address);
    final uri = directions
        ? Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$query')
        : Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.couldNotOpenMaps)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.mohClinicDetails),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : notFound
            ? _buildNotFound()
            : _buildClinicDetails(clinic!),
      ),
    );
  }

  Widget _buildNotFound() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 72),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      AppColors.primaryDark.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.mohNotFoundTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.mohNotFoundMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MotherProfileScreen(),
                      ),
                    );
                    if (mounted) _loadClinic();
                  },
                  icon: const Icon(Icons.edit_location_alt_rounded),
                  label: Text(context.l10n.motherProfile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClinicImage(String? photoUrl) {
    const placeholder = ColoredBox(
      color: Color(0xFFE9E4F7),
      child: Center(
        child: Icon(
          Icons.local_hospital_rounded,
          size: 48,
          color: Color(0xFF7C5FD6),
        ),
      ),
    );

    if (photoUrl == null || photoUrl.trim().isEmpty) {
      return placeholder;
    }

    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const ColoredBox(
            color: Color(0xFFE9E4F7),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stack) => placeholder,
      );
    }

    final file = File(photoUrl);
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => placeholder,
    );
  }

  Widget _buildClinicDetails(MohClinic clinic) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: _buildClinicImage(savedPhotoPath ?? clinic.photoUrl),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Material(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickClinicPhoto,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(clinic.name, style: AppTextStyles.greeting),
        const SizedBox(height: 2),
        Text(
          'Distance: ${clinic.distanceKm} km',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 16),
        InfoRow(
          icon: Icons.event_rounded,
          label: context.l10n.nextClinicDate,
          value: clinic.nextClinicDateText,
        ),
        InfoRow(
          icon: Icons.phone_rounded,
          label: context.l10n.phone,
          value: clinic.phone,
        ),
        InfoRow(
          icon: Icons.access_time_rounded,
          label: context.l10n.workingHours,
          value: clinic.workingHours,
        ),
        InfoRow(
          icon: Icons.location_on_rounded,
          label: context.l10n.address,
          value: clinic.address,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _call,
                icon: const Icon(Icons.call_rounded, size: 18),
                label: Text(context.l10n.call),
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
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openMap(),
                icon: const Icon(Icons.map_rounded, size: 18),
                label: Text(context.l10n.map),
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
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openMap(directions: true),
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: Text(context.l10n.directions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
