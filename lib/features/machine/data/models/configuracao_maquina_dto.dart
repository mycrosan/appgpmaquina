/// DTOs para configuração de máquina
/// Baseados na especificação OpenAPI do Swagger

/// DTO para criação de configuração de máquina
/// Baseado no schema ConfiguracaoMaquinaCreateDTO
class ConfiguracaoMaquinaCreateDTO {
  final int maquinaId;
  final int matrizId;
  final String celularId;
  final String? descricao;
  final String? atributos;

  const ConfiguracaoMaquinaCreateDTO({
    required this.maquinaId,
    required this.matrizId,
    required this.celularId,
    this.descricao,
    this.atributos,
  });

  /// Cria um DTO a partir de JSON
  factory ConfiguracaoMaquinaCreateDTO.fromJson(Map<String, dynamic> json) {
    return ConfiguracaoMaquinaCreateDTO(
      maquinaId: json['maquinaId'] as int,
      matrizId: json['matrizId'] as int,
      celularId: json['celularId'] as String,
      descricao: json['descricao'] as String?,
      atributos: json['atributos'] as String?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'maquinaId': maquinaId,
      'matrizId': matrizId,
      'celularId': celularId,
      if (descricao != null) 'descricao': descricao,
      if (atributos != null) 'atributos': atributos,
    };
  }
}

/// DTO para resposta de configuração de máquina
/// Baseado no schema ConfiguracaoMaquinaResponseDTO
class ConfiguracaoMaquinaResponseDTO {
  final int? id;
  final String? celularId;
  final String? descricao;
  final String? atributos;
  final int? matrizId;
  final String? matrizNome;
  final int? maquinaId;
  final String? maquinaNome;
  final String? dtCreate;
  final String? dtUpdate;
  final String? dtDelete;
  final int? usuarioId;

  const ConfiguracaoMaquinaResponseDTO({
    this.id,
    this.celularId,
    this.descricao,
    this.atributos,
    this.matrizId,
    this.matrizNome,
    this.maquinaId,
    this.maquinaNome,
    this.dtCreate,
    this.dtUpdate,
    this.dtDelete,
    this.usuarioId,
  });

  /// Cria um DTO a partir de JSON
  factory ConfiguracaoMaquinaResponseDTO.fromJson(Map<String, dynamic> json) {
    return ConfiguracaoMaquinaResponseDTO(
      id: json['id'] != null ? json['id'] as int : null,
      celularId: json['celularId'] != null ? json['celularId'] as String : null,
      descricao: json['descricao'] != null ? json['descricao'] as String : null,
      atributos: json['atributos'] != null ? json['atributos'] as String : null,
      matrizId: json['matrizId'] != null ? json['matrizId'] as int : null,
      matrizNome: json['matrizNome'] != null ? json['matrizNome'] as String : null,
      maquinaId: json['maquinaId'] != null ? json['maquinaId'] as int : null,
      maquinaNome: json['maquinaNome'] != null ? json['maquinaNome'] as String : null,
      dtCreate: json['dtCreate'] != null ? json['dtCreate'] as String : null,
      dtUpdate: json['dtUpdate'] != null ? json['dtUpdate'] as String : null,
      dtDelete: json['dtDelete'] != null ? json['dtDelete'] as String : null,
      usuarioId: json['usuarioId'] != null ? json['usuarioId'] as int : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'celularId': celularId,
      'descricao': descricao,
      'atributos': atributos,
      'matrizId': matrizId,
      'matrizNome': matrizNome,
      'maquinaId': maquinaId,
      'maquinaNome': maquinaNome,
      'dtCreate': dtCreate,
      'dtUpdate': dtUpdate,
      'dtDelete': dtDelete,
      'usuarioId': usuarioId,
    };
  }
}