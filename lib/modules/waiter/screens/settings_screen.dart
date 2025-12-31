import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import '../../../config/themes.dart';
import '../../../data/hive_keys.dart';
import '../providers/tables_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.cSlate50,
      appBar: AppBar(
        title: const Text("Impostazioni", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.cWhite,
        foregroundColor: AppColors.cSlate900,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Generali"),
          _buildTile(
            icon: Icons.print,
            title: "Stampante Cucina",
            subtitle: "192.168.1.200 (Mock)",
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.language,
            title: "Lingua",
            subtitle: "Italiano",
            onTap: () {},
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Dati & Manutenzione"),
          _buildTile(
            icon: Icons.delete_forever,
            title: "Reset Database",
            subtitle: "Cancella tutti i tavoli e ordini e ripristina i dati iniziali",
            iconColor: AppColors.cRose500,
            textColor: AppColors.cRose500,
            onTap: () => _showResetDialog(context, ref),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Info"),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Orderly Pocket v1.0.0", style: TextStyle(color: AppColors.cSlate400, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.cIndigo600, fontSize: 13)),
    );
  }

  Widget _buildTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap, Color iconColor = AppColors.cSlate600, Color textColor = AppColors.cSlate900}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.cSlate400)) : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.cSlate300),
        onTap: onTap,
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cWhite,
        title: const Text("Reset Dati"),
        content: const Text("Sei sicuro? Tutti gli ordini aperti verranno persi."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cRose500, foregroundColor: Colors.white),
            onPressed: () async {
              // 1. Cancella il contenuto del box Hive
              final box = Hive.box(kTablesBox);
              await box.clear();

              // 2. Invalida il provider per forzare la ricarica (che rileggerà i mock data visto che il box è vuoto)
              ref.invalidate(tablesProvider);

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Database ripristinato ai dati iniziali!")));
            },
            child: const Text("Conferma Reset"),
          ),
        ],
      ),
    );
  }
}