import 'package:flutter/material.dart';
import '../../../config/themes.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.loginPinError),
              backgroundColor: AppColors.cRose500,
              duration: Duration(milliseconds: 500),
            )
        );
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
    return Scaffold(
      backgroundColor: AppColors.cSlate900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 64, color: AppColors.cIndigo600),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.waiterAppName,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cWhite,
                  letterSpacing: 1.5
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.loginInsertPin,
              style: TextStyle(color: AppColors.cSlate500),
            ),
            const SizedBox(height: 48),

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
                      color: index < _pin.length ? AppColors.cIndigo600 : AppColors.cSlate800,
                      border: Border.all(
                          color: index < _pin.length ? AppColors.cIndigo600 : AppColors.cSlate600,
                          width: 2
                      )
                  ),
                );
              }),
            ),

            const SizedBox(height: 64),

            // Keypad
            SizedBox(
              width: 280,
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
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadBtn(String label, VoidCallback onTap) {
    return Material(
      color: AppColors.cSlate800,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.cWhite),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.cTransparent,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: Icon(icon, color: AppColors.cSlate500, size: 28),
        ),
      ),
    );
  }
}