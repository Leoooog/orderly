import 'package:flutter/material.dart';

import '../orderly_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Implementazione specifica per il POS
  runApp(const OrderlyApp(
    home: PosApp(),
    title: 'Orderly POS',
  ));
}