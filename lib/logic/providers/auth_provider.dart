import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Inizialmente non loggato
  }

  void login(String pin) {
    // Qui in futuro verificherai il PIN con il Backend/API
    if (pin == "1234") {
      state = true;
    }
  }

  void logout() {
    state = false;
  }
}