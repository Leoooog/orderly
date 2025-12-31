import 'package:flutter/material.dart';

class PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PaymentMethodButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcolo dimensioni dinamiche basate sull'altezza
        // Se l'altezza non è vincolata usa un valore di fallback
        final double h = constraints.maxHeight.isFinite ? constraints.maxHeight : 80.0;

        final double iconSize = h * 0.40;     // 40% dell'altezza
        final double fontSize = h * 0.16;     // 16% dell'altezza
        final double borderRadius = h * 0.20; // 20% dell'altezza

        return Material(
          color: color.withValues(alpha: 0.1),
          // RIMOSSO: borderRadius: BorderRadius.circular(borderRadius),
          // Motivo: Va in conflitto con 'shape'

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Icon(icon, size: iconSize, color: color),
                  const Spacer(flex: 1),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}