import 'package:equatable/equatable.dart';
import '../../domain/entities/configuracao_maquina.dart';

/// Eventos do BLoC de configuração de máquina
abstract class ConfiguracaoMaquinaEvent extends Equatable {
  const ConfiguracaoMaquinaEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar configurações com filtros
class LoadConfiguracoesMaquina extends ConfiguracaoMaquinaEvent {
  final int? registroMaquinaId;
  final String? chaveConfiguracao;
  final bool? ativo;
  final int page;
  final int size;

  const LoadConfiguracoesMaquina({
    this.registroMaquinaId,
    this.chaveConfiguracao,
    this.ativo,
    this.page = 0,
    this.size = 20,
  });

  @override
  List<Object?> get props => [
    registroMaquinaId,
    chaveConfiguracao,
    ativo,
    page,
    size,
  ];
}

/// Evento para carregar configuração por ID
class LoadConfiguracaoMaquinaById extends ConfiguracaoMaquinaEvent {
  final int id;

  const LoadConfiguracaoMaquinaById({required this.id});

  @override
  List<Object> get props => [id];
}

/// Evento para criar nova configuração
class CreateConfiguracaoMaquina extends ConfiguracaoMaquinaEvent {
  final ConfiguracaoMaquina configuracao;

  const CreateConfiguracaoMaquina({required this.configuracao});

  @override
  List<Object> get props => [configuracao];
}

/// Evento para atualizar configuração existente
class UpdateConfiguracaoMaquina extends ConfiguracaoMaquinaEvent {
  final int id;
  final ConfiguracaoMaquina configuracao;

  const UpdateConfiguracaoMaquina({
    required this.id,
    required this.configuracao,
  });

  @override
  List<Object> get props => [id, configuracao];
}

/// Evento para deletar configuração
class DeleteConfiguracaoMaquina extends ConfiguracaoMaquinaEvent {
  final int id;

  const DeleteConfiguracaoMaquina({required this.id});

  @override
  List<Object> get props => [id];
}

/// Evento para buscar configuração por máquina e chave
class LoadConfiguracaoByMaquinaAndChave extends ConfiguracaoMaquinaEvent {
  final int registroMaquinaId;
  final String chaveConfiguracao;

  const LoadConfiguracaoByMaquinaAndChave({
    required this.registroMaquinaId,
    required this.chaveConfiguracao,
  });

  @override
  List<Object> get props => [registroMaquinaId, chaveConfiguracao];
}

/// Evento para resetar o estado
class ResetConfiguracaoMaquinaState extends ConfiguracaoMaquinaEvent {
  const ResetConfiguracaoMaquinaState();
}

/// Evento para limpar mensagens de erro/sucesso
class ClearConfiguracaoMaquinaMessages extends ConfiguracaoMaquinaEvent {
  const ClearConfiguracaoMaquinaMessages();
}