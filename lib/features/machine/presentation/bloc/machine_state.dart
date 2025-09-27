part of 'machine_bloc.dart';

/// Estados do BLoC de máquinas
abstract class MachineState extends Equatable {
  const MachineState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MachineInitial extends MachineState {}

/// Estado de carregamento
class MachineLoading extends MachineState {}

/// Estado de erro
class MachineError extends MachineState {
  final String message;

  const MachineError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado com lista de carcaças carregadas
class MachineCarcacasLoaded extends MachineState {
  final List<Carcaca> carcacas;

  const MachineCarcacasLoaded({required this.carcacas});

  @override
  List<Object?> get props => [carcacas];
}

/// Estado com lista de matrizes carregadas
class MachineMatrizesLoaded extends MachineState {
  final List<Matriz> matrizes;

  const MachineMatrizesLoaded({required this.matrizes});

  @override
  List<Object?> get props => [matrizes];
}

/// Estado com uma carcaça específica carregada
class MachineCarcacaLoaded extends MachineState {
  final Carcaca carcaca;

  const MachineCarcacaLoaded({required this.carcaca});

  @override
  List<Object?> get props => [carcaca];
}

/// Estado com uma matriz específica carregada
class MachineMatrizLoaded extends MachineState {
  final Matriz matriz;

  const MachineMatrizLoaded({required this.matriz});

  @override
  List<Object?> get props => [matriz];
}

/// Estado com resultado da verificação se carcaça pode ser processada
class MachineCarcacaProcessableChecked extends MachineState {
  final int carcacaId;
  final bool canProcess;

  const MachineCarcacaProcessableChecked({
    required this.carcacaId,
    required this.canProcess,
  });

  @override
  List<Object?> get props => [carcacaId, canProcess];
}