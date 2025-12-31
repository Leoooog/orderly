import 'package:flutter/material.dart';
import 'package:orderly/l10n/app_localizations.dart';
import 'package:orderly/modules/waiter/screens/orderly_colors.dart';

class SuccessView extends StatelessWidget {
  final String tableName;

  const SuccessView({super.key, required this.tableName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.sizeOf(context);

    // Logica semplice per determinare le dimensioni in base al dispositivo
    final isTablet = size.shortestSide > 600;

    // Dimensioni dinamiche
    final double iconSize = isTablet ? 64 : 48;
    final double circlePadding = isTablet ? 40 : 24;
    final double titleSize = isTablet ? 42 : 32;
    final double subTitleSize = isTablet ? 24 : 20;
    final double spacing = isTablet ? 32 : 24;

    return Scaffold(
      backgroundColor: colors.success,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, // Occupa almeno tutta l'altezza
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600), // Limite larghezza per Tablet/Desktop
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // Importante per il scroll view
                      children: [
                        // Icona
                        Container(
                          padding: EdgeInsets.all(circlePadding),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: iconSize,
                            color: colors.success,
                          ),
                        ),

                        SizedBox(height: spacing),

                        // Titolo (Order Sent)
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.msgOrderSent,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: colors.textInverse,
                              height: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Sottotitolo (Table Name)
                        Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.tableName(tableName),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: subTitleSize,
                                color: colors.successContainer, // O un colore che contrasta bene su sfondo verde
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}