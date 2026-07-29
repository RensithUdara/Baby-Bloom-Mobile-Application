import 'package:flutter/material.dart';
import '../data/firebase_content_repository.dart';
import '../database/db_helper.dart';
import '../l10n/l10n.dart';
import '../models/moh_clinic.dart';
import '../models/mother.dart';
import '../theme/app_theme.dart';
import '../widgets/info_row.dart';
import '../widgets/app_top_bar.dart';

class MotherProfileScreen extends StatefulWidget {
  const MotherProfileScreen({super.key});

  @override
  State<MotherProfileScreen> createState() => _MotherProfileScreenState();
}

class _MotherProfileScreenState extends State<MotherProfileScreen> {
  Mother? mother;
  List<MohClinic> clinics = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMother();
  }

  Future<void> _loadMother() async {
    final results = await Future.wait([
      DBHelper().getActiveMother(),
      FirebaseContentRepository.getMohClinics(),
    ]);

    if (!mounted) return;
    setState(() {
      mother = results[0] as Mother?;
      clinics = results[1] as List<MohClinic>;
      loading = false;
    });
  }

  Future<void> _openEditSheet() async {
    if (mother == null) return;
    final current = mother!;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return _MotherProfileForm(
          clinics: clinics,
          initialMother: current,
          title: context.l10n.editProfile,
          buttonLabel: context.l10n.save,
          onSaved: (updated) async {
            await DBHelper().saveMother(updated);
            if (!mounted) return;
            setState(() => mother = updated);
            Navigator.pop(sheetContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.profileUpdated)),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.motherProfile),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : mother == null
            ? _FirstRunSetupForm(
                clinics: clinics,
                onSaved: (created) => setState(() => mother = created),
              )
            : _buildProfileView(mother!),
      ),
    );
  }

  Widget _buildProfileView(Mother mother) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mother.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.17),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        mother.mohArea,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              InfoRow(
                icon: Icons.phone_rounded,
                label: context.l10n.phone,
                value: mother.phone,
              ),
              InfoRow(
                icon: Icons.home_rounded,
                label: context.l10n.address,
                value: mother.address,
              ),
              InfoRow(
                icon: Icons.map_rounded,
                label: context.l10n.mohArea,
                value: mother.mohArea,
              ),
              InfoRow(
                icon: Icons.local_hospital_rounded,
                label: context.l10n.nearestClinic,
                value: mother.nearestClinic,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openEditSheet,
            icon: const Icon(Icons.edit_rounded),
            label: Text(context.l10n.editProfile),
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
    );
  }
}

class _FirstRunSetupForm extends StatelessWidget {
  final List<MohClinic> clinics;
  final void Function(Mother created) onSaved;

  const _FirstRunSetupForm({required this.clinics, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return _MotherProfileForm(
      clinics: clinics,
      title: context.l10n.setUpYourProfile,
      buttonLabel: context.l10n.saveProfile,
      onSaved: (mother) async {
        final id = await DBHelper().insertMother(mother);
        onSaved(mother.copyWith(id: id));
      },
    );
  }
}

class _MotherProfileForm extends StatefulWidget {
  final List<MohClinic> clinics;
  final Mother? initialMother;
  final String title;
  final String buttonLabel;
  final Future<void> Function(Mother mother) onSaved;

  const _MotherProfileForm({
    required this.clinics,
    required this.title,
    required this.buttonLabel,
    required this.onSaved,
    this.initialMother,
  });

  @override
  State<_MotherProfileForm> createState() => _MotherProfileFormState();
}

class _MotherProfileFormState extends State<_MotherProfileForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  String? selectedMohArea;
  String? selectedClinic;
  bool saving = false;

  List<String> get mohAreas {
    final areas = widget.clinics
        .map((clinic) => clinic.mohArea)
        .where((area) => area.trim().isNotEmpty)
        .toSet()
        .toList();
    areas.sort();
    return areas;
  }

