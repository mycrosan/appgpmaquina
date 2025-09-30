import '../../domain/entities/registro_maquina.dart';

/// Modelo de dados para RegistroMaquina que estende a entidade
/// Adiciona funcionalidades de serialização JSON
class RegistroMaquinaModel extends RegistroMaquina {
  const RegistroMaquinaModel({
    super.id,
    required super.nome,
    super.descricao,
    super.numeroSerie,
    super.modelo,
    super.fabricante,
    super.localizacao,
    super.responsavel,
    super.status,
    super.ativo,
    super.criadoEm,
    super.atualizadoEm,
    super.observacoes,
  });

  /// Cria um RegistroMaquinaModel a partir de JSON
  factory RegistroMaquinaModel.fromJson(Map<String, dynamic> json) {
    return RegistroMaquinaModel(
      id: json['id'] as int?,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      numeroSerie: json['numeroSerie'] as String?,
      modelo: json['modelo'] as String?,
      fabricante: json['fabricante'] as String?,
      localizacao: json['localizacao'] as String?,
      responsavel: json['responsavel'] as String?,
      status: json['status'] as String? ?? 'ATIVA',
      ativo: json['ativo'] as bool? ?? true,
      criadoEm: json['criadoEm'] != null 
          ? DateTime.parse(json['criadoEm'] as String)
          : null,
      atualizadoEm: json['atualizadoEm'] != null 
          ? DateTime.parse(json['atualizadoEm'] as String)
          : null,
      observacoes: json['observacoes'] as String?,
    );
  }

  /// Converte o RegistroMaquinaModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'numeroSerie': numeroSerie,
      'modelo': modelo,
      'fabricante': fabricante,
      'localizacao': localizacao,
      'responsavel': responsavel,
      'status': status,
      'ativo': ativo,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'observacoes': observacoes,
    };
  }

  /// Cria um RegistroMaquinaModel a partir de uma entidade RegistroMaquina
  factory RegistroMaquinaModel.fromEntity(RegistroMaquina maquina) {
    return RegistroMaquinaModel(
      id: maquina.id,
      nome: maquina.nome,
      descricao: maquina.descricao,
      numeroSerie: maquina.numeroSerie,
      modelo: maquina.modelo,
      fabricante: maquina.fabricante,
      localizacao: maquina.localizacao,
      responsavel: maquina.responsavel,
      status: maquina.status,
      ativo: maquina.ativo,
      criadoEm: maquina.criadoEm,
      atualizadoEm: maquina.atualizadoEm,
      observacoes: maquina.observacoes,
    );
  }

  /// Converte o modelo para entidade de domínio
  RegistroMaquina toEntity() {
    return RegistroMaquina(
      id: id,
      nome: nome,
      descricao: descricao,
      numeroSerie: numeroSerie,
      modelo: modelo,
      fabricante: fabricante,
      localizacao: localizacao,
      responsavel: responsavel,
      status: status,
      ativo: ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
      observacoes: observacoes,
    );
  }

  /// Cria uma cópia do modelo com valores atualizados
  RegistroMaquinaModel copyWith({
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
    return RegistroMaquinaModel(
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
  String toString() {
    return 'RegistroMaquinaModel(id: $id, nome: $nome, status: $status, ativo: $ativo)';
  }
}