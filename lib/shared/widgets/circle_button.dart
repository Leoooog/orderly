import 'package:flutter/material.dart';
import 'package:orderly/config/themes.dart';


class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool small;

  const CircularIconButton({super.key, required this.icon, required this.onTap, this.small = false});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cWhite,
            border: Border.all(color: AppColors.cSlate200),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))]
        ),
        child: Icon(icon, color: AppColors.cSlate800, size: small ? 24 : 32),
      ),
    );
  }
}