import '../../domain/entities/machine_config.dart';
import '../../domain/entities/matriz.dart';
import 'matriz_model.dart';

/// Modelo de dados para MachineConfig que estende a entidade
/// Adiciona funcionalidades de serialização JSON
class MachineConfigModel extends MachineConfig {
  const MachineConfigModel({
    super.id,
    required super.deviceId,
    required super.userId,
    required super.matrizId,
    super.matriz,
    required super.configuredAt,
    super.updatedAt,
    super.isActive,
  });

  /// Cria um MachineConfigModel a partir de JSON
  factory MachineConfigModel.fromJson(Map<String, dynamic> json) {
    return MachineConfigModel(
      id: json['id'] as int?,
      deviceId: json['device_id'] as String,
      userId: json['user_id'] as String,
      matrizId: json['matriz_id'] as int,
      matriz: json['matriz'] != null 
          ? MatrizModel.fromJson(json['matriz'] as Map<String, dynamic>)
          : null,
      configuredAt: DateTime.parse(json['configured_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converte o MachineConfigModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'user_id': userId,
      'matriz_id': matrizId,
      'matriz': matriz != null ? MatrizModel.fromEntity(matriz!).toJson() : null,
      'configured_at': configuredAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Cria um MachineConfigModel a partir de uma entidade MachineConfig
  factory MachineConfigModel.fromEntity(MachineConfig config) {
    return MachineConfigModel(
      id: config.id,
      deviceId: config.deviceId,
      userId: config.userId,
      matrizId: config.matrizId,
      matriz: config.matriz,
      configuredAt: config.configuredAt,
      updatedAt: config.updatedAt,
      isActive: config.isActive,
    );
  }

  /// Cria uma cópia do MachineConfigModel com campos atualizados
  MachineConfigModel copyWith({
    int? id,
    String? deviceId,
    String? userId,
    int? matrizId,
    Matriz? matriz,
    DateTime? configuredAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return MachineConfigModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      matrizId: matrizId ?? this.matrizId,
      matriz: matriz ?? this.matriz,
      configuredAt: configuredAt ?? this.configuredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'MachineConfigModel(id: $id, deviceId: $deviceId, userId: $userId, matrizId: $matrizId, isActive: $isActive)';
  }
}