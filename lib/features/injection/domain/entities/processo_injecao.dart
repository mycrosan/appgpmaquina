import 'package:equatable/equatable.dart';

/// Status possíveis para um processo de injeção
enum StatusProcesso {
  aguardando,
  iniciando,
  injetando,
  pausado,
  concluido,
  erro,
  cancelado,
}

/// Entidade que representa um processo de injeção de ar
/// Contém informações sobre o estado atual da injeção
class ProcessoInjecao extends Equatable {
  final String id;
  final int carcacaId;
  final String carcacaCodigo;
  final int regraId;
  final int matrizId;
  final String matrizNome;
  final StatusProcesso status;
  final int tempoTotal; // Tempo total em segundos
  final int tempoDecorrido; // Tempo decorrido em segundos
  final double pressaoInicial; // Pressão inicial em PSI
  final double pressaoAtual; // Pressão atual em PSI
  final double pressaoAlvo; // Pressão alvo em PSI
  final int pulsoAtual; // Pulso atual (se aplicável)
  final int totalPulsos; // Total de pulsos
  final String? observacoes;
  final String? motivoErro;
  final DateTime iniciadoEm;
  final DateTime? finalizadoEm;
  final int userId;
  final String userName;

  const ProcessoInjecao({
    required this.id,
    required this.carcacaId,
    required this.carcacaCodigo,
    required this.regraId,
    required this.matrizId,
    required this.matrizNome,
    required this.status,
    required this.tempoTotal,
    this.tempoDecorrido = 0,
    required this.pressaoInicial,
    required this.pressaoAtual,
    required this.pressaoAlvo,
    this.pulsoAtual = 0,
    this.totalPulsos = 1,
    this.observacoes,
    this.motivoErro,
    required this.iniciadoEm,
    this.finalizadoEm,
    required this.userId,
    required this.userName,
  });

  /// Verifica se o processo está em execução
  bool get isRunning {
    return status == StatusProcesso.iniciando || 
           status == StatusProcesso.injetando;
  }

  /// Verifica se o processo foi finalizado (com sucesso ou erro)
  bool get isFinished {
    return status == StatusProcesso.concluido || 
           status == StatusProcesso.erro || 
           status == StatusProcesso.cancelado;
  }

  /// Verifica se o processo pode ser pausado
  bool get canBePaused {
    return status == StatusProcesso.injetando;
  }

  /// Verifica se o processo pode ser retomado
  bool get canBeResumed {
    return status == StatusProcesso.pausado;
  }

  /// Verifica se o processo pode ser cancelado
  bool get canBeCanceled {
    return status == StatusProcesso.aguardando || 
           status == StatusProcesso.iniciando || 
           status == StatusProcesso.injetando || 
           status == StatusProcesso.pausado;
  }

  /// Calcula o progresso do processo (0.0 a 1.0)
  double get progress {
    if (tempoTotal <= 0) return 0.0;
    return (tempoDecorrido / tempoTotal).clamp(0.0, 1.0);
  }

  /// Calcula o tempo restante em segundos
  int get tempoRestante {
    return (tempoTotal - tempoDecorrido).clamp(0, tempoTotal);
  }

  /// Calcula a diferença de pressão alcançada
  double get diferencaPressao {
    return pressaoAtual - pressaoInicial;
  }

  /// Verifica se a pressão alvo foi atingida
  bool get pressaoAlvoAtingida {
    const tolerance = 0.5; // Tolerância de 0.5 PSI
    return (pressaoAtual - pressaoAlvo).abs() <= tolerance;
  }

  /// Calcula a duração total do processo
  Duration? get duracao {
    if (finalizadoEm == null) return null;
    return finalizadoEm!.difference(iniciadoEm);
  }

  /// Retorna uma descrição do status atual
  String get statusDescription {
    switch (status) {
      case StatusProcesso.aguardando:
        return 'Aguardando início';
      case StatusProcesso.iniciando:
        return 'Iniciando processo';
      case StatusProcesso.injetando:
        return 'Injetando ar';
      case StatusProcesso.pausado:
        return 'Processo pausado';
      case StatusProcesso.concluido:
        return 'Processo concluído';
      case StatusProcesso.erro:
        return 'Erro no processo';
      case StatusProcesso.cancelado:
        return 'Processo cancelado';
    }
  }

  /// Cria uma cópia do processo com campos atualizados
  ProcessoInjecao copyWith({
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
    return ProcessoInjecao(
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

  @override
  List<Object?> get props => [
        id,
        carcacaId,
        carcacaCodigo,
        regraId,
        matrizId,
        matrizNome,
        status,
        tempoTotal,
        tempoDecorrido,
        pressaoInicial,
        pressaoAtual,
        pressaoAlvo,
        pulsoAtual,
        totalPulsos,
        observacoes,
        motivoErro,
        iniciadoEm,
        finalizadoEm,
        userId,
        userName,
      ];

  @override
  String toString() {
    return 'ProcessoInjecao(id: $id, carcaca: $carcacaCodigo, status: $status, progresso: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}