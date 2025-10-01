part of 'injection_bloc.dart';

/// Estados do BLoC de injeções
abstract class InjectionState extends Equatable {
  const InjectionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class InjectionInitial extends InjectionState {}

/// Estado de carregamento
class InjectionLoading extends InjectionState {}

/// Estado de erro
class InjectionError extends InjectionState {
  final String message;

  const InjectionError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Estados para Regras
/// Estado com lista de regras carregadas
class InjectionRegrasLoaded extends InjectionState {
  final List<Regra> regras;

  const InjectionRegrasLoaded({required this.regras});

  @override
  List<Object?> get props => [regras];
}

/// Estado com uma regra específica carregada
class InjectionRegraLoaded extends InjectionState {
  final Regra regra;

  const InjectionRegraLoaded({required this.regra});

  @override
  List<Object?> get props => [regra];
}

/// Estado de regra criada com sucesso
class InjectionRegraCreated extends InjectionState {
  final Regra regra;

  const InjectionRegraCreated({required this.regra});

  @override
  List<Object?> get props => [regra];
}

/// Estado de regra atualizada com sucesso
class InjectionRegraUpdated extends InjectionState {
  final Regra regra;

  const InjectionRegraUpdated({required this.regra});

  @override
  List<Object?> get props => [regra];
}

/// Estado de regra deletada com sucesso
class InjectionRegraDeleted extends InjectionState {
  final int id;

  const InjectionRegraDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}

// Estados para Processos de Injeção
/// Estado de processo iniciado com sucesso
class InjectionProcessStarted extends InjectionState {
  final ProcessoInjecao processo;

  const InjectionProcessStarted({required this.processo});

  @override
  List<Object?> get props => [processo];
}

/// Estado de processo pausado com sucesso
class InjectionProcessPaused extends InjectionState {
  final ProcessoInjecao processo;

  const InjectionProcessPaused({required this.processo});

  @override
  List<Object?> get props => [processo];
}

/// Estado de processo retomado com sucesso
class InjectionProcessResumed extends InjectionState {
  final ProcessoInjecao processo;

  const InjectionProcessResumed({required this.processo});

  @override
  List<Object?> get props => [processo];
}

/// Estado de processo cancelado com sucesso
class InjectionProcessCanceled extends InjectionState {
  final ProcessoInjecao processo;

  const InjectionProcessCanceled({required this.processo});

  @override
  List<Object?> get props => [processo];
}

/// Estado de processo finalizado com sucesso
class InjectionProcessFinished extends InjectionState {
  final ProcessoInjecao processo;

  const InjectionProcessFinished({required this.processo});

  @override
  List<Object?> get props => [processo];
}

/// Estado com um processo específico carregado
class InjectionProcessLoaded extends InjectionState {
  final ProcessoInjecao processo;

  const InjectionProcessLoaded({required this.processo});

  @override
  List<Object?> get props => [processo];
}

/// Estado com lista de processos carregados
class InjectionProcessesLoaded extends InjectionState {
  final List<ProcessoInjecao> processos;

  const InjectionProcessesLoaded({required this.processos});

  @override
  List<Object?> get props => [processos];
}

/// Estado de processo ativo carregado
class InjectionActiveProcessLoaded extends InjectionState {
  final ProcessoInjecao? processo;

  const InjectionActiveProcessLoaded({this.processo});

  @override
  List<Object?> get props => [processo];
}

// Novos estados para o fluxo de injeção de ar
/// Estado de carcaça validada com sucesso
class InjectionCarcacaValidada extends InjectionState {
  final String numeroEtiqueta;
  final String matrizDescricao;
  final int tempoInjecao;
  final bool isMatrizCompativel;

  const InjectionCarcacaValidada({
    required this.numeroEtiqueta,
    required this.matrizDescricao,
    required this.tempoInjecao,
    required this.isMatrizCompativel,
  });

  @override
  List<Object?> get props => [numeroEtiqueta, matrizDescricao, tempoInjecao, isMatrizCompativel];
}

/// Estado de erro de validação de carcaça
class InjectionCarcacaValidationError extends InjectionState {
  final String message;

  const InjectionCarcacaValidationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de injeção de ar em andamento
class InjectionInjecaoArEmAndamento extends InjectionState {
  final String numeroEtiqueta;
  final int tempoTotal;
  final int tempoRestante;

  const InjectionInjecaoArEmAndamento({
    required this.numeroEtiqueta,
    required this.tempoTotal,
    required this.tempoRestante,
  });

  /// Calcula o progresso da injeção (0.0 a 1.0)
  double get progresso {
    if (tempoTotal <= 0) return 0.0;
    return (tempoTotal - tempoRestante) / tempoTotal;
  }

  /// Retorna true se a injeção está quase terminando (últimos 10 segundos)
  bool get isQuaseTerminando => tempoRestante <= 10;

  @override
  List<Object?> get props => [numeroEtiqueta, tempoTotal, tempoRestante];
}

/// Estado de injeção de ar finalizada
class InjectionInjecaoArFinalizada extends InjectionState {
  final String numeroEtiqueta;
  final bool sucesso;

  const InjectionInjecaoArFinalizada({
    required this.numeroEtiqueta,
    required this.sucesso,
  });

  @override
  List<Object?> get props => [numeroEtiqueta, sucesso];
}

/// Estado de injeção de ar cancelada
class InjectionInjecaoArCancelada extends InjectionState {
  final String numeroEtiqueta;

  const InjectionInjecaoArCancelada({required this.numeroEtiqueta});

  @override
  List<Object?> get props => [numeroEtiqueta];
}

/// Estado indicando que não há processo ativo
class InjectionNoActiveProcess extends InjectionState {}