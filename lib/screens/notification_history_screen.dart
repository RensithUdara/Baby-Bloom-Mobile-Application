import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../database/db_helper.dart';
import '../widgets/app_top_bar.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _upcoming = [];
  List<Map<String, dynamic>> _past = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final all = await DBHelper().getNotificationHistory();
    final now = DateTime.now();

    final upcoming = <Map<String, dynamic>>[];
    final past = <Map<String, dynamic>>[];

    for (final item in all) {
      final scheduledDate = DateTime.parse(item['scheduledDate'] as String);
      if (scheduledDate.isAfter(now)) {
        upcoming.add(item);
      } else {
        past.add(item);
      }
    }

    final pastDescending = past.reversed.toList();

    if (!mounted) return;
    setState(() {
      _upcoming = upcoming;
      _past = pastDescending;
      _loading = false;
    });
  }

  String _formatDate(DateTime date) =>
      DateFormat.yMMMd(context.l10n.localeName).add_jm().format(date);

  @override
  Widget build(BuildContext context) {
    final isEmpty = _upcoming.isEmpty && _past.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.notificationHistory),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l10n.noNotificationsYet,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_upcoming.isNotEmpty) ...[
                    _sectionTitle(context.l10n.upcoming),
                    const SizedBox(height: 10),
                    ..._upcoming.map(
                      (item) => _buildTile(item, isUpcoming: true),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_past.isNotEmpty) ...[
                    _sectionTitle(context.l10n.history),
                    const SizedBox(height: 10),
                    ..._past.map((item) => _buildTile(item, isUpcoming: false)),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.sectionTitle);
  }

  Widget _buildTile(Map<String, dynamic> item, {required bool isUpcoming}) {
    final scheduledDate = DateTime.parse(item['scheduledDate'] as String);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUpcoming
                    ? AppColors.upcomingLight
                    : AppColors.pendingLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUpcoming
                    ? Icons.schedule_rounded
                    : Icons.notifications_rounded,
                color: isUpcoming ? AppColors.upcoming : AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] as String, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 2),
                  Text(item['body'] as String, style: AppTextStyles.subtitle),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(scheduledDate),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
