import 'package:equatable/equatable.dart';

/// Entidade que representa uma matriz de pneu
/// Contém informações sobre a matriz conforme retorno da API
class Matriz extends Equatable {
  final int id;
  final String descricao;
  final String nome;
  final String codigo;
  final bool isActive;
  final bool canBeUsed;

  const Matriz({
    required this.id,
    required this.descricao,
    required this.nome,
    required this.codigo,
    required this.isActive,
    required this.canBeUsed,
  });

  /// Descrição completa da matriz
  String get fullDescription => '$nome ($codigo) - $descricao';

  /// Cria uma cópia da matriz com campos atualizados
  Matriz copyWith({
    int? id,
    String? descricao,
    String? nome,
    String? codigo,
    bool? isActive,
    bool? canBeUsed,
  }) {
    return Matriz(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      nome: nome ?? this.nome,
      codigo: codigo ?? this.codigo,
      isActive: isActive ?? this.isActive,
      canBeUsed: canBeUsed ?? this.canBeUsed,
    );
  }

  @override
  List<Object?> get props => [id, descricao, nome, codigo, isActive, canBeUsed];

  @override
  String toString() {
    return 'Matriz(id: $id, nome: $nome, codigo: $codigo, descricao: $descricao, isActive: $isActive, canBeUsed: $canBeUsed)';
  }
}