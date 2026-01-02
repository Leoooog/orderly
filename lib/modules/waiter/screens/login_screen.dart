import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/orderly_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../logic/providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _pin = "";

  void _onDigitPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });

      if (_pin.length == 4) {
        ref.read(sessionProvider.notifier).login(_pin).then((_) {
          // Dopo il tentativo di login, controlla lo stato.
          // Se il login fallisce, lo stato conterrà un errore.
          final session = ref.read(sessionProvider);
          if (session.errorMessage != null &&
              session.appState != AppState.authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(session.errorMessage!),
              backgroundColor: context.colors.danger,
              duration: const Duration(milliseconds: 800),
            ));
            Future.delayed(const Duration(milliseconds: 800), () {
              setState(() => _pin = "");
            });
          }
          // Se il login ha successo, il redirect del router farà il resto.
        });
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
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              const Spacer(flex: 2),
              Icon(Icons.restaurant_menu, size: 64, color: colors.primary),
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
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _pin.length
                            ? colors.primary
                            : colors.surface,
                        border: Border.all(
                            color: index < _pin.length
                                ? colors.primary
                                : colors.divider,
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