  List<MohClinic> get selectedAreaClinics {
    final area = selectedMohArea;
    if (area == null) return const [];
    return widget.clinics.where((clinic) => clinic.mohArea == area).toList();
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMother;
    nameController = TextEditingController(text: initial?.name ?? '');
    phoneController = TextEditingController(text: initial?.phone ?? '');
    addressController = TextEditingController(text: initial?.address ?? '');
    selectedMohArea = _matchingArea(initial?.mohArea);
    selectedClinic = _matchingClinic(initial?.nearestClinic);

    if (selectedMohArea != null &&
        selectedClinic == null &&
        selectedAreaClinics.length == 1) {
      selectedClinic = selectedAreaClinics.first.name;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String? _matchingArea(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    for (final area in mohAreas) {
      if (area.toLowerCase() == raw.trim().toLowerCase()) return area;
    }
    return raw.trim();
  }

  String? _matchingClinic(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    for (final clinic in widget.clinics) {
      if (clinic.name.toLowerCase() == raw.trim().toLowerCase()) {
        return clinic.name;
      }
    }
    return raw.trim();
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);

    final initial = widget.initialMother;
    final mother = Mother(
      id: initial?.id,
      name: nameController.text.trim(),
      nic: '',
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      mohArea: selectedMohArea?.trim() ?? '',
      nearestClinic: selectedClinic?.trim() ?? '',
      photoUrl: initial?.photoUrl,
    );

    await widget.onSaved(mother);
    if (mounted) setState(() => saving = false);
  }

  void _selectArea(String? area) {
    setState(() {
      selectedMohArea = area;
      final options = selectedAreaClinics;
      selectedClinic = options.length == 1 ? options.first.name : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasClinics = widget.clinics.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: bottomInset + 18,
      ),
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
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
                              widget.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              context.l10n.motherSetupMessage,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    controller: nameController,
                    label: context.l10n.fullName,
                    icon: Icons.person_rounded,
                  ),
                  _buildField(
                    controller: phoneController,
                    label: context.l10n.phone,
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildField(
                    controller: addressController,
                    label: context.l10n.address,
                    icon: Icons.home_rounded,
                    maxLines: 2,
                  ),
                  _buildMohAreaDropdown(hasClinics),
                  _buildClinicDropdown(hasClinics),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    child: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.buttonLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) => (value == null || value.trim().isEmpty)
            ? context.l10n.required
            : null,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  Widget _buildMohAreaDropdown(bool hasClinics) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: DropdownButtonFormField<String>(
        value: mohAreas.contains(selectedMohArea) ? selectedMohArea : null,
        isExpanded: true,
        items: mohAreas
            .map((area) => DropdownMenuItem(value: area, child: Text(area)))
            .toList(),
        onChanged: hasClinics ? _selectArea : null,
        validator: (value) => (value == null || value.trim().isEmpty)
            ? context.l10n.required
            : null,
        decoration: _inputDecoration(context.l10n.mohArea, Icons.map_rounded),
      ),
    );
  }

  Widget _buildClinicDropdown(bool hasClinics) {
    final names = selectedAreaClinics
        .map((clinic) => clinic.name)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: DropdownButtonFormField<String>(
        value: names.contains(selectedClinic) ? selectedClinic : null,
        isExpanded: true,
        items: names
            .map((name) => DropdownMenuItem(value: name, child: Text(name)))
            .toList(),
        onChanged: hasClinics && selectedMohArea != null
            ? (value) => setState(() => selectedClinic = value)
            : null,
        validator: (value) => (value == null || value.trim().isEmpty)
            ? context.l10n.required
            : null,
        decoration: _inputDecoration(
          context.l10n.nearestClinic,
          Icons.local_hospital_rounded,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: const Color(0xFFF7F8FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.overdue.withValues(alpha: 0.7)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.overdue, width: 1.4),
      ),
    );
  }
}
