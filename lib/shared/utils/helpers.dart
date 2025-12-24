import 'dart:math';

// Funzione per generare PIN numerico casuale
String generateRandomPin({int length = 6}) {
  final random = Random();
  String pin = '';
  for (int i = 0; i < length; i++) {
    pin += random.nextInt(10).toString(); // 0-9
  }
  return pin;
}

