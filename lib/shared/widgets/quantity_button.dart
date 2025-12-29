import 'package:flutter/material.dart';
import 'package:orderly/config/themes.dart';

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const QuantityButton({super.key, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(icon, size: 16, color: AppColors.cSlate600)));
  }
}