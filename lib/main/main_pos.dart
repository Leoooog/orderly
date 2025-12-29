import 'package:flutter/material.dart';

import '../modules/pos/POSApp.dart';
import '../orderly_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Implementazione specifica per il POS
  runApp(const OrderlyApp(
    home: POSApp(),
    title: 'Orderly POS',
  ));
}