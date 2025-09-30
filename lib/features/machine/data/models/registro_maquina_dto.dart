import '../../domain/entities/registro_maquina.dart';
import 'registro_maquina_model.dart';

/// DTO para resposta da API de registro de máquinas
/// Baseado na especificação OpenAPI fornecida
class RegistroMaquinaResponseDTO {
  final int? id;
  final String? nome;
  final String? descricao;
  final String? numeroSerie;
  final String? modelo;
  final String? fabricante;
  final String? localizacao;
  final String? responsavel;
  final String? status;
  final bool? ativo;
  final String? criadoEm;
  final String? atualizadoEm;
  final String? observacoes;
  final String? message;
  final bool? success;

  const RegistroMaquinaResponseDTO({
    this.id,
    this.nome,
    this.descricao,
    this.numeroSerie,
    this.modelo,
    this.fabricante,
    this.localizacao,
    this.responsavel,
    this.status,
    this.ativo,
    this.criadoEm,
    this.atualizadoEm,
    this.observacoes,
    this.message,
    this.success,
  });

  /// Cria um DTO a partir de JSON
  factory RegistroMaquinaResponseDTO.fromJson(Map<String, dynamic> json) {
    return RegistroMaquinaResponseDTO(
      id: json['id'] as int?,
      nome: json['nome'] as String?,
      descricao: json['descricao'] as String?,
      numeroSerie: json['numeroSerie'] as String?,
      modelo: json['modelo'] as String?,
      fabricante: json['fabricante'] as String?,
      localizacao: json['localizacao'] as String?,
      responsavel: json['responsavel'] as String?,
      status: json['status'] as String?,
      ativo: json['ativo'] as bool?,
      criadoEm: json['criadoEm'] as String?,
      atualizadoEm: json['atualizadoEm'] as String?,
      observacoes: json['observacoes'] as String?,
      message: json['message'] as String?,
      success: json['success'] as bool?,
    );
  }

  /// Converte para JSON
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
      'criadoEm': criadoEm,
      'atualizadoEm': atualizadoEm,
      'observacoes': observacoes,
      'message': message,
      'success': success,
    };
  }

  /// Converte para modelo de dados
  RegistroMaquinaModel? toModel() {
    if (id == null || nome == null) return null;
    
    return RegistroMaquinaModel(
      id: id,
      nome: nome!,
      descricao: descricao,
      numeroSerie: numeroSerie,
      modelo: modelo,
      fabricante: fabricante,
      localizacao: localizacao,
      responsavel: responsavel,
      status: status ?? 'ATIVA',
      ativo: ativo ?? true,
      criadoEm: criadoEm != null ? DateTime.tryParse(criadoEm!) : null,
      atualizadoEm: atualizadoEm != null ? DateTime.tryParse(atualizadoEm!) : null,
      observacoes: observacoes,
    );
  }

  /// Converte para entidade de domínio
  RegistroMaquina toEntity() {
    if (id == null || nome == null) {
      throw Exception('ID e nome são obrigatórios para criar entidade');
    }
    
    return RegistroMaquina(
      id: id!,
      nome: nome!,
      descricao: descricao,
      numeroSerie: numeroSerie,
      modelo: modelo,
      fabricante: fabricante,
      localizacao: localizacao,
      responsavel: responsavel,
      status: status ?? 'ATIVA',
      ativo: ativo ?? true,
      criadoEm: criadoEm != null ? DateTime.tryParse(criadoEm!) : null,
      atualizadoEm: atualizadoEm != null ? DateTime.tryParse(atualizadoEm!) : null,
      observacoes: observacoes,
    );
  }
}

/// DTO para atualização de máquina
/// Baseado na especificação OpenAPI fornecida
class RegistroMaquinaUpdateDTO {
  final String? nome;
  final String? descricao;
  final String? numeroSerie;
  final String? modelo;
  final String? fabricante;
  final String? localizacao;
  final String? responsavel;
  final String? status;
  final bool? ativo;
  final String? observacoes;

  const RegistroMaquinaUpdateDTO({
    this.nome,
    this.descricao,
    this.numeroSerie,
    this.modelo,
    this.fabricante,
    this.localizacao,
    this.responsavel,
    this.status,
    this.ativo,
    this.observacoes,
  });

  /// Cria um DTO a partir de JSON
  factory RegistroMaquinaUpdateDTO.fromJson(Map<String, dynamic> json) {
    return RegistroMaquinaUpdateDTO(
      nome: json['nome'] as String?,
      descricao: json['descricao'] as String?,
      numeroSerie: json['numeroSerie'] as String?,
      modelo: json['modelo'] as String?,
      fabricante: json['fabricante'] as String?,
      localizacao: json['localizacao'] as String?,
      responsavel: json['responsavel'] as String?,
      status: json['status'] as String?,
      ativo: json['ativo'] as bool?,
      observacoes: json['observacoes'] as String?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (nome != null) json['nome'] = nome;
    if (descricao != null) json['descricao'] = descricao;
    if (numeroSerie != null) json['numeroSerie'] = numeroSerie;
    if (modelo != null) json['modelo'] = modelo;
    if (fabricante != null) json['fabricante'] = fabricante;
    if (localizacao != null) json['localizacao'] = localizacao;
    if (responsavel != null) json['responsavel'] = responsavel;
    if (status != null) json['status'] = status;
    if (ativo != null) json['ativo'] = ativo;
    if (observacoes != null) json['observacoes'] = observacoes;
    
    return json;
  }

  /// Cria um DTO a partir de um modelo
  factory RegistroMaquinaUpdateDTO.fromModel(RegistroMaquinaModel model) {
    return RegistroMaquinaUpdateDTO(
      nome: model.nome,
      descricao: model.descricao,
      numeroSerie: model.numeroSerie,
      modelo: model.modelo,
      fabricante: model.fabricante,
      localizacao: model.localizacao,
      responsavel: model.responsavel,
      status: model.status,
      ativo: model.ativo,
      observacoes: model.observacoes,
    );
  }
}