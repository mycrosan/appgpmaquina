import '../../domain/entities/configuracao_maquina.dart';

/// Modelo de dados para ConfiguracaoMaquina que estende a entidade
/// Adiciona funcionalidades de serialização JSON
class ConfiguracaoMaquinaModel extends ConfiguracaoMaquina {
  const ConfiguracaoMaquinaModel({
    super.id,
    required super.registroMaquinaId,
    required super.chaveConfiguracao,
    required super.valorConfiguracao,
    super.descricao,
    super.tipoValor,
    super.valorPadrao,
    super.obrigatorio,
    super.ativo,
    super.criadoEm,
    super.atualizadoEm,
  });

  /// Cria um ConfiguracaoMaquinaModel a partir de JSON
  factory ConfiguracaoMaquinaModel.fromJson(Map<String, dynamic> json) {
    return ConfiguracaoMaquinaModel(
      id: json['id'] as int?,
      registroMaquinaId: json['registroMaquinaId'] as int,
      chaveConfiguracao: json['chaveConfiguracao'] as String,
      valorConfiguracao: json['valorConfiguracao'] as String,
      descricao: json['descricao'] as String?,
      tipoValor: json['tipoValor'] as String? ?? 'STRING',
      valorPadrao: json['valorPadrao'] as String?,
      obrigatorio: json['obrigatorio'] as bool? ?? false,
      ativo: json['ativo'] as bool? ?? true,
      criadoEm: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : null,
      atualizadoEm: json['atualizadoEm'] != null
          ? DateTime.parse(json['atualizadoEm'] as String)
          : null,
    );
  }

  /// Converte o ConfiguracaoMaquinaModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registroMaquinaId': registroMaquinaId,
      'chaveConfiguracao': chaveConfiguracao,
      'valorConfiguracao': valorConfiguracao,
      'descricao': descricao,
      'tipoValor': tipoValor,
      'valorPadrao': valorPadrao,
      'obrigatorio': obrigatorio,
      'ativo': ativo,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
    };
  }

  /// Cria um ConfiguracaoMaquinaModel a partir de uma entidade ConfiguracaoMaquina
  factory ConfiguracaoMaquinaModel.fromEntity(ConfiguracaoMaquina config) {
    return ConfiguracaoMaquinaModel(
      id: config.id,
      registroMaquinaId: config.registroMaquinaId,
      chaveConfiguracao: config.chaveConfiguracao,
      valorConfiguracao: config.valorConfiguracao,
      descricao: config.descricao,
      tipoValor: config.tipoValor,
      valorPadrao: config.valorPadrao,
      obrigatorio: config.obrigatorio,
      ativo: config.ativo,
      criadoEm: config.criadoEm,
      atualizadoEm: config.atualizadoEm,
    );
  }

  /// Converte o modelo para entidade de domínio
  ConfiguracaoMaquina toEntity() {
    return ConfiguracaoMaquina(
      id: id,
      registroMaquinaId: registroMaquinaId,
      chaveConfiguracao: chaveConfiguracao,
      valorConfiguracao: valorConfiguracao,
      descricao: descricao,
      tipoValor: tipoValor,
      valorPadrao: valorPadrao,
      obrigatorio: obrigatorio,
      ativo: ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
    );
  }

  /// Cria uma cópia do modelo com valores atualizados
  ConfiguracaoMaquinaModel copyWith({
    int? id,
    int? registroMaquinaId,
    String? chaveConfiguracao,
    String? valorConfiguracao,
    String? descricao,
    String? tipoValor,
    String? valorPadrao,
    bool? obrigatorio,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return ConfiguracaoMaquinaModel(
      id: id ?? this.id,
      registroMaquinaId: registroMaquinaId ?? this.registroMaquinaId,
      chaveConfiguracao: chaveConfiguracao ?? this.chaveConfiguracao,
      valorConfiguracao: valorConfiguracao ?? this.valorConfiguracao,
      descricao: descricao ?? this.descricao,
      tipoValor: tipoValor ?? this.tipoValor,
      valorPadrao: valorPadrao ?? this.valorPadrao,
      obrigatorio: obrigatorio ?? this.obrigatorio,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return 'ConfiguracaoMaquinaModel(id: $id, registroMaquinaId: $registroMaquinaId, chaveConfiguracao: $chaveConfiguracao, valorConfiguracao: $valorConfiguracao, ativo: $ativo)';
  }
}