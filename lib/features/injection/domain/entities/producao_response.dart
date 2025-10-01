import 'package:equatable/equatable.dart';
import 'carcaca.dart';

/// Entidade para Matriz
class Matriz extends Equatable {
  final int id;
  final String descricao;

  const Matriz({
    required this.id,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id, descricao];
}

/// Entidade para Camelback
class Camelback extends Equatable {
  final int id;
  final String descricao;

  const Camelback({
    required this.id,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id, descricao];
}

/// Entidade para Espessuramento
class Espessuramento extends Equatable {
  final int id;
  final String descricao;

  const Espessuramento({
    required this.id,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id, descricao];
}

/// Entidade para Antiquebra
class Antiquebra extends Equatable {
  final int id;
  final String descricao;

  const Antiquebra({
    required this.id,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id, descricao];
}

/// Entidade para Usuário
class Usuario extends Equatable {
  final String nome;
  final String login;
  final bool enabled;
  final String password;
  final List<String> authorities;
  final bool accountNonExpired;
  final bool accountNonLocked;
  final bool credentialsNonExpired;
  final String username;

  const Usuario({
    required this.nome,
    required this.login,
    required this.enabled,
    required this.password,
    required this.authorities,
    required this.accountNonExpired,
    required this.accountNonLocked,
    required this.credentialsNonExpired,
    required this.username,
  });

  @override
  List<Object?> get props => [
        nome,
        login,
        enabled,
        password,
        authorities,
        accountNonExpired,
        accountNonLocked,
        credentialsNonExpired,
        username,
      ];
}

/// Entidade para Regra de Produção
class RegraProducao extends Equatable {
  final int id;
  final double tamanhoMin;
  final double tamanhoMax;
  final String tempo;
  final Matriz matriz;
  final Medida medida;
  final Modelo modelo;
  final Pais pais;
  final Camelback camelback;
  final Espessuramento espessuramento;
  final Antiquebra antiquebra1;
  final Antiquebra antiquebra2;
  final Antiquebra antiquebra3;
  final DateTime dtCreate;
  final DateTime? dtUpdate;
  final DateTime? dtDelete;

  const RegraProducao({
    required this.id,
    required this.tamanhoMin,
    required this.tamanhoMax,
    required this.tempo,
    required this.matriz,
    required this.medida,
    required this.modelo,
    required this.pais,
    required this.camelback,
    required this.espessuramento,
    required this.antiquebra1,
    required this.antiquebra2,
    required this.antiquebra3,
    required this.dtCreate,
    this.dtUpdate,
    this.dtDelete,
  });

  @override
  List<Object?> get props => [
        id,
        tamanhoMin,
        tamanhoMax,
        tempo,
        matriz,
        medida,
        modelo,
        pais,
        camelback,
        espessuramento,
        antiquebra1,
        antiquebra2,
        antiquebra3,
        dtCreate,
        dtUpdate,
        dtDelete,
      ];
}

/// Entidade principal para Resposta da API de Produção
class ProducaoResponse extends Equatable {
  final int id;
  final Carcaca carcaca;
  final double medidaPneuRaspado;
  final String? dados;
  final RegraProducao regra;
  final String? fotos;
  final DateTime dtCreate;
  final DateTime? dtUpdate;
  final String? uuid;
  final Usuario criadoPor;

  const ProducaoResponse({
    required this.id,
    required this.carcaca,
    required this.medidaPneuRaspado,
    this.dados,
    required this.regra,
    this.fotos,
    required this.dtCreate,
    this.dtUpdate,
    this.uuid,
    required this.criadoPor,
  });

  @override
  List<Object?> get props => [
        id,
        carcaca,
        medidaPneuRaspado,
        dados,
        regra,
        fotos,
        dtCreate,
        dtUpdate,
        uuid,
        criadoPor,
      ];
}