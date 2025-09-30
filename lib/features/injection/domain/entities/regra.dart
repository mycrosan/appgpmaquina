import 'package:equatable/equatable.dart';

/// Entidade que representa uma regra de injeção de ar
/// Define os parâmetros para injeção de ar em um tipo específico de pneu
class Regra extends Equatable {
  final int id;
  final int matrizId;
  final String matrizNome;
  final int tempo; // Tempo de injeção em segundos
  final double pressaoMinima; // Pressão mínima em PSI
  final double pressaoMaxima; // Pressão máxima em PSI
  final double pressaoRecomendada; // Pressão recomendada em PSI
  final int intervaloPulso; // Intervalo entre pulsos em milissegundos
  final int numeroPulsos; // Número de pulsos por ciclo
  final String? observacoes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Regra({
    required this.id,
    required this.matrizId,
    required this.matrizNome,
    required this.tempo,
    required this.pressaoMinima,
    required this.pressaoMaxima,
    required this.pressaoRecomendada,
    this.intervaloPulso = 1000,
    this.numeroPulsos = 1,
    this.observacoes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Verifica se a regra está ativa e pode ser aplicada
  bool get canBeApplied {
    return isActive &&
        tempo > 0 &&
        pressaoMinima > 0 &&
        pressaoMaxima > pressaoMinima &&
        pressaoRecomendada >= pressaoMinima &&
        pressaoRecomendada <= pressaoMaxima;
  }

  /// Verifica se uma pressão está dentro da faixa válida
  bool isPressureInRange(double pressure) {
    return pressure >= pressaoMinima && pressure <= pressaoMaxima;
  }

  /// Calcula o tempo total de injeção considerando pulsos e intervalos
  int get tempoTotalInjecao {
    if (numeroPulsos <= 1) return tempo;

    final tempoTotalPulsos = tempo;
    final tempoTotalIntervalos =
        (numeroPulsos - 1) * (intervaloPulso / 1000).round();
    return tempoTotalPulsos + tempoTotalIntervalos;
  }

  /// Retorna uma descrição da regra
  String get description {
    return 'Matriz: $matrizNome | Tempo: ${tempo}s | Pressão: ${pressaoRecomendada} PSI';
  }

  /// Verifica se a regra é adequada para uma pressão atual
  bool isAdequateForCurrentPressure(double currentPressure) {
    // Se a pressão atual já está na faixa recomendada, pode não precisar de injeção
    return currentPressure < pressaoRecomendada;
  }

  /// Cria uma cópia da regra com campos atualizados
  Regra copyWith({
    int? id,
    int? matrizId,
    String? matrizNome,
    int? tempo,
    double? pressaoMinima,
    double? pressaoMaxima,
    double? pressaoRecomendada,
    int? intervaloPulso,
    int? numeroPulsos,
    String? observacoes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Regra(
      id: id ?? this.id,
      matrizId: matrizId ?? this.matrizId,
      matrizNome: matrizNome ?? this.matrizNome,
      tempo: tempo ?? this.tempo,
      pressaoMinima: pressaoMinima ?? this.pressaoMinima,
      pressaoMaxima: pressaoMaxima ?? this.pressaoMaxima,
      pressaoRecomendada: pressaoRecomendada ?? this.pressaoRecomendada,
      intervaloPulso: intervaloPulso ?? this.intervaloPulso,
      numeroPulsos: numeroPulsos ?? this.numeroPulsos,
      observacoes: observacoes ?? this.observacoes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    matrizId,
    matrizNome,
    tempo,
    pressaoMinima,
    pressaoMaxima,
    pressaoRecomendada,
    intervaloPulso,
    numeroPulsos,
    observacoes,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Regra(id: $id, matrizId: $matrizId, matrizNome: $matrizNome, tempo: ${tempo}s, pressao: ${pressaoRecomendada} PSI)';
  }
}