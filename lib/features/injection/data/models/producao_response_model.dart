import '../../domain/entities/producao_response.dart';
import 'carcaca_model.dart';

/// Modelo para Matriz
class MatrizModel extends Matriz {
  const MatrizModel({
    required super.id,
    required super.descricao,
  });

  factory MatrizModel.fromJson(Map<String, dynamic> json) {
    return MatrizModel(
      id: json['id'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }
}

/// Modelo para Camelback
class CamelbackModel extends Camelback {
  const CamelbackModel({
    required super.id,
    required super.descricao,
  });

  factory CamelbackModel.fromJson(Map<String, dynamic> json) {
    return CamelbackModel(
      id: json['id'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }
}

/// Modelo para Espessuramento
class EspessuramentoModel extends Espessuramento {
  const EspessuramentoModel({
    required super.id,
    required super.descricao,
  });

  factory EspessuramentoModel.fromJson(Map<String, dynamic> json) {
    return EspessuramentoModel(
      id: json['id'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }
}

/// Modelo para Antiquebra
class AntiquebraModel extends Antiquebra {
  const AntiquebraModel({
    required super.id,
    required super.descricao,
  });

  factory AntiquebraModel.fromJson(Map<String, dynamic> json) {
    return AntiquebraModel(
      id: json['id'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }
}

/// Modelo para Usuário
class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.nome,
    required super.login,
    required super.enabled,
    required super.password,
    required super.authorities,
    required super.accountNonExpired,
    required super.accountNonLocked,
    required super.credentialsNonExpired,
    required super.username,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      nome: json['nome'],
      login: json['login'],
      enabled: json['enabled'],
      password: json['password'],
      authorities: List<String>.from(json['authorities']),
      accountNonExpired: json['accountNonExpired'],
      accountNonLocked: json['accountNonLocked'],
      credentialsNonExpired: json['credentialsNonExpired'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'login': login,
      'enabled': enabled,
      'password': password,
      'authorities': authorities,
      'accountNonExpired': accountNonExpired,
      'accountNonLocked': accountNonLocked,
      'credentialsNonExpired': credentialsNonExpired,
      'username': username,
    };
  }
}

/// Modelo para Regra de Produção
class RegraProducaoModel extends RegraProducao {
  const RegraProducaoModel({
    required super.id,
    required super.tamanhoMin,
    required super.tamanhoMax,
    required super.tempo,
    required super.matriz,
    required super.medida,
    required super.modelo,
    required super.pais,
    required super.camelback,
    required super.espessuramento,
    required super.antiquebra1,
    required super.antiquebra2,
    required super.antiquebra3,
    required super.dtCreate,
    super.dtUpdate,
    super.dtDelete,
  });

  factory RegraProducaoModel.fromJson(Map<String, dynamic> json) {
    return RegraProducaoModel(
      id: json['id'],
      tamanhoMin: json['tamanho_min'].toDouble(),
      tamanhoMax: json['tamanho_max'].toDouble(),
      tempo: json['tempo'],
      matriz: MatrizModel.fromJson(json['matriz']),
      medida: MedidaModel.fromJson(json['medida']),
      modelo: ModeloModel.fromJson(json['modelo']),
      pais: PaisModel.fromJson(json['pais']),
      camelback: CamelbackModel.fromJson(json['camelback']),
      espessuramento: EspessuramentoModel.fromJson(json['espessuramento']),
      antiquebra1: AntiquebraModel.fromJson(json['antiquebra1']),
      antiquebra2: AntiquebraModel.fromJson(json['antiquebra2']),
      antiquebra3: AntiquebraModel.fromJson(json['antiquebra3']),
      dtCreate: DateTime.parse(json['dt_create']),
      dtUpdate: json['dt_update'] != null ? DateTime.parse(json['dt_update']) : null,
      dtDelete: json['dt_delete'] != null ? DateTime.parse(json['dt_delete']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tamanho_min': tamanhoMin,
      'tamanho_max': tamanhoMax,
      'tempo': tempo,
      'matriz': (matriz as MatrizModel).toJson(),
      'medida': (medida as MedidaModel).toJson(),
      'modelo': (modelo as ModeloModel).toJson(),
      'pais': (pais as PaisModel).toJson(),
      'camelback': (camelback as CamelbackModel).toJson(),
      'espessuramento': (espessuramento as EspessuramentoModel).toJson(),
      'antiquebra1': (antiquebra1 as AntiquebraModel).toJson(),
      'antiquebra2': (antiquebra2 as AntiquebraModel).toJson(),
      'antiquebra3': (antiquebra3 as AntiquebraModel).toJson(),
      'dt_create': dtCreate.toIso8601String(),
      'dt_update': dtUpdate?.toIso8601String(),
      'dt_delete': dtDelete?.toIso8601String(),
    };
  }
}

/// Modelo principal para Resposta da API de Produção
class ProducaoResponseModel extends ProducaoResponse {
  const ProducaoResponseModel({
    required super.id,
    required super.carcaca,
    required super.medidaPneuRaspado,
    super.dados,
    required super.regra,
    super.fotos,
    required super.dtCreate,
    super.dtUpdate,
    super.uuid,
    required super.criadoPor,
  });

  factory ProducaoResponseModel.fromJson(Map<String, dynamic> json) {
    return ProducaoResponseModel(
      id: json['id'],
      carcaca: CarcacaModel.fromJson(json['carcaca']),
      medidaPneuRaspado: json['medida_pneu_raspado'].toDouble(),
      dados: json['dados'],
      regra: RegraProducaoModel.fromJson(json['regra']),
      fotos: json['fotos'],
      dtCreate: DateTime.parse(json['dt_create']),
      dtUpdate: json['dt_update'] != null ? DateTime.parse(json['dt_update']) : null,
      uuid: json['uuid'],
      criadoPor: UsuarioModel.fromJson(json['criadoPor']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carcaca': (carcaca as CarcacaModel).toJson(),
      'medida_pneu_raspado': medidaPneuRaspado,
      'dados': dados,
      'regra': (regra as RegraProducaoModel).toJson(),
      'fotos': fotos,
      'dt_create': dtCreate.toIso8601String(),
      'dt_update': dtUpdate?.toIso8601String(),
      'uuid': uuid,
      'criadoPor': (criadoPor as UsuarioModel).toJson(),
    };
  }
}