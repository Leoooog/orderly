class Staff {
  final String id;
  final String name;
  final String role;
  final String? email; // tecnico per login con email
  final String? pin;
  final String? authUserId;
  final String? restaurantId;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.pin,
    this.authUserId,
    this.restaurantId,
  });

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      email: map['email'],
      pin: map['pin'],
      authUserId: map['auth_user_id'],
      restaurantId: map['restaurant_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'pin': pin,
      'auth_user_id': authUserId,
      'restaurant_id': restaurantId,
    };
  }
}
