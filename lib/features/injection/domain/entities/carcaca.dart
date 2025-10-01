import 'package:equatable/equatable.dart';

/// Entidade para Marca
class Marca extends Equatable {
  final int id;
  final String descricao;

  const Marca({
    required this.id,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id, descricao];
}

/// Entidade para Modelo
class Modelo extends Equatable {
  final int id;
  final String descricao;
  final Marca marca;

  const Modelo({
    required this.id,
    required this.descricao,
    required this.marca,
  });

  @override
  List<Object?> get props => [id, descricao, marca];
}

/// Entidade para Medida
class Medida extends Equatable {
  final int id;
  final String descricao;

  const Medida({
    required this.id,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id, descricao];
}

/// Entidade para País
class Pais extends Equatable {
  final int id;
  final String descricao;

  const Pais({
    required this.id,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id, descricao];
}

/// Entidade para Status da Carcaça
class StatusCarcaca extends Equatable {
  final int id;
  final String descricao;

  const StatusCarcaca({
    required this.id,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id, descricao];
}

/// Entidade principal para Carcaça
class Carcaca extends Equatable {
  final int id;
  final String numeroEtiqueta;
  final String dot;
  final String status;
  final String? dados;
  final Modelo modelo;
  final Medida medida;
  final Pais pais;
  final String? fotos;
  final StatusCarcaca statusCarcaca;
  final DateTime dtCreate;
  final DateTime? dtUpdate;
  final String uuid;

  const Carcaca({
    required this.id,
    required this.numeroEtiqueta,
    required this.dot,
    required this.status,
    this.dados,
    required this.modelo,
    required this.medida,
    required this.pais,
    this.fotos,
    required this.statusCarcaca,
    required this.dtCreate,
    this.dtUpdate,
    required this.uuid,
  });

  @override
  List<Object?> get props => [
        id,
        numeroEtiqueta,
        dot,
        status,
        dados,
        modelo,
        medida,
        pais,
        fotos,
        statusCarcaca,
        dtCreate,
        dtUpdate,
        uuid,
      ];
}