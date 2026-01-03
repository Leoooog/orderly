import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/logic/providers/repository_provider.dart';

final voidReasonsProvider = FutureProvider<List<VoidReason>>((ref) async {
  print("[VoidReasonsProvider] fetching void reasons...");
  // Attesa asincrona del repository
  final repo = await ref.watch(repositoryProvider.future);
  if(repo == null) {
    throw Exception("Repository non inizializzato. Impossibile fetchare void reasons.");
  }
  final reasons = await repo.getVoidReasons();
  print("[VoidReasonsProvider] fetched ${reasons.length} void reasons");
  return reasons;
});