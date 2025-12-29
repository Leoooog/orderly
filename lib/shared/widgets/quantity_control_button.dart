import 'package:flutter/material.dart';
import 'package:orderly/config/themes.dart';

class QuantityControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const QuantityControlButton({super.key, required this.icon, required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cSlate100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cSlate200),
        ),
        child: Icon(icon, size: 16, color: AppColors.cSlate600),
      ),
    );
  }
}