import 'package:equatable/equatable.dart';

import '../../domain/entities/registro_maquina.dart';

/// Estados do BLoC para registro de máquinas
abstract class RegistroMaquinaState extends Equatable {
  const RegistroMaquinaState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class RegistroMaquinaInitial extends RegistroMaquinaState {
  const RegistroMaquinaInitial();
}

/// Estado de carregamento
class RegistroMaquinaLoading extends RegistroMaquinaState {
  const RegistroMaquinaLoading();
}

/// Estado quando máquina é carregada com sucesso
class RegistroMaquinaLoaded extends RegistroMaquinaState {
  final RegistroMaquina maquina;

  const RegistroMaquinaLoaded({required this.maquina});

  @override
  List<Object> get props => [maquina];
}

/// Estado quando máquina é criada com sucesso
class RegistroMaquinaCreated extends RegistroMaquinaState {
  final RegistroMaquina maquina;

  const RegistroMaquinaCreated({required this.maquina});

  @override
  List<Object> get props => [maquina];
}

/// Estado quando máquina é atualizada com sucesso
class RegistroMaquinaUpdated extends RegistroMaquinaState {
  final RegistroMaquina maquina;
  final String message;

  const RegistroMaquinaUpdated({
    required this.maquina,
    this.message = 'Máquina atualizada com sucesso',
  });

  @override
  List<Object?> get props => [maquina, message];
}

/// Estado de erro
class RegistroMaquinaError extends RegistroMaquinaState {
  final String message;

  const RegistroMaquinaError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de atualizando
class RegistroMaquinaUpdating extends RegistroMaquinaState {
  final RegistroMaquina maquina;

  const RegistroMaquinaUpdating({required this.maquina});

  @override
  List<Object?> get props => [maquina];
}

/// Estado quando lista de máquinas é carregada com sucesso
class RegistroMaquinasLoaded extends RegistroMaquinaState {
  final List<RegistroMaquina> maquinas;

  const RegistroMaquinasLoaded({required this.maquinas});

  @override
  List<Object> get props => [maquinas];
}

/// Estado quando a máquina atual do dispositivo é carregada
class CurrentDeviceMachineLoaded extends RegistroMaquinaState {
  final RegistroMaquina? currentMachine;

  const CurrentDeviceMachineLoaded({required this.currentMachine});

  @override
  List<Object?> get props => [currentMachine];
}