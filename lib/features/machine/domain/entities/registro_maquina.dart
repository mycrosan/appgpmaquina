import 'package:equatable/equatable.dart';

/// Entidade que representa o registro de uma máquina no sistema
/// Contém informações básicas sobre a máquina registrada
class RegistroMaquina extends Equatable {
  final int? id;
  final String nome;
  final String? descricao;
  final String? numeroSerie;
  final String? modelo;
  final String? fabricante;
  final String? localizacao;
  final String? responsavel;
  final String status; // ATIVA, INATIVA, MANUTENCAO, etc.
  final bool ativo;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;
  final String? observacoes;

  const RegistroMaquina({
    this.id,
    required this.nome,
    this.descricao,
    this.numeroSerie,
    this.modelo,
    this.fabricante,
    this.localizacao,
    this.responsavel,
    this.status = 'ATIVA',
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
    this.observacoes,
  });

  /// Verifica se a máquina está ativa e operacional
  bool get isOperational {
    return ativo && status == 'ATIVA';
  }

  /// Verifica se a máquina está em manutenção
  bool get isInMaintenance {
    return status == 'MANUTENCAO';
  }

  /// Retorna uma descrição completa da máquina
  String get fullDescription {
    final parts = <String>[];
    
    if (modelo != null && modelo!.isNotEmpty) {
      parts.add('Modelo: $modelo');
    }
    
    if (fabricante != null && fabricante!.isNotEmpty) {
      parts.add('Fabricante: $fabricante');
    }
    
    if (numeroSerie != null && numeroSerie!.isNotEmpty) {
      parts.add('S/N: $numeroSerie');
    }
    
    if (localizacao != null && localizacao!.isNotEmpty) {
      parts.add('Local: $localizacao');
    }
    
    return parts.isEmpty ? nome : '$nome (${parts.join(', ')})';
  }

  /// Cria uma cópia da máquina com campos atualizados
  RegistroMaquina copyWith({
    int? id,
    String? nome,
    String? descricao,
    String? numeroSerie,
    String? modelo,
    String? fabricante,
    String? localizacao,
    String? responsavel,
    String? status,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    String? observacoes,
  }) {
    return RegistroMaquina(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      modelo: modelo ?? this.modelo,
      fabricante: fabricante ?? this.fabricante,
      localizacao: localizacao ?? this.localizacao,
      responsavel: responsavel ?? this.responsavel,
      status: status ?? this.status,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nome,
    descricao,
    numeroSerie,
    modelo,
    fabricante,
    localizacao,
    responsavel,
    status,
    ativo,
    criadoEm,
    atualizadoEm,
    observacoes,
  ];

  @override
  String toString() {
    return 'RegistroMaquina(id: $id, nome: $nome, status: $status, ativo: $ativo)';
  }
}