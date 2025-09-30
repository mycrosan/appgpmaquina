import 'package:equatable/equatable.dart';

/// Entidade que representa uma configuração específica de uma máquina
/// Contém pares chave-valor para configurações personalizadas
class ConfiguracaoMaquina extends Equatable {
  final int? id;
  final int registroMaquinaId; // ID da máquina registrada
  final String
  chaveConfiguracao; // Chave da configuração (ex: "temperatura_maxima")
  final String valorConfiguracao; // Valor da configuração (ex: "80")
  final String? descricao; // Descrição da configuração
  final String tipoValor; // Tipo do valor (STRING, NUMBER, BOOLEAN, etc.)
  final String? valorPadrao; // Valor padrão da configuração
  final bool obrigatorio; // Se a configuração é obrigatória
  final bool ativo; // Se a configuração está ativa
  final DateTime? criadoEm; // Data de criação
  final DateTime? atualizadoEm; // Data da última atualização

  const ConfiguracaoMaquina({
    this.id,
    required this.registroMaquinaId,
    required this.chaveConfiguracao,
    required this.valorConfiguracao,
    this.descricao,
    this.tipoValor = 'STRING',
    this.valorPadrao,
    this.obrigatorio = false,
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });

  /// Verifica se a configuração é válida
  bool get isValid {
    return ativo &&
        chaveConfiguracao.isNotEmpty &&
        valorConfiguracao.isNotEmpty &&
        registroMaquinaId > 0;
  }

  /// Retorna uma descrição da configuração
  String get fullDescription {
    if (descricao != null && descricao!.isNotEmpty) {
      return '$chaveConfiguracao: $descricao';
    }
    return '$chaveConfiguracao: $valorConfiguracao';
  }

  /// Converte o valor da configuração para o tipo apropriado
  dynamic get typedValue {
    switch (tipoValor.toUpperCase()) {
      case 'NUMBER':
      case 'INTEGER':
        return int.tryParse(valorConfiguracao) ??
            double.tryParse(valorConfiguracao);
      case 'DOUBLE':
      case 'FLOAT':
        return double.tryParse(valorConfiguracao);
      case 'BOOLEAN':
        return valorConfiguracao.toLowerCase() == 'true' ||
            valorConfiguracao == '1';
      default:
        return valorConfiguracao;
    }
  }

  /// Cria uma cópia da configuração com campos atualizados
  ConfiguracaoMaquina copyWith({
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
    return ConfiguracaoMaquina(
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
  List<Object?> get props => [
    id,
    registroMaquinaId,
    chaveConfiguracao,
    valorConfiguracao,
    descricao,
    tipoValor,
    valorPadrao,
    obrigatorio,
    ativo,
    criadoEm,
    atualizadoEm,
  ];

  @override
  String toString() {
    return 'ConfiguracaoMaquina(id: $id, registroMaquinaId: $registroMaquinaId, chaveConfiguracao: $chaveConfiguracao, valorConfiguracao: $valorConfiguracao, ativo: $ativo)';
  }
}