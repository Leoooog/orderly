import 'package:hive_ce/hive_ce.dart';
import 'package:orderly/data/repositories/i_orderly_repository.dart';
import 'package:orderly/data/repositories/pocket_base_repository.dart';

import '../../config/hive_keys.dart';

class RepositoryFactory {
  // Costruttore vuoto
  RepositoryFactory();

  Future<Box> _getSettingsBox() async {
    // Apre il box solo quando serve
    return await Hive.openBox(HiveKeys.settingsBox);
  }

  Future<IOrderlyRepository> createRepository() async {
    final settingsBox = await _getSettingsBox();
    final backendType =
        settingsBox.get(HiveKeys.backendType, defaultValue: 'pocketbase');

    switch (backendType) {
      case 'pocketbase':
        // PocketBaseRepository si inizializzerà usando il TenantService
        return await PocketBaseRepository.create();
      default:
        throw Exception('Unknown backend type: $backendType');
    }
  }

  Future<void> setBackendType(String type) async {
    final settingsBox = await _getSettingsBox();
    await settingsBox.put(HiveKeys.backendType, type);
  }
}
