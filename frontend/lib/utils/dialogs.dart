import 'package:envolet_frontend/providers/session_provider.dart';
import 'package:envolet_frontend/providers/settings_provider.dart';
import 'package:envolet_frontend/screens/auth/login_page.dart';
import 'package:envolet_frontend/utils/formatters.dart';
import 'package:envolet_frontend/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

const _accentBlue = Color(0xFF2D6BFF);

/// Reusable alerts, confirmation dialogs and bottom sheets.
class AppDialogs {
  AppDialogs._();

  static Future<void> showSuccess(
    BuildContext context,
    String message, {
    String? title,
    String confirmText = 'Continue',
  }) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: title,
      text: message,
      confirmBtnText: confirmText,
      confirmBtnColor: _accentBlue,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      titleColor: Colors.black,
      textColor: Colors.black54,
      confirmBtnTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  static Future<void> showError(
    BuildContext context,
    String message, {
    String title = 'Error',
  }) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: title,
      text: message,
      confirmBtnText: 'Try Again',
      confirmBtnColor: Colors.red,
      backgroundColor: Colors.white,
      titleColor: Colors.black,
      textColor: Colors.black87,
    );
  }

  static void showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ConfirmationDialog(
        icon: Icons.warning,
        iconColor: Colors.orange,
        message: 'Are you sure you want to sign out?',
        confirmText: 'Confirm',
        confirmColor: Colors.blue,
        onConfirm: () async {
          await context.read<SessionProvider>().logout();
          if (context.mounted) resetTo(context, const LoginPage());
        },
      ),
    );
  }

  static void showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ConfirmationDialog(
        icon: Icons.delete_outline,
        iconColor: Colors.red,
        title: 'Deleting your account',
        message:
            'Are you sure you want to delete your account?\nThis action cannot be undone.',
        confirmText: 'Delete',
        confirmColor: Colors.red,
        requireCheckbox: true,
        onConfirm: () async {
          try {
            await context.read<SessionProvider>().deleteAccount();
            if (context.mounted) resetTo(context, const LoginPage());
          } on Exception {
            if (context.mounted) {
              Navigator.of(dialogContext).pop();
              showError(context, 'Could not delete your account.');
            }
          }
        },
      ),
    );
  }

  /// Confirmation sheet shown after a transaction was created or updated.
  static void showTransactionSaved(
    BuildContext context, {
    required bool isUpdate,
    required String category,
    required double amount,
    required DateTime date,
  }) {
    final currency = context.read<SettingsProvider>().currency;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFF00C851),
              child: Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              isUpdate ? 'Transaction Updated!' : 'Transaction Successful',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isUpdate
                  ? 'Your expense has been updated!'
                  : 'Your expense has been recorded!',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _InfoRow('Date', DateFormat('dd MMM, yyyy').format(date)),
            const SizedBox(height: 12),
            _InfoRow('Category', category),
            const SizedBox(height: 12),
            _InfoRow('Amount', '${formatAmount(amount)} $currency'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ConfirmationDialog extends StatefulWidget {
  const _ConfirmationDialog({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirm,
    this.title,
    this.requireCheckbox = false,
  });

  final IconData icon;
  final MaterialColor iconColor;
  final String? title;
  final String message;
  final String confirmText;
  final Color confirmColor;
  final Future<void> Function() onConfirm;
  final bool requireCheckbox;

  @override
  State<_ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<_ConfirmationDialog> {
  bool _checked = false;
  bool _busy = false;

  bool get _canConfirm => !_busy && (!widget.requireCheckbox || _checked);

  Future<void> _confirm() async {
    setState(() => _busy = true);
    await widget.onConfirm();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    const buttonSize = Size(double.infinity, 48);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: widget.iconColor.shade100,
                child: Icon(widget.icon, color: widget.iconColor),
              ),
            ),
            const SizedBox(height: 20),
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.title == null ? 16 : 14,
                fontWeight:
                    widget.title == null ? FontWeight.w600 : FontWeight.normal,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _canConfirm ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.confirmColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: buttonShape,
                minimumSize: buttonSize,
              ),
              child: Text(
                widget.confirmText,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                shape: buttonShape,
                minimumSize: buttonSize,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            if (widget.requireCheckbox) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _checked,
                    onChanged: (value) =>
                        setState(() => _checked = value ?? false),
                  ),
                  const Text('I am sure.'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
