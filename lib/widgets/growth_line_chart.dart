import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GrowthLineChart extends StatelessWidget {
  final List<String> xLabels;
  final List<double> values;
  final String unit;
  final Color? lineColor;
  final double height;

  const GrowthLineChart({
    super.key,
    required this.xLabels,
    required this.values,
    required this.unit,
    this.lineColor,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = lineColor ?? AppColors.primary;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(
          values: values,
          xLabels: xLabels,
          lineColor: resolvedColor,
        ),
        child: Container(),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> xLabels;
  final Color lineColor;

  _LineChartPainter({
    required this.values,
    required this.xLabels,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const bottomPadding = 24.0;
    const topPadding = 24.0;
    final chartHeight = size.height - bottomPadding - topPadding;

    final minVal = values.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxVal = values.reduce((a, b) => a > b ? a : b) * 1.1;
    final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    final isSinglePoint = values.length == 1;
    final stepX = values.length > 1 ? size.width / (values.length - 1) : 0.0;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = isSinglePoint ? size.width / 2 : stepX * i;
      final normalized = (values[i] - minVal) / range;
      final y = topPadding + chartHeight - (normalized * chartHeight);
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final fillPath = Path()
        ..moveTo(points.first.dx, topPadding + chartHeight);
      for (final p in points) {
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath.lineTo(points.last.dx, topPadding + chartHeight);
      fillPath.close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lineColor.withOpacity(0.18), lineColor.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight));
      canvas.drawPath(fillPath, fillPaint);

      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        linePath.lineTo(p.dx, p.dy);
      }
      final linePaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(linePath, linePaint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < points.length; i++) {
      final p = points[i];

      canvas.drawCircle(p, 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        4.5,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      textPainter.text = TextSpan(
        text: values[i].toStringAsFixed(1),
        style: TextStyle(
          fontSize: 10,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(p.dx - textPainter.width / 2, p.dy - 18),
      );

      if (i < xLabels.length) {
        textPainter.text = TextSpan(
          text: xLabels[i],
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(p.dx - textPainter.width / 2, size.height - bottomPadding + 6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
