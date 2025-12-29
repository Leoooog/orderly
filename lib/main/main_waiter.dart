import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modules/waiter/waiter_app.dart';
import '../orderly_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Qui potresti inizializzare servizi specifici per i camerieri

  runApp(const ProviderScope(
    child: OrderlyApp(
      home: WaiterApp(),
      title: 'Orderly Sala',
    ),
  ));
}