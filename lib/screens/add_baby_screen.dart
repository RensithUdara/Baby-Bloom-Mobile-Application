import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../l10n/l10n.dart';
import '../models/baby.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import 'home_screen.dart';

class AddBabyScreen extends StatefulWidget {
  final Baby? babyToEdit;

  const AddBabyScreen({super.key, this.babyToEdit});

  bool get isEditing => babyToEdit != null;

  @override
  State<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends State<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _hospitalController;

  DateTime? _dob;
  String _gender = 'female';
  String? _bloodGroup;
  bool _saving = false;

  static const _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    final baby = widget.babyToEdit;

    _nameController = TextEditingController(text: baby?.name ?? '');
    _weightController = TextEditingController(
      text: baby?.birthWeightKg != null ? baby!.birthWeightKg.toString() : '',
    );
    _hospitalController = TextEditingController(text: baby?.hospital ?? '');

    _dob = baby?.dob;
    _gender = baby?.gender ?? 'female';
    _bloodGroup = baby?.bloodGroup;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? now,
      firstDate: DateTime(now.year - 15),
      lastDate: now,
      helpText: context.l10n.selectDateOfBirth,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.pleaseSelectDob)));
      return;
    }

    setState(() => _saving = true);

    final baby = Baby(
      id: widget.babyToEdit?.id,
      name: _nameController.text.trim(),
      dob: _dob!,
      gender: _gender,
      photoPath: widget.babyToEdit?.photoPath,
      bloodGroup: _bloodGroup,
      birthWeightKg: _weightController.text.trim().isEmpty
          ? null
          : double.tryParse(_weightController.text.trim()),
      hospital: _hospitalController.text.trim().isEmpty
          ? null
          : _hospitalController.text.trim(),
    );

    try {
      if (widget.isEditing) {
        await DBHelper().updateBaby(baby);
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        await DBHelper().insertBaby(baby);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.somethingWentWrong(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: widget.isEditing ? l10n.editBaby : l10n.addBaby),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.basicDetails, style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(
                        l10n.babyName,
                        Icons.child_care_rounded,
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? l10n.pleaseEnterName
                          : null,
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickDob,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          l10n.dateOfBirth,
                          Icons.cake_rounded,
                        ),
                        child: Text(
                          _dob == null
                              ? l10n.selectDate
                              : context.formatNumericDate(_dob!),
                          style: TextStyle(
                            color: _dob == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _genderChip(
                            'female',
                            l10n.female,
                            Icons.female_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _genderChip(
                            'male',
                            l10n.male,
                            Icons.male_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.additionalDetailsOptional,
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _bloodGroup,
                      decoration: _inputDecoration(
                        l10n.bloodGroup,
                        Icons.bloodtype_rounded,
                      ),
                      items: _bloodGroups
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _bloodGroup = value),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration(
                        l10n.birthWeightKg,
                        Icons.monitor_weight_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _hospitalController,
                      decoration: _inputDecoration(
                        l10n.hospital,
                        Icons.local_hospital_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isEditing ? l10n.updateBaby : l10n.saveBaby,
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderChip(String value, String label, IconData icon) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () => setState(() => _gender = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
