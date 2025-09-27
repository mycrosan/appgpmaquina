import 'package:equatable/equatable.dart';
import '../../domain/entities/matriz.dart';
import '../../domain/entities/machine_config.dart';

/// Estados para o BLoC de configuração da máquina
abstract class MachineConfigState extends Equatable {
  const MachineConfigState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MachineConfigInitial extends MachineConfigState {
  const MachineConfigInitial();
}

/// Estado de carregamento
class MachineConfigLoading extends MachineConfigState {
  const MachineConfigLoading();
}

/// Estado quando as matrizes disponíveis foram carregadas
class AvailableMatrizesLoaded extends MachineConfigState {
  final List<Matriz> matrizes;

  const AvailableMatrizesLoaded({required this.matrizes});

  @override
  List<Object> get props => [matrizes];
}

/// Estado quando a configuração atual da máquina foi carregada
class CurrentMachineConfigLoaded extends MachineConfigState {
  final MachineConfig? config;

  const CurrentMachineConfigLoaded({required this.config});

  @override
  List<Object?> get props => [config];
}

/// Estado quando uma matriz foi selecionada com sucesso
class MatrizSelectedSuccess extends MachineConfigState {
  final MachineConfig config;

  const MatrizSelectedSuccess({required this.config});

  @override
  List<Object> get props => [config];
}

/// Estado quando a configuração da máquina foi removida com sucesso
class MachineConfigRemovedSuccess extends MachineConfigState {
  const MachineConfigRemovedSuccess();
}

/// Estado de erro
class MachineConfigError extends MachineConfigState {
  final String message;

  const MachineConfigError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Estado de erro de validação
class MachineConfigValidationError extends MachineConfigState {
  final String message;
  final Map<String, String> fieldErrors;

  const MachineConfigValidationError({
    required this.message,
    this.fieldErrors = const {},
  });

  @override
  List<Object> get props => [message, fieldErrors];
}