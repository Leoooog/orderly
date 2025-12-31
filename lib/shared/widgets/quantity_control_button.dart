import 'package:flutter/material.dart';
import 'package:orderly/config/themes.dart';

class QuantityControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const QuantityControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // LOGICA RESPONSIVE ROBUSTA
        // 1. Cerchiamo di prendere l'altezza dal genitore (se esiste ed è fissa)
        double size = constraints.maxHeight;

        // 2. Se l'altezza non è definita (es. dentro una Row flessibile o ListView),
        // il valore sarebbe "infinito" e causerebbe il crash.
        // In quel caso, calcoliamo la dimensione in base alla larghezza dello schermo.
        if (!constraints.hasBoundedHeight || size == double.infinity) {
          final screenWidth = MediaQuery.of(context).size.width;
          // Il bottone sarà circa il 12% della larghezza schermo (responsive)
          // Con dei limiti min/max per non diventare ridicolo su tablet o schermi piccoli
          size = (screenWidth * 0.05).clamp(36.0, 64.0);
        }

        // Calcoli proporzionali basati sulla dimensione finale sicura 'size'
        final double iconSize = size * 0.5;

        // Usiamo SizedBox per forzare le dimensioni quadrate (sostituisce AspectRatio)
        return SizedBox(
          width: size,
          height: size,
          child: Opacity(
            opacity: isActive ? 1.0 : 0.5,
            child: InkWell(
              onTap: isActive ? onTap : null,
              customBorder: CircleBorder(),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: AppColors.cSlate600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}