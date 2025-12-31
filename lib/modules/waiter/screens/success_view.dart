import 'package:flutter/material.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/modules/waiter/screens/orderly_colors.dart';

class SuccessView extends StatelessWidget {
  final String tableName;

  const SuccessView({super.key, required this.tableName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
        backgroundColor: colors.success,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              padding: const EdgeInsets.all(24),
              decoration:
                  BoxDecoration(color: colors.surface, shape: BoxShape.circle),
              child: Icon(Icons.check_circle, size: 48, color: colors.success)),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context)!.msgOrderSent,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors.textInverse)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.tableName(tableName),
              style: TextStyle(fontSize: 20, color: colors.successContainer))
        ])));
  }
}
