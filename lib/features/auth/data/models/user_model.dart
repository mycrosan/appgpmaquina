import '../../domain/entities/user.dart';

/// Modelo de dados para User que estende a entidade
/// Adiciona funcionalidades de serialização JSON
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.name,
    super.role,
    super.lastLogin,
  });

  /// Cria um UserModel a partir de JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extrai o primeiro perfil se existir
    String? role;
    if (json['perfil'] != null && json['perfil'] is List && (json['perfil'] as List).isNotEmpty) {
      final perfil = (json['perfil'] as List).first as Map<String, dynamic>;
      role = perfil['authority'] as String?;
    }
    
    return UserModel(
      id: json['id'] as int,
      username: json['login'] as String,  // Backend usa 'login' ao invés de 'username'
      email: json['email'] as String? ?? '${json['login']}@gp.local', // Backend não envia email, gera um baseado no login
      name: json['nome'] as String?,      // Backend usa 'nome' ao invés de 'name'
      role: role,                         // Extrai do array 'perfil'
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  /// Converte o UserModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'role': role,
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Cria um UserModel a partir de uma entidade User
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      name: user.name,
      role: user.role,
      lastLogin: user.lastLogin,
    );
  }

  /// Converte para entidade User
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      name: name,
      role: role,
      lastLogin: lastLogin,
    );
  }

  /// Cria uma cópia do UserModel com campos atualizados
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? name,
    String? role,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, name: $name, role: $role)';
  }
}