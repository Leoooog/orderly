import 'package:orderly/old/core/config/user_context.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late final SupabaseClient supabase;

Future<void> initializeSupabase() async {
  await Supabase.initialize(
      url: 'https://eeqpvcuvrspprgtjhpuw.supabase.co',
      anonKey: 'sb_publishable_n1-DdJ4HnKfICojWQq3oSA_aPS4xBiS');

  supabase = Supabase.instance.client;
  if (supabase.auth.currentSession != null) {
    // carica UserContext da DB, sia admin che staff
    await UserContext.init(); // singolo punto di bootstrap
  }
}
