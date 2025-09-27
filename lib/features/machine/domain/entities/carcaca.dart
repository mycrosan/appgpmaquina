import 'package:equatable/equatable.dart';

/// Entidade que representa uma carcaça de pneu
/// Contém informações sobre o código da carcaça e sua matriz associada
class Carcaca extends Equatable {
  final int id;
  final String codigo; // Código de 6 dígitos da etiqueta
  final int matrizId;
  final String matrizNome;
  final String? observacoes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const Carcaca({
    required this.id,
    required this.codigo,
    required this.matrizId,
    required this.matrizNome,
    this.observacoes,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Verifica se o código da carcaça é válido (6 dígitos)
  bool get isValidCode {
    return codigo.length == 6 && RegExp(r'^\d{6}$').hasMatch(codigo);
  }

  /// Verifica se a carcaça está ativa e pode ser processada
  bool get canBeProcessed {
    return isActive && isValidCode;
  }

  /// Verifica se a carcaça pertence à matriz especificada
  bool belongsToMatrix(int matrixId) {
    return matrizId == matrixId;
  }

  /// Cria uma cópia da carcaça com campos atualizados
  Carcaca copyWith({
    int? id,
    String? codigo,
    int? matrizId,
    String? matrizNome,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Carcaca(
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
  List<Object?> get props => [
        id,
        codigo,
        matrizId,
        matrizNome,
        observacoes,
        createdAt,
        updatedAt,
        isActive,
      ];

  @override
  String toString() {
    return 'Carcaca(id: $id, codigo: $codigo, matrizId: $matrizId, matrizNome: $matrizNome, isActive: $isActive)';
  }
}