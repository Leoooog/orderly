import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:orderly/data/hive_keys.dart';
import 'package:orderly/modules/waiter/screens/orderly_colors.dart';
import '../providers/tables_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart'; // Importa il provider lingua

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // Leggi la lingua corrente per mostrarla nel sottotitolo
    final currentLocale = ref.watch(localeProvider);
    final String languageName = currentLocale.languageCode == 'it' ? 'Italiano' : 'English';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text("Impostazioni", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, "Dispositivo"),
          _buildTile(
            context,
            icon: Icons.smartphone,
            title: "ID Terminale",
            subtitle: "W-01 (Autorizzato)",
            onTap: () {},
            iconColor: colors.primary,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, "Preferenze"),

          // TILE LINGUA ATTIVO
          _buildTile(
            context,
            icon: Icons.language,
            title: "Lingua",
            subtitle: languageName, // Mostra la lingua attuale
            onTap: () => _showLanguageDialog(context, ref),
          ),

          _buildTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: "Tema",
            subtitle: "Chiaro (Default)",
            onTap: () => _showThemeDialog(context, ref),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, "Manutenzione Dati"),
          _buildTile(
            context,
            icon: Icons.delete_forever,
            title: "Reset Database Locale",
            subtitle: "Cancella cache tavoli e ordini (Solo questo dispositivo)",
            iconColor: colors.danger,
            textColor: colors.danger,
            onTap: () => _showResetDialog(context, ref),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              "Orderly Pocket v1.0.0\nBuild 2024.10.25",
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textTertiary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Seleziona Lingua", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.textPrimary)),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: colors.textSecondary, fontSize: 11, letterSpacing: 1.2)),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap, Color? iconColor, Color? textColor}) {
    final colors = context.colors;
    final effectiveIconColor = iconColor ?? colors.textSecondary;
    final effectiveTextColor = textColor ?? colors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: effectiveIconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: effectiveIconColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: effectiveTextColor)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: colors.textSecondary)) : null,
        trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
        onTap: onTap,
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text("Reset Dati"),
        content: const Text("Sei sicuro? Tutti i tavoli aperti verranno chiusi e resettati."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.danger, foregroundColor: colors.textInverse),
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

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Seleziona Tema", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.textPrimary)),
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text("Chiaro"),
              onTap: () {
                ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.nights_stay_outlined),
              title: const Text("Scuro"),
              onTap: () {
                ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto_outlined),
              title: const Text("Automatico"),
              onTap: () {
                ref.read(themeModeProvider.notifier).setSystem();
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

}
