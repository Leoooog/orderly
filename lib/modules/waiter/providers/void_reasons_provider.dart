 import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orderly/data/models/config/void_reason.dart';
import 'package:orderly/logic/providers/session_provider.dart';

final voidReasonsProvider = FutureProvider<List<VoidReason>>((ref) async {
  final repo = ref.watch(sessionProvider).repository!;
  return repo.getVoidReasons();
});

