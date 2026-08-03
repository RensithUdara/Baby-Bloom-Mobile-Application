import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  IconData icon = Icons.help_rounded,
  Color? confirmColor,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.58),
    builder: (context) {
      final actionColor = confirmColor ?? AppColors.primary;
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: _ConfirmDialogCard(
            title: title,
            message: message,
            cancelLabel: cancelLabel,
            confirmLabel: confirmLabel,
            icon: icon,
            actionColor: actionColor,
          ),
        ),
      );
    },
  );
}

class _ConfirmDialogCard extends StatelessWidget {
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final IconData icon;
  final Color actionColor;

  const _ConfirmDialogCard({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.icon,
    required this.actionColor,
  });

  static const _undoWarning = 'This action cannot be undone.';

  bool get _usesWarningPanel =>
      title.toLowerCase().contains('mark') && message.contains(_undoWarning);

  @override
  Widget build(BuildContext context) {
    final baseMessage = _usesWarningPanel
        ? message.replaceAll(_undoWarning, '').trim()
        : message;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconHeader(icon: icon, color: actionColor),
          const SizedBox(height: 12),
          _DialogTitle(title: title, color: actionColor),
          const SizedBox(height: 8),
          _DialogMessage(message: baseMessage, color: actionColor),
          if (_usesWarningPanel) ...[
            const SizedBox(height: 12),
            _WarningPanel(color: actionColor, message: _undoWarning),
          ],
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          _DialogActions(
            cancelLabel: cancelLabel,
            confirmLabel: confirmLabel,
            icon: icon,
            color: actionColor,
          ),
        ],
      ),
    );
  }
}

class _IconHeader extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconHeader({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 14, top: 15, child: _DecorMark(color: color)),
          Positioned(right: 14, top: 20, child: _DecorMark(color: color)),
          Positioned(left: 28, bottom: 12, child: _DecorDot(color: color)),
          Positioned(right: 30, bottom: 12, child: _DecorDot(color: color)),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ],
      ),
    );
  }
}

class _DecorDot extends StatelessWidget {
  final Color color;

  const _DecorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.72), width: 1.8),
      ),
    );
  }
}

class _DecorMark extends StatelessWidget {
  final Color color;

  const _DecorMark({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.add_rounded,
      color: color.withValues(alpha: 0.70),
      size: 14,
    );
  }
}

class _DialogTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _DialogTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final primaryStyle = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 22,
      fontWeight: FontWeight.w900,
      height: 1.12,
    );
    final accentStyle = primaryStyle.copyWith(color: color);
    final lowerTitle = title.toLowerCase();

    if (lowerTitle == 'mark vaccine as done?') {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Mark vaccine ', style: primaryStyle),
            TextSpan(text: 'as done?', style: accentStyle),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    if (lowerTitle == 'delete baby profile?') {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Delete ', style: primaryStyle),
            TextSpan(text: 'baby profile?', style: accentStyle),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    return Text(title, textAlign: TextAlign.center, style: primaryStyle);
  }
}

class _DialogMessage extends StatelessWidget {
  final String message;
  final Color color;

  const _DialogMessage({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    final normalStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.45,
    );
    final accentStyle = normalStyle.copyWith(
      color: color,
      fontWeight: FontWeight.w800,
    );

    final vaccineMatch = RegExp(
      r'^Are you sure (.+) has received this vaccine\?$',
    ).firstMatch(message);
    if (vaccineMatch != null) {
      final name = vaccineMatch.group(1)!;
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Are you sure ', style: normalStyle),
            TextSpan(text: name, style: accentStyle),
            TextSpan(text: ' has received this vaccine?', style: normalStyle),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    final undoIndex = message.indexOf(_ConfirmDialogCard._undoWarning);
    if (undoIndex >= 0) {
      final before = message.substring(0, undoIndex).trimRight();
      final warning = message.substring(undoIndex);
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: before, style: normalStyle),
            const TextSpan(text: ' '),
            TextSpan(text: warning, style: accentStyle),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    return Text(message, textAlign: TextAlign.center, style: normalStyle);
  }
}

class _WarningPanel extends StatelessWidget {
  final Color color;
  final String message;

  const _WarningPanel({required this.color, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final String cancelLabel;
  final String confirmLabel;
  final IconData icon;
  final Color color;

  const _DialogActions({
    required this.cancelLabel,
    required this.confirmLabel,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedButtons = constraints.maxWidth < 250;
        final buttons = [
          _DialogButton(
            label: cancelLabel,
            icon: Icons.close_rounded,
            color: AppColors.textSecondary,
            outlined: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          _DialogButton(
            label: confirmLabel,
            icon: icon,
            color: color,
            outlined: false,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ];

        if (useStackedButtons) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buttons[0], const SizedBox(height: 12), buttons[1]],
          );
        }

        return Row(
          children: [
            Expanded(child: buttons[0]),
            const SizedBox(width: 10),
            Expanded(child: buttons[1]),
          ],
        );
      },
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onPressed;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.outlined,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Material(
      color: outlined ? Colors.transparent : color,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: outlined
                ? Border.all(color: AppColors.divider, width: 1.3)
                : null,
            gradient: outlined
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.88), color],
                  ),
            boxShadow: outlined
                ? null
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: outlined ? color : Colors.white, size: 18),
              const SizedBox(width: 7),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: outlined ? color : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
