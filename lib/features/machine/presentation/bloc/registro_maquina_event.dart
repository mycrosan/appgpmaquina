import 'package:equatable/equatable.dart';

import '../../domain/entities/registro_maquina.dart';

/// Eventos do BLoC para registro de máquinas
abstract class RegistroMaquinaEvent extends Equatable {
  const RegistroMaquinaEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para criar nova máquina
class CreateMaquinaEvent extends RegistroMaquinaEvent {
  final RegistroMaquina maquina;

  const CreateMaquinaEvent({required this.maquina});

  @override
  List<Object> get props => [maquina];
}

/// Evento para buscar máquina por ID
class GetMaquinaByIdEvent extends RegistroMaquinaEvent {
  final int id;

  const GetMaquinaByIdEvent({required this.id});

  @override
  List<Object> get props => [id];
}

/// Evento para atualizar máquina
class UpdateMaquinaEvent extends RegistroMaquinaEvent {
  final RegistroMaquina maquina;

  const UpdateMaquinaEvent({required this.maquina});

  @override
  List<Object?> get props => [maquina];
}

/// Evento para limpar o estado
class ClearRegistroMaquinaEvent extends RegistroMaquinaEvent {
  const ClearRegistroMaquinaEvent();
}

/// Evento para resetar o estado de atualização
class ResetUpdateStatusEvent extends RegistroMaquinaEvent {
  const ResetUpdateStatusEvent();
}

/// Evento para carregar lista de todas as máquinas
class GetAllMaquinasEvent extends RegistroMaquinaEvent {
  const GetAllMaquinasEvent();
}

/// Evento para buscar a máquina atual do dispositivo
class GetCurrentDeviceMachineEvent extends RegistroMaquinaEvent {
  const GetCurrentDeviceMachineEvent();
}