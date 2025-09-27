import '../../domain/entities/carcaca.dart';

/// Modelo de dados para Carcaca que estende a entidade
/// Adiciona funcionalidades de serialização JSON
class CarcacaModel extends Carcaca {
  const CarcacaModel({
    required super.id,
    required super.codigo,
    required super.matrizId,
    required super.matrizNome,
    super.observacoes,
    required super.createdAt,
    super.updatedAt,
    super.isActive,
  });

  /// Cria um CarcacaModel a partir de JSON
  factory CarcacaModel.fromJson(Map<String, dynamic> json) {
    return CarcacaModel(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      matrizId: json['matriz_id'] as int,
      matrizNome: json['matriz_nome'] as String,
      observacoes: json['observacoes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converte o CarcacaModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'matriz_id': matrizId,
      'matriz_nome': matrizNome,
      'observacoes': observacoes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Cria um CarcacaModel a partir de uma entidade Carcaca
  factory CarcacaModel.fromEntity(Carcaca carcaca) {
    return CarcacaModel(
      id: carcaca.id,
      codigo: carcaca.codigo,
      matrizId: carcaca.matrizId,
      matrizNome: carcaca.matrizNome,
      observacoes: carcaca.observacoes,
      createdAt: carcaca.createdAt,
      updatedAt: carcaca.updatedAt,
      isActive: carcaca.isActive,
    );
  }

  /// Cria uma cópia do CarcacaModel com campos atualizados
  CarcacaModel copyWith({
    int? id,
    String? codigo,
    int? matrizId,
    String? matrizNome,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CarcacaModel(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      matrizId: matrizId ?? this.matrizId,
      matrizNome: matrizNome ?? this.matrizNome,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'CarcacaModel(id: $id, codigo: $codigo, matrizId: $matrizId, matrizNome: $matrizNome, isActive: $isActive)';
  }
}