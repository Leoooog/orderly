import 'package:flutter/material.dart';
import 'package:orderly/modules/waiter/screens/orderly_colors.dart';
import '../../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = "";
  final String _correctPin = "1234";

  void _onDigitPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });

      if (_pin == _correctPin) {
        Future.delayed(const Duration(milliseconds: 300), () {
          widget.onLoginSuccess();
          setState(() => _pin = "");
        });
      } else if (_pin.length == 4) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.loginPinError),
          backgroundColor: context.colors.danger,
          duration: const Duration(milliseconds: 500),
        ));
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() => _pin = "");
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
          // Determine dot size based on screen width
          final dotSize = constraints.maxWidth * 0.04;

          return Column(
            children: [
              // --- SECTION 1: HEADER (Flex 3) ---
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Expanded(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          Icons.restaurant_menu,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppLocalizations.of(context)!.waiterAppName,
                          style: TextStyle(
                            fontSize: 28, // Base size, FittedBox will scale it down
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        AppLocalizations.of(context)!.loginInsertPin,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),

              // --- SECTION 2: PIN DOTS (Flex 1) ---
              Expanded(
                flex: 1,
                child: Center(
                  child: SizedBox(
                    width: constraints.maxWidth * 0.5, // Constrain width
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        final isFilled = index < _pin.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: dotSize,
                          height: dotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled ? colors.primary : colors.surface,
                            border: Border.all(
                              color: isFilled ? colors.primary : colors.divider,
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // --- SECTION 3: KEYPAD (Flex 6) ---
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.15,
                    vertical: constraints.maxHeight * 0.02,
                  ),
                  child: Column(
                    children: [
                      // Row 1-3
                      Expanded(
                        child: Row(
                          children: [
                            _buildKeypadBtn("1", () => _onDigitPress("1")),
                            _buildKeypadBtn("2", () => _onDigitPress("2")),
                            _buildKeypadBtn("3", () => _onDigitPress("3")),
                          ],
                        ),
                      ),
                      // Row 4-6
                      Expanded(
                        child: Row(
                          children: [
                            _buildKeypadBtn("4", () => _onDigitPress("4")),
                            _buildKeypadBtn("5", () => _onDigitPress("5")),
                            _buildKeypadBtn("6", () => _onDigitPress("6")),
                          ],
                        ),
                      ),
                      // Row 7-9
                      Expanded(
                        child: Row(
                          children: [
                            _buildKeypadBtn("7", () => _onDigitPress("7")),
                            _buildKeypadBtn("8", () => _onDigitPress("8")),
                            _buildKeypadBtn("9", () => _onDigitPress("9")),
                          ],
                        ),
                      ),
                      // Row 0 & Backspace
                      Expanded(
                        child: Row(
                          children: [
                            const Spacer(), // Empty slot
                            _buildKeypadBtn("0", () => _onDigitPress("0")),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _buildIconBtn(
                                  Icons.backspace_outlined,
                                  _onDeletePress,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 1), // Bottom buffer
            ],
          );
        }),
      ),
    );
  }

  // Uses Expanded to ensure the button fills its cell in the Flex layout
  Widget _buildKeypadBtn(String label, VoidCallback onTap) {
    final colors = context.colors;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0), // The "gap" between buttons
        child: LayoutBuilder(
            builder: (context, constraints) {
              return Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(100), // Fully rounded
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(100),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        // Scale font relative to button height to avoid overflow
                        fontSize: constraints.maxHeight * 0.35,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    final colors = context.colors;
    return LayoutBuilder(
        builder: (context, constraints) {
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(100),
              child: Center(
                child: Icon(
                  icon,
                  color: colors.textSecondary,
                  // Scale icon relative to container
                  size: constraints.maxHeight * 0.4,
                ),
              ),
            ),
          );
        }
    );
  }
}