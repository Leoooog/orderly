import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:orderly/data/hive_keys.dart';
import '../../../config/themes.dart';
import '../providers/tables_provider.dart';
import '../providers/locale_provider.dart'; // Importa il provider lingua

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leggi la lingua corrente per mostrarla nel sottotitolo
    final currentLocale = ref.watch(localeProvider);
    final String languageName = currentLocale.languageCode == 'it' ? 'Italiano' : 'English';

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
          _buildSectionHeader("Dispositivo"),
          _buildTile(
            icon: Icons.smartphone,
            title: "ID Terminale",
            subtitle: "W-01 (Autorizzato)",
            onTap: () {},
            iconColor: AppColors.cIndigo600,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Preferenze"),

          // TILE LINGUA ATTIVO
          _buildTile(
            icon: Icons.language,
            title: "Lingua",
            subtitle: languageName, // Mostra la lingua attuale
            onTap: () => _showLanguageDialog(context, ref),
          ),

          _buildTile(
            icon: Icons.dark_mode_outlined,
            title: "Tema",
            subtitle: "Chiaro (Default)",
            onTap: () {},
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Manutenzione Dati"),
          _buildTile(
            icon: Icons.delete_forever,
            title: "Reset Database Locale",
            subtitle: "Cancella cache tavoli e ordini (Solo questo dispositivo)",
            iconColor: AppColors.cRose500,
            textColor: AppColors.cRose500,
            onTap: () => _showResetDialog(context, ref),
          ),

          const SizedBox(height: 24),
          const Center(
            child: Text(
              "Orderly Pocket v1.0.0\nBuild 2024.10.25",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.cSlate400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Seleziona Lingua", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.cSlate800)),
            ),
            ListTile(
              leading: const Text("🇮🇹", style: TextStyle(fontSize: 24)),
              title: const Text("Italiano"),
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('it'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text("🇬🇧", style: TextStyle(fontSize: 24)),
              title: const Text("English"),
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ... (Resto dei metodi _buildSectionHeader, _buildTile, _showResetDialog identici a prima)

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.cSlate500, fontSize: 11, letterSpacing: 1.2)),
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
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.cSlate500)) : null,
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
        content: const Text("Sei sicuro? Tutti i tavoli aperti verranno chiusi e resettati."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cRose500, foregroundColor: Colors.white),
            onPressed: () async {
              final tablesBox = Hive.box(kTablesBox);
              final voidsBox = Hive.box(kVoidsBox);

              await voidsBox.clear();
              await tablesBox.clear();

              ref.invalidate(tablesProvider);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reset effettuato!")));
            },
            child: const Text("Conferma Reset"),
          ),
        ],
      ),
    );
  }
}