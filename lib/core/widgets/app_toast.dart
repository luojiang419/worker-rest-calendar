import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';

void showAppToast(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_outline_rounded,
}) {
  final tokens = context.tokens;
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(icon, color: tokens.colors.primary),
            SizedBox(width: tokens.spacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
