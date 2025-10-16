import 'package:equatable/equatable.dart';
import 'matriz.dart';

/// Entidade que representa a configuração atual da máquina
/// Contém informações sobre qual matriz está aceita para a máquina
/// vinculada ao usuário/dispositivo
class MachineConfig extends Equatable {
  final int? id;
  final String deviceId; // ID único do dispositivo/máquina
  final String userId; // ID do usuário
  final int matrizId; // ID da matriz selecionada
  final int? registroMaquinaId; // ID do registro da máquina
  final Matriz? matriz; // Dados completos da matriz (opcional)
  final DateTime configuredAt; // Quando foi configurada
  final DateTime? updatedAt; // Última atualização
  final bool isActive; // Se a configuração está ativa

  const MachineConfig({
    this.id,
    required this.deviceId,
    required this.userId,
    required this.matrizId,
    this.registroMaquinaId,
    this.matriz,
    required this.configuredAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Verifica se a configuração é válida
  bool get isValid {
    return isActive && 
           deviceId.isNotEmpty && 
           userId.isNotEmpty && 
           matrizId > 0;
  }

  /// Retorna uma descrição da configuração
  String get description {
    if (matriz != null) {
      return 'Máquina configurada com matriz: ${matriz!.fullDescription}';
    }
    return 'Máquina configurada com matriz ID: $matrizId';
  }

  /// Cria uma cópia da configuração com campos atualizados
  MachineConfig copyWith({
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
    return MachineConfig(
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
  List<Object?> get props => [
        id,
        deviceId,
        userId,
        matrizId,
        registroMaquinaId,
        matriz,
        configuredAt,
        updatedAt,
        isActive,
      ];

  @override
  String toString() {
    return 'MachineConfig(id: $id, deviceId: $deviceId, userId: $userId, matrizId: $matrizId, isActive: $isActive)';
  }
}