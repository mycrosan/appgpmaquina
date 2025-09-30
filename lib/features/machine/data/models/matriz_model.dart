import '../../domain/entities/matriz.dart';

/// Modelo de dados para Matriz que estende a entidade
/// Adiciona funcionalidades de serialização JSON
class MatrizModel extends Matriz {
  const MatrizModel({
    required super.id,
    required super.descricao,
    required super.nome,
    required super.codigo,
    required super.isActive,
    required super.canBeUsed,
  });

  /// Cria um MatrizModel a partir de JSON
  factory MatrizModel.fromJson(Map<String, dynamic> json) {
    return MatrizModel(
      id: json['id'] as int,
      descricao: json['descricao'] as String,
      nome:
          json['nome'] as String? ??
          json['descricao'] as String, // Usa descricao como fallback para nome
      codigo:
          json['codigo'] as String? ??
          'M${json['id']}', // Gera código baseado no ID se não existir
      isActive: json['is_active'] as bool? ?? true,
      canBeUsed: json['can_be_used'] as bool? ?? true,
    );
  }

  /// Converte o MatrizModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'nome': nome,
      'codigo': codigo,
      'is_active': isActive,
      'can_be_used': canBeUsed,
    };
  }

  /// Cria um MatrizModel a partir de uma entidade Matriz
  factory MatrizModel.fromEntity(Matriz matriz) {
    return MatrizModel(
      id: matriz.id,
      descricao: matriz.descricao,
      nome: matriz.nome,
      codigo: matriz.codigo,
      isActive: matriz.isActive,
      canBeUsed: matriz.canBeUsed,
    );
  }

  /// Converte para entidade Matriz
  Matriz toEntity() {
    return Matriz(
      id: id,
      descricao: descricao,
      nome: nome,
      codigo: codigo,
      isActive: isActive,
      canBeUsed: canBeUsed,
    );
  }

  /// Cria uma cópia do MatrizModel com campos atualizados
  MatrizModel copyWith({
    int? id,
    String? descricao,
    String? nome,
    String? codigo,
    bool? isActive,
    bool? canBeUsed,
  }) {
    return MatrizModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      nome: nome ?? this.nome,
      codigo: codigo ?? this.codigo,
      isActive: isActive ?? this.isActive,
      canBeUsed: canBeUsed ?? this.canBeUsed,
    );
  }

  @override
  String toString() {
    return 'MatrizModel(id: $id, nome: $nome, codigo: $codigo, descricao: $descricao, isActive: $isActive, canBeUsed: $canBeUsed)';
  }
}