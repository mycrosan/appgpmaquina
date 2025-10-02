import 'package:equatable/equatable.dart';

/// Status possíveis para um pneu vulcanizado
enum StatusPneuVulcanizado {
  iniciado('INICIADO'),
  finalizado('FINALIZADO');

  const StatusPneuVulcanizado(this.value);
  final String value;

  static StatusPneuVulcanizado fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INICIADO':
        return StatusPneuVulcanizado.iniciado;
      case 'FINALIZADO':
        return StatusPneuVulcanizado.finalizado;
      default:
        throw ArgumentError('Status inválido: $value');
    }
  }
}

/// DTO de resposta para pneu vulcanizado
/// 
/// Baseado na documentação da API:
/// - Retornado pelos endpoints GET e POST /api/pneu-vulcanizado
/// - Contém informações completas do pneu vulcanizado
class PneuVulcanizadoResponseDTO extends Equatable {
  /// ID único do pneu vulcanizado
  final int id;
  
  /// ID do usuário responsável
  final int usuarioId;
  
  /// Nome do usuário responsável
  final String usuarioNome;
  
  /// ID da produção relacionada
  final int producaoId;
  
  /// Status da vulcanização
  final StatusPneuVulcanizado status;
  
  /// Data e hora de criação
  final DateTime dtCreate;
  
  /// Data e hora da última atualização
  final DateTime? dtUpdate;

  const PneuVulcanizadoResponseDTO({
    required this.id,
    required this.usuarioId,
    required this.usuarioNome,
    required this.producaoId,
    required this.status,
    required this.dtCreate,
    this.dtUpdate,
  });

  /// Converte o DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'usuarioNome': usuarioNome,
      'producaoId': producaoId,
      'status': status.value,
      'dtCreate': dtCreate.toIso8601String(),
      'dtUpdate': dtUpdate?.toIso8601String(),
    };
  }

  /// Cria uma instância a partir de JSON
  factory PneuVulcanizadoResponseDTO.fromJson(Map<String, dynamic> json) {
    final dtUpdateRaw = json['dtUpdate'];
    return PneuVulcanizadoResponseDTO(
      id: json['id'] as int,
      usuarioId: json['usuarioId'] as int,
      usuarioNome: json['usuarioNome'] as String,
      producaoId: json['producaoId'] as int,
      status: StatusPneuVulcanizado.fromString(json['status'] as String),
      dtCreate: DateTime.parse(json['dtCreate'] as String),
      dtUpdate: dtUpdateRaw == null ? null : DateTime.parse(dtUpdateRaw as String),
    );
  }

  /// Cria uma cópia com campos atualizados
  PneuVulcanizadoResponseDTO copyWith({
    int? id,
    int? usuarioId,
    String? usuarioNome,
    int? producaoId,
    StatusPneuVulcanizado? status,
    DateTime? dtCreate,
    DateTime? dtUpdate,
  }) {
    return PneuVulcanizadoResponseDTO(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNome: usuarioNome ?? this.usuarioNome,
      producaoId: producaoId ?? this.producaoId,
      status: status ?? this.status,
      dtCreate: dtCreate ?? this.dtCreate,
      dtUpdate: dtUpdate ?? this.dtUpdate,
    );
  }

  /// Verifica se o pneu está finalizado
  bool get isFinalized => status == StatusPneuVulcanizado.finalizado;

  /// Verifica se o pneu está iniciado
  bool get isStarted => status == StatusPneuVulcanizado.iniciado;

  /// Calcula a duração do processo (se finalizado)
  Duration? get duracao {
    if (isFinalized && dtUpdate != null) {
      return dtUpdate!.difference(dtCreate);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        usuarioId,
        usuarioNome,
        producaoId,
        status,
        dtCreate,
        dtUpdate,
      ];

  @override
  String toString() {
    return 'PneuVulcanizadoResponseDTO(id: $id, usuarioId: $usuarioId, usuarioNome: $usuarioNome, producaoId: $producaoId, status: ${status.value}, dtCreate: $dtCreate, dtUpdate: $dtUpdate)';
  }
}