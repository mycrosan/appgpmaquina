import '../../domain/entities/carcaca.dart';

/// Modelo de dados para Marca
class MarcaModel extends Marca {
  const MarcaModel({
    required super.id,
    required super.descricao,
  });

  factory MarcaModel.fromJson(Map<String, dynamic> json) {
    return MarcaModel(
      id: json['id'] as int,
      descricao: json['descricao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }
}

/// Modelo de dados para Modelo
class ModeloModel extends Modelo {
  const ModeloModel({
    required super.id,
    required super.descricao,
    required super.marca,
  });

  factory ModeloModel.fromJson(Map<String, dynamic> json) {
    return ModeloModel(
      id: json['id'] as int,
      descricao: json['descricao'] as String,
      marca: MarcaModel.fromJson(json['marca'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'marca': (marca as MarcaModel).toJson(),
    };
  }
}

/// Modelo de dados para Medida
class MedidaModel extends Medida {
  const MedidaModel({
    required super.id,
    required super.descricao,
  });

  factory MedidaModel.fromJson(Map<String, dynamic> json) {
    return MedidaModel(
      id: json['id'] as int,
      descricao: json['descricao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }
}

/// Modelo de dados para País
class PaisModel extends Pais {
  const PaisModel({
    required super.id,
    required super.descricao,
  });

  factory PaisModel.fromJson(Map<String, dynamic> json) {
    return PaisModel(
      id: json['id'] as int,
      descricao: json['descricao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }
}

/// Modelo de dados para Status da Carcaça
class StatusCarcacaModel extends StatusCarcaca {
  const StatusCarcacaModel({
    required super.id,
    required super.descricao,
  });

  factory StatusCarcacaModel.fromJson(Map<String, dynamic> json) {
    return StatusCarcacaModel(
      id: json['id'] as int,
      descricao: json['descricao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }
}

/// Modelo de dados para Carcaça
/// Estende a entidade Carcaca e adiciona funcionalidades de serialização
class CarcacaModel extends Carcaca {
  const CarcacaModel({
    required super.id,
    required super.numeroEtiqueta,
    required super.dot,
    required super.status,
    super.dados,
    required super.modelo,
    required super.medida,
    required super.pais,
    super.fotos,
    required super.statusCarcaca,
    required super.dtCreate,
    super.dtUpdate,
    required super.uuid,
  });

  /// Cria uma instância de CarcacaModel a partir de JSON
  factory CarcacaModel.fromJson(Map<String, dynamic> json) {
    return CarcacaModel(
      id: json['id'] as int,
      numeroEtiqueta: json['numero_etiqueta'] as String,
      dot: json['dot'] as String,
      status: json['status'] as String,
      dados: json['dados'] as String?,
      modelo: ModeloModel.fromJson(json['modelo'] as Map<String, dynamic>),
      medida: MedidaModel.fromJson(json['medida'] as Map<String, dynamic>),
      pais: PaisModel.fromJson(json['pais'] as Map<String, dynamic>),
      fotos: json['fotos'] as String?,
      statusCarcaca: StatusCarcacaModel.fromJson(json['status_carcaca'] as Map<String, dynamic>),
      dtCreate: DateTime.parse(json['dt_create'] as String),
      dtUpdate: json['dt_update'] != null 
          ? DateTime.parse(json['dt_update'] as String) 
          : null,
      uuid: json['uuid'] as String,
    );
  }

  /// Converte a instância para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_etiqueta': numeroEtiqueta,
      'dot': dot,
      'status': status,
      'dados': dados,
      'modelo': (modelo as ModeloModel).toJson(),
      'medida': (medida as MedidaModel).toJson(),
      'pais': (pais as PaisModel).toJson(),
      'fotos': fotos,
      'status_carcaca': (statusCarcaca as StatusCarcacaModel).toJson(),
      'dt_create': dtCreate.toIso8601String(),
      'dt_update': dtUpdate?.toIso8601String(),
      'uuid': uuid,
    };
  }
}