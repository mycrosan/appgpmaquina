import '../../domain/entities/machine_config.dart';
import '../../domain/entities/matriz.dart';
import 'matriz_model.dart';
import 'configuracao_maquina_dto.dart';

/// Modelo de dados para MachineConfig que estende a entidade
/// Adiciona funcionalidades de serialização JSON
class MachineConfigModel extends MachineConfig {
  const MachineConfigModel({
    super.id,
    required super.deviceId,
    required super.userId,
    required super.matrizId,
    super.registroMaquinaId,
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
      registroMaquinaId: json['registro_maquina_id'] as int?,
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
      'registro_maquina_id': registroMaquinaId,
      'matriz': matriz != null
          ? MatrizModel.fromEntity(matriz!).toJson()
          : null,
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
      registroMaquinaId: config.registroMaquinaId,
      matriz: config.matriz,
      configuredAt: config.configuredAt,
      updatedAt: config.updatedAt,
      isActive: config.isActive,
    );
  }

  /// Cria um MachineConfigModel a partir de ConfiguracaoMaquinaResponseDTO
  factory MachineConfigModel.fromConfiguracao(
    ConfiguracaoMaquinaResponseDTO dto, {
    required String deviceId,
    required String userId,
    int? registroMaquinaId,
    Matriz? matriz,
  }) {
    return MachineConfigModel(
      id: dto.id,
      deviceId: deviceId,
      userId: userId,
      matrizId: dto.matrizId ?? 0,
      registroMaquinaId: registroMaquinaId,
      matriz: matriz,
      configuredAt: dto.dtCreate != null
          ? DateTime.parse(dto.dtCreate!)
          : DateTime.now(),
      updatedAt: dto.dtUpdate != null ? DateTime.parse(dto.dtUpdate!) : null,
      // Configuração está ativa apenas se não foi soft-deletada (dt_delete é null)
      isActive: dto.dtDelete == null,
    );
  }

  /// Cria uma cópia do MachineConfigModel com campos atualizados
  MachineConfigModel copyWith({
    int? id,
    String? deviceId,
    String? userId,
    int? matrizId,
    int? registroMaquinaId,
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
      registroMaquinaId: registroMaquinaId ?? this.registroMaquinaId,
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