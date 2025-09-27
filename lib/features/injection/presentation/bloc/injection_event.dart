part of 'injection_bloc.dart';

/// Eventos do BLoC de injeções
abstract class InjectionEvent extends Equatable {
  const InjectionEvent();

  @override
  List<Object?> get props => [];
}

// Eventos para Regras
/// Evento para carregar todas as regras
class InjectionLoadRegras extends InjectionEvent {
  const InjectionLoadRegras();
}

/// Evento para carregar regras por matriz
class InjectionLoadRegrasByMatriz extends InjectionEvent {
  final int matrizId;

  const InjectionLoadRegrasByMatriz({required this.matrizId});

  @override
  List<Object?> get props => [matrizId];
}

/// Evento para carregar uma regra por ID
class InjectionLoadRegraById extends InjectionEvent {
  final int id;

  const InjectionLoadRegraById({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Evento para criar uma nova regra
class InjectionCreateRegra extends InjectionEvent {
  final Regra regra;

  const InjectionCreateRegra({required this.regra});

  @override
  List<Object?> get props => [regra];
}

/// Evento para atualizar uma regra
class InjectionUpdateRegra extends InjectionEvent {
  final Regra regra;

  const InjectionUpdateRegra({required this.regra});

  @override
  List<Object?> get props => [regra];
}

/// Evento para deletar uma regra
class InjectionDeleteRegra extends InjectionEvent {
  final int id;

  const InjectionDeleteRegra({required this.id});

  @override
  List<Object?> get props => [id];
}

// Eventos para Processos de Injeção
/// Evento para iniciar um processo de injeção
class InjectionStartProcess extends InjectionEvent {
  final int regraId;
  final String carcacaCodigo;
  final double pressaoInicial;

  const InjectionStartProcess({
    required this.regraId,
    required this.carcacaCodigo,
    required this.pressaoInicial,
  });

  @override
  List<Object?> get props => [regraId, carcacaCodigo, pressaoInicial];
}

/// Evento para pausar um processo de injeção
class InjectionPauseProcess extends InjectionEvent {
  final int processoId;

  const InjectionPauseProcess({required this.processoId});

  @override
  List<Object?> get props => [processoId];
}

/// Evento para retomar um processo de injeção
class InjectionResumeProcess extends InjectionEvent {
  final int processoId;

  const InjectionResumeProcess({required this.processoId});

  @override
  List<Object?> get props => [processoId];
}

/// Evento para cancelar um processo de injeção
class InjectionCancelProcess extends InjectionEvent {
  final int processoId;
  final String motivo;

  const InjectionCancelProcess({
    required this.processoId,
    required this.motivo,
  });

  @override
  List<Object?> get props => [processoId, motivo];
}

/// Evento para finalizar um processo de injeção
class InjectionFinishProcess extends InjectionEvent {
  final int processoId;
  final double pressaoFinal;

  const InjectionFinishProcess({
    required this.processoId,
    required this.pressaoFinal,
  });

  @override
  List<Object?> get props => [processoId, pressaoFinal];
}

/// Evento para carregar um processo por ID
class InjectionLoadProcessById extends InjectionEvent {
  final int id;

  const InjectionLoadProcessById({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Evento para carregar processos por status
class InjectionLoadProcessesByStatus extends InjectionEvent {
  final String status;

  const InjectionLoadProcessesByStatus({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Evento para carregar o processo ativo atual
class InjectionLoadCurrentActiveProcess extends InjectionEvent {
  const InjectionLoadCurrentActiveProcess();
}