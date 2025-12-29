import 'package:flutter/material.dart';

import '../../../config/themes.dart';

class SuccessView extends StatelessWidget {
  final String tableName;

  const SuccessView({super.key, required this.tableName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.cEmerald500,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  color: AppColors.cWhite, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle,
                  size: 48, color: AppColors.cEmerald500)),
          const SizedBox(height: 24),
          const Text("Comanda Inviata!",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cWhite)),
          const SizedBox(height: 8),
          Text("Tavolo $tableName",
              style:
                  const TextStyle(fontSize: 20, color: AppColors.cEmerald100))
        ])));
  }
}
