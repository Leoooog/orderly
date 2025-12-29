import 'package:flutter/material.dart';

import '../orderly_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Implementazione specifica per l'admin
  runApp(const OrderlyApp(
    home: AdminApp(),
    title: 'Orderly Admin',
  ));
}