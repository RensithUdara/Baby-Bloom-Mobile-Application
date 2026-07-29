import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n.dart';
import '../models/baby.dart';
import '../models/vaccine.dart';
import '../models/reminder.dart';
import '../theme/app_theme.dart';
import '../database/db_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/section_card.dart';
import '../widgets/empty_baby_state.dart';
import '../widgets/app_top_bar.dart';
import '../utils/vaccine_extensions.dart';
import 'home_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _UpcomingEntry {
  final DateTime date;
  final Vaccine? vaccine;
  final Reminder? reminder;

  _UpcomingEntry.vaccine(Vaccine v)
    : date = v.dueDate,
      vaccine = v,
      reminder = null;

  _UpcomingEntry.reminder(Reminder r)
    : date = r.date,
      vaccine = null,
      reminder = r;
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _loading = true;
  Baby? _baby;
  List<Vaccine> _vaccines = [];
  List<Reminder> _reminders = [];
  DateTime _visibleMonth = DateTime.now();

  static const _monthLabels = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final baby = await DBHelper().getActiveBaby();
    List<Vaccine> vaccines = [];
    if (baby != null && baby.id != null) {
      vaccines = await DBHelper().getVaccinesForBaby(baby.id!);
    }
    final reminders = await DBHelper().getAllReminders();
    if (!mounted) return;
    setState(() {
      _baby = baby;
      _vaccines = vaccines;
      _reminders = reminders;

      _visibleMonth = vaccines.isNotEmpty
          ? DateTime(vaccines.first.dueDate.year, vaccines.first.dueDate.month)
          : DateTime(DateTime.now().year, DateTime.now().month);
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  List<DateTime?> _buildGridDays() {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leadingBlanks = firstOfMonth.weekday % 7;

    final days = <DateTime?>[];
    for (int i = 0; i < leadingBlanks; i++) {
      days.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      days.add(DateTime(_visibleMonth.year, _visibleMonth.month, d));
    }
    return days;
  }

  VaccineStatus? _statusForDay(DateTime day) {
    for (final v in _vaccines) {
      if (v.dueDate.year == day.year &&
          v.dueDate.month == day.month &&
          v.dueDate.day == day.day) {
        return v.uiStatus;
      }
    }
    return null;
  }

  Future<void> _openAddReminderSheet() async {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime pickedDate = DateTime.now();
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
                        'Add Reminder',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: context.l10n.reminderTitle,
                          hintText: context.l10n.reminderHint,
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return context.l10n.required;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: sheetContext,
                            initialDate: pickedDate,
                            firstDate: DateTime(2015),
                            lastDate: DateTime(2100),
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
                            fillColor: const Color(0xFFF7F7F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          child: Text(context.formatNumericDate(pickedDate)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => saving = true);

                                final reminder = Reminder(
                                  title: titleController.text.trim(),
                                  date: pickedDate,
                                );
                                await DBHelper().insertReminder(reminder);

                                if (!mounted) return;
                                Navigator.pop(sheetContext);
                                _loadData();
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
                            : Text(context.l10n.saveReminder),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopBar(title: context.l10n.calendar, onBack: _goHome),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _baby == null
            ? const EmptyBabyState()
            : _buildContent(),
        bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      ),
    );
  }

  void _goHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Widget _buildContent() {
    final days = _buildGridDays();
    final today = DateTime.now();

    final combined = <_UpcomingEntry>[
      ..._vaccines.map((v) => _UpcomingEntry.vaccine(v)),
      ..._reminders.map((r) => _UpcomingEntry.reminder(r)),
    ]..sort((a, b) => a.date.compareTo(b.date));

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Text(
                      '${_monthLabels[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                      style: AppTextStyles.sectionTitle,
                    ),
                    IconButton(
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: context.weekdayShortNames
                      .map(
                        (label) => Expanded(
                          child: Center(
                            child: Text(label, style: AppTextStyles.subtitle),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 6),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: days.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    if (day == null) return const SizedBox.shrink();

                    final status = _statusForDay(day);
                    final isToday =
                        day.year == today.year &&
                        day.month == today.month &&
                        day.day == today.day;

                    Color? bg;
                    Color textColor = AppColors.textPrimary;
                    if (status != null) {
                      bg = status.color;
                      textColor = Colors.white;
                    } else if (isToday) {
                      bg = AppColors.completed;
                      textColor = Colors.white;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bg,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: status != null || isToday
                                ? FontWeight.w700
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(context.l10n.upcomingEvents, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          if (combined.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                context.l10n.noEventsYet,
                style: AppTextStyles.subtitle,
              ),
            )
          else
            ...combined.take(5).map((entry) {
              return entry.vaccine != null
                  ? _eventRow(entry.vaccine!)
                  : _reminderRow(entry.reminder!);
            }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openAddReminderSheet,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.addReminder),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _eventRow(Vaccine v) {
    final status = v.uiStatus;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: status.lightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  '${v.dueDate.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status.color,
                  ),
                ),
                Text(
                  DateFormat.MMM(context.l10n.localeName).format(v.dueDate),
                  style: TextStyle(fontSize: 11, color: status.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.vaccineName, style: AppTextStyles.cardTitle),
                Text(
                  context.formatShortDate(v.dueDate),
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: status.lightColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.vaccineStatusLabel(status),
              style: TextStyle(
                color: status.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reminderRow(Reminder r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  '${r.date.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  DateFormat.MMM(context.l10n.localeName).format(r.date),
                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title, style: AppTextStyles.cardTitle),
                Text(
                  context.formatNumericDate(r.date),
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              if (r.id != null) {
                await DBHelper().deleteReminder(r.id!);
                _loadData();
              }
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
