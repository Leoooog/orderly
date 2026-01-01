import 'package:flutter/material.dart';
import 'package:orderly/config/orderly_colors.dart';

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const QuantityButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 16, color: colors.textSecondary),
        ),
      ),
    );
  }
}