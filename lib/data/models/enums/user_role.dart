enum UserRole {
  admin,
  waiter,
  kitchen,
  pos,
  unknown;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
          (e) => e.name == value,
      orElse: () => UserRole.unknown,
    );
  }

  String toJson() => name;
}