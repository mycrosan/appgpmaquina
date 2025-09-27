import '../../domain/entities/processo_injecao.dart';

/// Modelo de dados para ProcessoInjecao
/// Estende a entidade ProcessoInjecao e adiciona funcionalidades de serialização
class ProcessoInjecaoModel extends ProcessoInjecao {
  const ProcessoInjecaoModel({
    required super.id,
    required super.carcacaId,
    required super.carcacaCodigo,
    required super.regraId,
    required super.matrizId,
    required super.matrizNome,
    required super.status,
    required super.tempoTotal,
    super.tempoDecorrido = 0,
    required super.pressaoInicial,
    required super.pressaoAtual,
    required super.pressaoAlvo,
    super.pulsoAtual = 0,
    super.totalPulsos = 1,
    super.observacoes,
    super.motivoErro,
    required super.iniciadoEm,
    super.finalizadoEm,
    required super.userId,
    required super.userName,
  });

  /// Cria uma instância de ProcessoInjecaoModel a partir de JSON
  factory ProcessoInjecaoModel.fromJson(Map<String, dynamic> json) {
    return ProcessoInjecaoModel(
      id: json['id'] as String,
      carcacaId: json['carcaca_id'] as int,
      carcacaCodigo: json['carcaca_codigo'] as String,
      regraId: json['regra_id'] as int,
      matrizId: json['matriz_id'] as int,
      matrizNome: json['matriz_nome'] as String,
      status: StatusProcesso.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => StatusProcesso.aguardando,
      ),
      tempoTotal: json['tempo_total'] as int,
      tempoDecorrido: json['tempo_decorrido'] as int? ?? 0,
      pressaoInicial: (json['pressao_inicial'] as num).toDouble(),
      pressaoAtual: (json['pressao_atual'] as num).toDouble(),
      pressaoAlvo: (json['pressao_alvo'] as num).toDouble(),
      pulsoAtual: json['pulso_atual'] as int? ?? 0,
      totalPulsos: json['total_pulsos'] as int? ?? 1,
      observacoes: json['observacoes'] as String?,
      motivoErro: json['motivo_erro'] as String?,
      iniciadoEm: DateTime.parse(json['iniciado_em'] as String),
      finalizadoEm: json['finalizado_em'] != null 
          ? DateTime.parse(json['finalizado_em'] as String) 
          : null,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
    );
  }

  /// Converte a instância para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carcaca_id': carcacaId,
      'carcaca_codigo': carcacaCodigo,
      'regra_id': regraId,
      'matriz_id': matrizId,
      'matriz_nome': matrizNome,
      'status': status.toString().split('.').last,
      'tempo_total': tempoTotal,
      'tempo_decorrido': tempoDecorrido,
      'pressao_inicial': pressaoInicial,
      'pressao_atual': pressaoAtual,
      'pressao_alvo': pressaoAlvo,
      'pulso_atual': pulsoAtual,
      'total_pulsos': totalPulsos,
      'observacoes': observacoes,
      'motivo_erro': motivoErro,
      'iniciado_em': iniciadoEm.toIso8601String(),
      'finalizado_em': finalizadoEm?.toIso8601String(),
      'user_id': userId,
      'user_name': userName,
    };
  }

  /// Cria uma instância de ProcessoInjecaoModel a partir de uma entidade ProcessoInjecao
  factory ProcessoInjecaoModel.fromEntity(ProcessoInjecao processo) {
    return ProcessoInjecaoModel(
      id: processo.id,
      carcacaId: processo.carcacaId,
      carcacaCodigo: processo.carcacaCodigo,
      regraId: processo.regraId,
      matrizId: processo.matrizId,
      matrizNome: processo.matrizNome,
      status: processo.status,
      tempoTotal: processo.tempoTotal,
      tempoDecorrido: processo.tempoDecorrido,
      pressaoInicial: processo.pressaoInicial,
      pressaoAtual: processo.pressaoAtual,
      pressaoAlvo: processo.pressaoAlvo,
      pulsoAtual: processo.pulsoAtual,
      totalPulsos: processo.totalPulsos,
      observacoes: processo.observacoes,
      motivoErro: processo.motivoErro,
      iniciadoEm: processo.iniciadoEm,
      finalizadoEm: processo.finalizadoEm,
      userId: processo.userId,
      userName: processo.userName,
    );
  }

  /// Cria uma cópia da instância com valores opcionalmente modificados
  @override
  ProcessoInjecaoModel copyWith({
    String? id,
    int? carcacaId,
    String? carcacaCodigo,
    int? regraId,
    int? matrizId,
    String? matrizNome,
    StatusProcesso? status,
    int? tempoTotal,
    int? tempoDecorrido,
    double? pressaoInicial,
    double? pressaoAtual,
    double? pressaoAlvo,
    int? pulsoAtual,
    int? totalPulsos,
    String? observacoes,
    String? motivoErro,
    DateTime? iniciadoEm,
    DateTime? finalizadoEm,
    int? userId,
    String? userName,
  }) {
    return ProcessoInjecaoModel(
      id: id ?? this.id,
      carcacaId: carcacaId ?? this.carcacaId,
      carcacaCodigo: carcacaCodigo ?? this.carcacaCodigo,
      regraId: regraId ?? this.regraId,
      matrizId: matrizId ?? this.matrizId,
      matrizNome: matrizNome ?? this.matrizNome,
      status: status ?? this.status,
      tempoTotal: tempoTotal ?? this.tempoTotal,
      tempoDecorrido: tempoDecorrido ?? this.tempoDecorrido,
      pressaoInicial: pressaoInicial ?? this.pressaoInicial,
      pressaoAtual: pressaoAtual ?? this.pressaoAtual,
      pressaoAlvo: pressaoAlvo ?? this.pressaoAlvo,
      pulsoAtual: pulsoAtual ?? this.pulsoAtual,
      totalPulsos: totalPulsos ?? this.totalPulsos,
      observacoes: observacoes ?? this.observacoes,
      motivoErro: motivoErro ?? this.motivoErro,
      iniciadoEm: iniciadoEm ?? this.iniciadoEm,
      finalizadoEm: finalizadoEm ?? this.finalizadoEm,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }
}