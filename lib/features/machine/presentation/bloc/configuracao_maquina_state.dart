import 'package:equatable/equatable.dart';
import '../../domain/entities/configuracao_maquina.dart';

/// Estados do BLoC de configuração de máquina
abstract class ConfiguracaoMaquinaState extends Equatable {
  const ConfiguracaoMaquinaState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ConfiguracaoMaquinaInitial extends ConfiguracaoMaquinaState {
  const ConfiguracaoMaquinaInitial();
}

/// Estado de carregamento
class ConfiguracaoMaquinaLoading extends ConfiguracaoMaquinaState {
  const ConfiguracaoMaquinaLoading();
}

/// Estado de sucesso ao carregar lista de configurações
class ConfiguracoesMaquinaLoaded extends ConfiguracaoMaquinaState {
  final List<ConfiguracaoMaquina> configuracoes;
  final int totalElements;
  final int currentPage;
  final int totalPages;

  const ConfiguracoesMaquinaLoaded({
    required this.configuracoes,
    required this.totalElements,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object> get props => [
    configuracoes,
    totalElements,
    currentPage,
    totalPages,
  ];
}

/// Estado de sucesso ao carregar configuração específica
class ConfiguracaoMaquinaLoaded extends ConfiguracaoMaquinaState {
  final ConfiguracaoMaquina configuracao;

  const ConfiguracaoMaquinaLoaded({required this.configuracao});

  @override
  List<Object> get props => [configuracao];
}

/// Estado de sucesso ao criar configuração
class ConfiguracaoMaquinaCreated extends ConfiguracaoMaquinaState {
  final ConfiguracaoMaquina configuracao;
  final String message;

  const ConfiguracaoMaquinaCreated({
    required this.configuracao,
    this.message = 'Configuração criada com sucesso',
  });

  @override
  List<Object> get props => [configuracao, message];
}

/// Estado de sucesso ao atualizar configuração
class ConfiguracaoMaquinaUpdated extends ConfiguracaoMaquinaState {
  final ConfiguracaoMaquina configuracao;
  final String message;

  const ConfiguracaoMaquinaUpdated({
    required this.configuracao,
    this.message = 'Configuração atualizada com sucesso',
  });

  @override
  List<Object> get props => [configuracao, message];
}

/// Estado de sucesso ao deletar configuração
class ConfiguracaoMaquinaDeleted extends ConfiguracaoMaquinaState {
  final String message;

  const ConfiguracaoMaquinaDeleted({
    this.message = 'Configuração deletada com sucesso',
  });

  @override
  List<Object> get props => [message];
}

/// Estado de erro
class ConfiguracaoMaquinaError extends ConfiguracaoMaquinaState {
  final String message;
  final String? errorCode;

  const ConfiguracaoMaquinaError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

/// Estado de validação com erros específicos
class ConfiguracaoMaquinaValidationError extends ConfiguracaoMaquinaState {
  final Map<String, String> errors;

  const ConfiguracaoMaquinaValidationError({required this.errors});

  @override
  List<Object> get props => [errors];
}