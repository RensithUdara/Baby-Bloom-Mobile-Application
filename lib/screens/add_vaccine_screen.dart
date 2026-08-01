import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../l10n/l10n.dart';
import '../models/baby.dart';
import '../models/vaccine.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';

class AddVaccineScreen extends StatefulWidget {
  final Baby baby;

  const AddVaccineScreen({super.key, required this.baby});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController(text: '1');

  DateTime? _dueDate;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
      helpText: 'Select vaccine due date',
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.selectDate)));
      return;
    }

    setState(() => _saving = true);

    final vaccine = Vaccine(
      babyId: widget.baby.id!,
      vaccineName: _nameController.text.trim(),
      doseNumber: int.parse(_doseController.text.trim()),
      dueDate: _dueDate!,
      status: 'pending',
    );

    try {
      await DBHelper().insertVaccine(vaccine);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.somethingWentWrong('$error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Add Vaccine'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Custom vaccine', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        'Vaccine name',
                        Icons.vaccines_rounded,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.required
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _doseController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        'Dose number',
                        Icons.format_list_numbered_rounded,
                      ),
                      validator: (value) {
                        final dose = int.tryParse(value?.trim() ?? '');
                        if (dose == null || dose < 1) return l10n.invalidNumber;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickDueDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          l10n.dueDate,
                          Icons.event_rounded,
                        ),
                        child: Text(
                          _dueDate == null
                              ? l10n.selectDate
                              : context.formatNumericDate(_dueDate!),
                          style: TextStyle(
                            color: _dueDate == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
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
