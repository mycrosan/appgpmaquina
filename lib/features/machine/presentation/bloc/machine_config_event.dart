import 'package:equatable/equatable.dart';

/// Eventos para o BLoC de configuração da máquina
abstract class MachineConfigEvent extends Equatable {
  const MachineConfigEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar todas as matrizes disponíveis
class LoadAvailableMatrizes extends MachineConfigEvent {
  const LoadAvailableMatrizes();
}

/// Evento para carregar a configuração atual da máquina
class LoadCurrentMachineConfig extends MachineConfigEvent {
  final String deviceId;
  final String userId;

  const LoadCurrentMachineConfig({
    required this.deviceId,
    required this.userId,
  });

  @override
  List<Object> get props => [deviceId, userId];
}

/// Evento para selecionar uma matriz para a máquina
class SelectMatrizForMachine extends MachineConfigEvent {
  final String matrizId;
  final String deviceId;
  final String userId;

  const SelectMatrizForMachine({
    required this.matrizId,
    required this.deviceId,
    required this.userId,
  });

  @override
  List<Object> get props => [matrizId, deviceId, userId];
}

/// Evento para remover a configuração da máquina
class RemoveMachineConfig extends MachineConfigEvent {
  final String deviceId;
  final String userId;

  const RemoveMachineConfig({
    required this.deviceId,
    required this.userId,
  });

  @override
  List<Object> get props => [deviceId, userId];
}

/// Evento para resetar o estado da configuração da máquina
class ResetMachineConfig extends MachineConfigEvent {
  const ResetMachineConfig();
}