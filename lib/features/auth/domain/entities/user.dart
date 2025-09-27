import 'package:equatable/equatable.dart';

/// Entidade que representa um usuário autenticado
class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String? name;
  final String? role;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.role,
    this.lastLogin,
  });

  /// Cria uma cópia do usuário com campos atualizados
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? name,
    String? role,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [id, username, email, name, role, lastLogin];

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, name: $name, role: $role)';
  }
}