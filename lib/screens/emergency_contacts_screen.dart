import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/national_emergency_numbers.dart';
import '../l10n/l10n.dart';
import '../database/db_helper.dart';
import '../models/emergency_contact.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<EmergencyContact> contacts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final result = await DBHelper().getAllEmergencyContacts();
    setState(() {
      contacts = result;
      loading = false;
    });
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.couldNotOpenDialer)));
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.removeContactQuestion),
        content: Text(context.l10n.removeContactMessage(contact.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.remove,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || contact.id == null) return;

    await DBHelper().deleteEmergencyContact(contact.id!);
    _loadContacts();
  }

  Future<void> _openAddContactSheet() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add Emergency Contact',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildField(nameController, context.l10n.name),
                      _buildField(
                        phoneController,
                        context.l10n.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildField(
                        relationController,
                        context.l10n.relationHint,
                        required: false,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => saving = true);

                                await DBHelper().insertEmergencyContact(
                                  EmergencyContact(
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    relation:
                                        relationController.text.trim().isEmpty
                                        ? null
                                        : relationController.text.trim(),
                                  ),
                                );

                                if (!mounted) return;
                                Navigator.pop(sheetContext);
                                _loadContacts();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
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
                            : Text(context.l10n.saveContact),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: required
            ? (value) => (value == null || value.trim().isEmpty)
                  ? context.l10n.required
                  : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF7F7F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.emergencyContacts),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddContactSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                children: [
                  const Text(
                    'National Emergency Numbers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...NationalEmergencyNumbersData.numbers.map(
                    (n) => _buildTile(
                      icon: n.icon,
                      title: n.label,
                      subtitle: n.phone,
                      onCall: () => _call(n.phone),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Emergency Contacts',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (contacts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        context.l10n.noPersonalContacts,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  else
                    ...contacts.map(
                      (c) => _buildTile(
                        icon: Icons.contact_phone_rounded,
                        title: c.name,
                        subtitle: c.relation != null ? ' ? ' : c.phone,
                        onCall: () => _call(c.phone),
                        onDelete: () => _deleteContact(c),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onCall,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.subtitle),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ),
          IconButton(
            onPressed: onCall,
            icon: Icon(Icons.call_rounded, color: AppColors.primary),
            style: IconButton.styleFrom(backgroundColor: AppColors.softSurface),
          ),
        ],
      ),
    );
  }
}
