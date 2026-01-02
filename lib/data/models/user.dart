import 'base_model.dart';
import 'enums/user_role.dart';

class User extends BaseModel {
  final String username;
  final String email;
  final String name; // Standard PB name
  final String fullName; // Custom field: full_name
  final UserRole role; // TYPED
  final String pinHash;
  final String? avatar;
  final List<String> assignedDepartments; // IDs of departments

  User({
    required super.id,
    required super.created,
    required super.updated,
    required super.collectionId,
    required super.collectionName,
    required this.username,
    required this.email,
    required this.name,
    required this.fullName,
    required this.role,
    required this.pinHash,
    this.avatar,
    this.assignedDepartments = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      created: BaseModel.parseDate(json['created']),
      updated: BaseModel.parseDate(json['updated']),
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      role: UserRole.fromString(json['role'] ?? ''),
      pinHash: json['pin_hash'] ?? '',
      avatar: json['avatar'],
      assignedDepartments: (json['assigned_departments'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }

  factory User.empty() {
    return User(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      collectionId: '',
      collectionName: '',
      username: '',
      email: '',
      name: '',
      fullName: '',
      role: UserRole.unknown,
      pinHash: '',
    );
  }

  @override
  String toString() {
    return 'User{username: $username, email: $email, name: $name, fullName: $fullName, role: $role, pinHash: $pinHash, avatar: $avatar, assignedDepartments: $assignedDepartments}';
  }
}