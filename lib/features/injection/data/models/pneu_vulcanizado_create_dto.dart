import 'package:equatable/equatable.dart';

/// DTO para criação de pneu vulcanizado
/// 
/// Baseado na documentação da API:
/// - POST /api/pneu-vulcanizado
/// - Cria um novo registro de pneu vulcanizado com status inicial 'INICIADO'
class PneuVulcanizadoCreateDTO extends Equatable {
  /// ID do usuário responsável pela vulcanização
  final int usuarioId;
  
  /// ID da produção relacionada
  final int producaoId;

  const PneuVulcanizadoCreateDTO({
    required this.usuarioId,
    required this.producaoId,
  });

  /// Converte o DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'producaoId': producaoId,
    };
  }

  /// Cria uma instância a partir de JSON
  factory PneuVulcanizadoCreateDTO.fromJson(Map<String, dynamic> json) {
    return PneuVulcanizadoCreateDTO(
      usuarioId: json['usuarioId'] as int,
      producaoId: json['producaoId'] as int,
    );
  }

  /// Cria uma cópia com campos atualizados
  PneuVulcanizadoCreateDTO copyWith({
    int? usuarioId,
    int? producaoId,
  }) {
    return PneuVulcanizadoCreateDTO(
      usuarioId: usuarioId ?? this.usuarioId,
      producaoId: producaoId ?? this.producaoId,
    );
  }

  @override
  List<Object?> get props => [usuarioId, producaoId];

  @override
  String toString() {
    return 'PneuVulcanizadoCreateDTO(usuarioId: $usuarioId, producaoId: $producaoId)';
  }
}