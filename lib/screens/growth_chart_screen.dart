import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../models/growth_record.dart';
import '../database/db_helper.dart';
import '../widgets/growth_line_chart.dart';
import '../widgets/app_top_bar.dart';

class GrowthChartScreen extends StatefulWidget {
  final int babyId;

  const GrowthChartScreen({super.key, required this.babyId});

  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen> {
  GrowthMetric _selectedMetric = GrowthMetric.weight;
  bool _loading = true;
  List<GrowthRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _loading = true);
    final records = await DBHelper().getGrowthRecordsForBaby(widget.babyId);
    if (!mounted) return;
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  Future<void> _openAddEntrySheet() async {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime pickedDate = DateTime.now();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
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
                      Text(
                        'Add Growth Entry',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: sheetContext,
                            initialDate: pickedDate,
                            firstDate: DateTime(2015),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setSheetState(() => pickedDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: context.l10n.date,
                            filled: true,
                            fillColor: AppColors.elevatedSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.divider),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.divider),
                            ),
                          ),
                          child: Text(
                            context.formatNumericDate(pickedDate),
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.weightKg,
                          filled: true,
                          fillColor: AppColors.elevatedSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return context.l10n.required;
                          if (double.tryParse(value.trim()) == null)
                            return context.l10n.invalidNumber;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.heightCm,
                          filled: true,
                          fillColor: AppColors.elevatedSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return context.l10n.required;
                          if (double.tryParse(value.trim()) == null)
                            return context.l10n.invalidNumber;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => saving = true);

                                final record = GrowthRecord(
                                  babyId: widget.babyId,
                                  recordedDate: pickedDate,
                                  weightKg: double.parse(
                                    weightController.text.trim(),
                                  ),
                                  heightCm: double.parse(
                                    heightController.text.trim(),
                                  ),
                                );
                                await DBHelper().insertGrowthRecord(record);

                                if (!mounted) return;
                                Navigator.pop(sheetContext);
                                _loadRecords();
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
                            : Text(context.l10n.saveEntry),
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

  @override
  Widget build(BuildContext context) {
    final labels = _records.map((r) => r.label).toList();
    final values = _records.map((r) {
      switch (_selectedMetric) {
        case GrowthMetric.weight:
          return r.weightKg;
        case GrowthMetric.height:
          return r.heightCm;
        case GrowthMetric.bmi:
          return r.bmi;
      }
    }).toList();

    final unit = switch (_selectedMetric) {
      GrowthMetric.weight => 'kg',
      GrowthMetric.height => 'cm',
      GrowthMetric.bmi => '',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.growthChart),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntrySheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _metricChip(
                          context.l10n.weight,
                          GrowthMetric.weight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _metricChip(
                          context.l10n.height,
                          GrowthMetric.height,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _metricChip(context.l10n.bmi, GrowthMetric.bmi),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          context.l10n.noGrowthRecordsYet,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: GrowthLineChart(
                        xLabels: labels,
                        values: values,
                        unit: unit,
                        height: 220,
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (_records.isNotEmpty) ...[
                    Text(
                      context.l10n.allEntries,
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 10),
                    ..._records.reversed.map((r) => _buildEntryTile(r)),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildEntryTile(GrowthRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.formatNumericDate(record.recordedDate),
              style: AppTextStyles.cardTitle,
            ),
          ),
          Text('${record.weightKg} kg', style: AppTextStyles.subtitle),
          const SizedBox(width: 10),
          Text('${record.heightCm} cm', style: AppTextStyles.subtitle),
          IconButton(
            onPressed: () async {
              if (record.id != null) {
                await DBHelper().deleteGrowthRecord(record.id!);
                _loadRecords();
              }
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, GrowthMetric metric) {
    final isSelected = _selectedMetric == metric;
    return InkWell(
      onTap: () => setState(() => _selectedMetric = metric),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
