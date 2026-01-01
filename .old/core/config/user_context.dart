import 'package:orderly/old/core/config/supabase_client.dart';

class UserContext {
  /// Singleton instance (MVP)
  static UserContext? instance;

  /// Auth
  final String authUserId;

  /// Dominio
  final String restaurantId;
  final String role; // admin | staff
  final String? staffId;
  final String? staffRole; // waiter | kitchen
  final String? staffName;
  final String? restaurantName;

  UserContext({
    required this.authUserId,
    required this.restaurantId,
    required this.role,
    this.staffId,
    this.staffRole,
    this.staffName,
    this.restaurantName,
  });

  /// Factory: carica contesto da Supabase
  static Future<UserContext?> load() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // staff include anche admin
    final res = await supabase
        .from('staff')
        .select('''
          id,
          name,
          role,
          restaurant_id,
          restaurants (
            name
          )
        ''')
        .eq('auth_user_id', user.id)
        .single();

    return UserContext(
      authUserId: user.id,
      restaurantId: res['restaurant_id'],
      role: res['role'] == 'admin' ? 'admin' : 'staff',
      staffId: res['id'],
      staffRole: res['role'] != 'admin' ? res['role'] : null,
      staffName: res['name'],
      restaurantName: res['restaurants']?['name'],
    );
  }

  /// Init globale
  static Future<void> init() async {
    instance = await load();
  }

  /// Cleanup logout
  static void clear() {
    instance = null;
  }

  /// Helpers utili
  bool get isAdmin => role == 'admin';
  bool get isStaff => role == 'staff';
  bool get isWaiter => staffRole == 'waiter';
  bool get isKitchen => staffRole == 'kitchen';
}
