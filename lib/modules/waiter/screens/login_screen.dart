import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/orderly_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../logic/providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  // Rimosso onLoginSuccess: il router gestisce il redirect automaticamente
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _pin = "";

  void _onDigitPress(String digit) {
    // Evita input se stiamo già caricando o se il pin è completo
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });

      if (_pin.length == 4) {
        // Lancia il login. Non serve .then(), gestiamo il risultato con ref.listen nel build
        ref.read(sessionProvider.notifier).login(_pin);
      }
    }
  }

  void _onDeletePress() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // 1. Ascolta i cambiamenti di stato per gestire Errori e Reset UI
    ref.listen(sessionProvider, (previous, next) {
      // Se c'è un errore (AsyncError)
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error.toString().replaceAll("Exception: ", "")),
          backgroundColor: context.colors.danger,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ));

        // Resetta il PIN per riprovare
        setState(() => _pin = "");
      }
    });

    // 2. Leggi lo stato attuale per sapere se stiamo caricando
    final sessionState = ref.watch(sessionProvider);
    final isLoading = sessionState.isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return IgnorePointer(
            // Disabilita l'interazione durante il caricamento
            ignoring: isLoading,
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo / Icona (con indicatore di caricamento opzionale)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 64, color: colors.primary),
                    if (isLoading)
                      SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(color: colors.primary, strokeWidth: 2)
                      ),
                  ],
                ),

                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.waiterAppName,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.loginInsertPin,
                  style: TextStyle(color: colors.textSecondary, fontSize: 16),
                ),
                const Spacer(),

                // PIN Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? colors.primary : colors.surface,
                          border: Border.all(
                              color: isFilled ? colors.primary : colors.divider,
                              width: 2)),
                    );
                  }),
                ),
                const Spacer(),

                // Keypad
                SizedBox(
                  width: constraints.maxWidth * 0.7,
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (var i = 1; i <= 9; i++)
                        _buildKeypadBtn("$i", () => _onDigitPress("$i")),
                      const SizedBox(),
                      _buildKeypadBtn("0", () => _onDigitPress("0")),
                      _buildIconBtn(Icons.backspace_outlined, _onDeletePress),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKeypadBtn(String label, VoidCallback onTap) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(40),
      elevation: 2, // Leggera ombra per renderli più tattili
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: Icon(icon, color: colors.textSecondary, size: 28),
        ),
      ),
    );
  }
}