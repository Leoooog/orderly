// repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../config/hive_keys.dart';
import '../../core/services/repository_factory.dart';
import '../../core/services/tenant_service.dart';
import '../../data/repositories/i_orderly_repository.dart';

final repositoryProvider = FutureProvider<IOrderlyRepository?>((ref) async {
  print("[RepositoryProvider] Initializing repository...");

  // 1. Apri Hive
  final settingsBox = await Hive.openBox(HiveKeys.settingsBox);
  final backendType = settingsBox.get(HiveKeys.backendType, defaultValue: "pocketbase");

  // 2. Controllo Url Pocketbase
  if (backendType == 'pocketbase') {
    final tenantService = await TenantService.create();
    final url = tenantService.getSavedTenantUrl();

    // QUI IL CAMBIAMENTO: Se url è null, NON lanciare eccezione.
    // Restituisci null. Questo completa il Future IMMEDIATAMENTE.
    if (url == null) {
      print("[RepositoryProvider] Tenant URL mancante. Ritorno null.");
      return null;
    }
  }

  // 3. Se arriviamo qui, abbiamo l'URL. Creiamo il repository.
  final factory = RepositoryFactory();
  return factory.createRepository(backendType);
});