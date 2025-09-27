import '../../domain/entities/regra.dart';

/// Modelo de dados para Regra
/// Estende a entidade Regra e adiciona funcionalidades de serialização
class RegraModel extends Regra {
  const RegraModel({
    required super.id,
    required super.matrizId,
    required super.matrizNome,
    required super.tempo,
    required super.pressaoMinima,
    required super.pressaoMaxima,
    required super.pressaoRecomendada,
    required super.intervaloPulso,
    required super.numeroPulsos,
    super.observacoes,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Cria uma instância de RegraModel a partir de JSON
  factory RegraModel.fromJson(Map<String, dynamic> json) {
    return RegraModel(
      id: json['id'] as int,
      matrizId: json['matriz_id'] as int,
      matrizNome: json['matriz_nome'] as String,
      tempo: json['tempo'] as int,
      pressaoMinima: (json['pressao_minima'] as num).toDouble(),
      pressaoMaxima: (json['pressao_maxima'] as num).toDouble(),
      pressaoRecomendada: (json['pressao_recomendada'] as num).toDouble(),
      intervaloPulso: json['intervalo_pulso'] as int,
      numeroPulsos: json['numero_pulsos'] as int,
      observacoes: json['observacoes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  /// Converte a instância para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matriz_id': matrizId,
      'matriz_nome': matrizNome,
      'tempo': tempo,
      'pressao_minima': pressaoMinima,
      'pressao_maxima': pressaoMaxima,
      'pressao_recomendada': pressaoRecomendada,
      'intervalo_pulso': intervaloPulso,
      'numero_pulsos': numeroPulsos,
      'observacoes': observacoes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Cria uma instância de RegraModel a partir de uma entidade Regra
  factory RegraModel.fromEntity(Regra regra) {
    return RegraModel(
      id: regra.id,
      matrizId: regra.matrizId,
      matrizNome: regra.matrizNome,
      tempo: regra.tempo,
      pressaoMinima: regra.pressaoMinima,
      pressaoMaxima: regra.pressaoMaxima,
      pressaoRecomendada: regra.pressaoRecomendada,
      intervaloPulso: regra.intervaloPulso,
      numeroPulsos: regra.numeroPulsos,
      observacoes: regra.observacoes,
      isActive: regra.isActive,
      createdAt: regra.createdAt,
      updatedAt: regra.updatedAt,
    );
  }

  /// Cria uma cópia da instância com valores opcionalmente modificados
  @override
  RegraModel copyWith({
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
    return RegraModel(
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
}