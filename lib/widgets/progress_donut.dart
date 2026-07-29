import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressDonut extends StatelessWidget {
  final int completed;
  final int pending;
  final int overdue;
  final double size;

  const ProgressDonut({
    super.key,
    required this.completed,
    required this.pending,
    required this.overdue,
    this.size = 120,
  });

  int get total => completed + pending + overdue;

  int get percent => total == 0 ? 0 : ((completed / total) * 100).round();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(
              completed: completed,
              pending: pending,
              overdue: overdue,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: size * 0.2,
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
}

class _DonutPainter extends CustomPainter {
  final int completed;
  final int pending;
  final int overdue;

  _DonutPainter({
    required this.completed,
    required this.pending,
    required this.overdue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = completed + pending + overdue;
    final strokeWidth = size.width * 0.16;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    if (total == 0) {
      final bgPaint = Paint()
        ..color = AppColors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, 0, 6.283, false, bgPaint);
      return;
    }

    double startAngle = -1.5708;
    final slices = [
      _Slice(completed, AppColors.completed),
      _Slice(pending, AppColors.pending),
      _Slice(overdue, AppColors.overdue),
    ];

    for (final slice in slices) {
      if (slice.value == 0) continue;
      final sweep = (slice.value / total) * 6.283185307;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep * 0.96, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.completed != completed ||
        oldDelegate.pending != pending ||
        oldDelegate.overdue != overdue;
  }
}

class _Slice {
  final int value;
  final Color color;
  _Slice(this.value, this.color);
}
