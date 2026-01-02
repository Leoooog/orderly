import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/logic/providers/session_provider.dart';

final voidReasonsProvider = FutureProvider<List<VoidReason>>((ref) async {
  print("[VoidReasonsProvider] fetching void reasons...");
  final repo = ref.watch(sessionProvider).repository!;
  final reasons = await repo.getVoidReasons();
  print("[VoidReasonsProvider] fetched ${reasons.length} void reasons");
  return reasons;
});
