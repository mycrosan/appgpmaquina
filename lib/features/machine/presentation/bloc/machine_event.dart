part of 'machine_bloc.dart';

/// Eventos do BLoC de máquinas
abstract class MachineEvent extends Equatable {
  const MachineEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar todas as carcaças
class MachineLoadCarcacas extends MachineEvent {
  const MachineLoadCarcacas();
}

/// Evento para carregar todas as matrizes
class MachineLoadMatrizes extends MachineEvent {
  const MachineLoadMatrizes();
}

/// Evento para carregar uma carcaça por ID
class MachineLoadCarcacaById extends MachineEvent {
  final int id;

  const MachineLoadCarcacaById({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Evento para carregar uma matriz por ID
class MachineLoadMatrizById extends MachineEvent {
  final int id;

  const MachineLoadMatrizById({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Evento para buscar carcaças por termo
class MachineSearchCarcacas extends MachineEvent {
  final String searchTerm;

  const MachineSearchCarcacas({required this.searchTerm});

  @override
  List<Object?> get props => [searchTerm];
}

/// Evento para buscar matrizes por termo
class MachineSearchMatrizes extends MachineEvent {
  final String searchTerm;

  const MachineSearchMatrizes({required this.searchTerm});

  @override
  List<Object?> get props => [searchTerm];
}

/// Evento para verificar se uma carcaça pode ser processada
class MachineCheckCarcacaProcessable extends MachineEvent {
  final int carcacaId;

  const MachineCheckCarcacaProcessable({required this.carcacaId});

  @override
  List<Object?> get props => [carcacaId];
}