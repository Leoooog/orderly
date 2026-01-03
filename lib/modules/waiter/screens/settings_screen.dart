import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/orderly_colors.dart';
import '../../../logic/providers/locale_provider.dart';
import '../../../logic/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    // 1. Logica Lingua
    final currentLocale = ref.watch(localeProvider);
    final String languageName =
    currentLocale.languageCode == 'it' ? 'Italiano' : 'English';

    // 2. Logica Tema (Per aggiornare il sottotitolo)
    final currentThemeMode = ref.watch(themeModeProvider);
    String themeName;
    switch (currentThemeMode) {
      case ThemeMode.system:
        themeName = "Automatico";
        break;
      case ThemeMode.light:
        themeName = "Chiaro";
        break;
      case ThemeMode.dark:
        themeName = "Scuro";
        break;
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text(
          "Impostazioni",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0, // Evita cambio colore allo scroll
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // CORREZIONE 1: Rimosso padding da qui per evitare scroll inutile
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight( // Aiuta a gestire il layout flessibile
                child: Padding(
                  // CORREZIONE 1: Padding spostato qui dentro
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      _buildTile(
                        context,
                        icon: Icons.language,
                        title: "Lingua",
                        subtitle: languageName,
                        onTap: () => _showLanguageDialog(context, ref),
                      ),
                      _buildTile(
                        context,
                        icon: Icons.dark_mode_outlined,
                        title: "Tema",
                        subtitle: themeName, // Ora dinamico
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
                        onTap: () {
                          // _showResetDialog(context, ref);
                        },
                      ),

                      const Spacer(), // Spinge tutto giù

                      // CORREZIONE 2: SafeArea per non coprire il testo in basso
                      SafeArea(
                        top: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                            child: Text(
                              "Orderly Pocket v1.0.0\nBuild 2024.10.25",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: colors.textTertiary,
                                  fontSize: 12,
                                  height: 1.5
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ... (Il resto dei metodi _showLanguageDialog e _showThemeDialog rimane uguale)
  // Assicurati solo di usare context.colors correttamente

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Seleziona Lingua",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colors.textPrimary)),
            ),
            ListTile(
              leading: const Text("🇮🇹", style: TextStyle(fontSize: 24)),
              title: Text("Italiano", style: TextStyle(fontSize: 14, color: colors.textPrimary)),
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('it'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text("🇬🇧", style: TextStyle(fontSize: 24)),
              title: Text("English", style: TextStyle(fontSize: 14, color: colors.textPrimary)),
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

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Seleziona Tema",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colors.textPrimary)),
            ),
            ListTile(
              leading: Icon(Icons.wb_sunny_outlined, size: 20, color: colors.textPrimary),
              title: Text("Chiaro", style: TextStyle(fontSize: 14, color: colors.textPrimary)),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.nights_stay_outlined, size: 20, color: colors.textPrimary),
              title: Text("Scuro", style: TextStyle(fontSize: 14, color: colors.textPrimary)),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.brightness_auto_outlined, size: 20, color: colors.textPrimary),
              title: Text("Automatico", style: TextStyle(fontSize: 14, color: colors.textPrimary)),
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8), // Leggermente rientrato
      child: Text(title.toUpperCase(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              fontSize: 11,
              letterSpacing: 1.2)),
    );
  }

  Widget _buildTile(BuildContext context,
      {required IconData icon,
        required String title,
        String? subtitle,
        required VoidCallback onTap,
        Color? iconColor,
        Color? textColor}) {
    final colors = context.colors;
    final effectiveIconColor = iconColor ?? colors.textSecondary;
    final effectiveTextColor = textColor ?? colors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        // CORREZIONE 4: Ombra più delicata
        boxShadow: [
          BoxShadow(
              color: colors.shadow.withValues(alpha:0.05), // Assicurati sia sottile
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Padding interno coerente
            child: Row(
              children: [
                // Icona
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: effectiveIconColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: effectiveIconColor, size: 22),
                ),
                const SizedBox(width: 16),
                // Testi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: effectiveTextColor,
                              fontSize: 15)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13,
                                color: colors.textSecondary,
                                height: 1.2
                            )),
                      ]
                    ],
                  ),
                ),
                // Freccia
                Icon(Icons.chevron_right, color: colors.textTertiary.withValues(alpha:0.5), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}