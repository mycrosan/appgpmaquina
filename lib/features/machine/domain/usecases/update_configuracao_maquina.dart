import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/configuracao_maquina.dart';
import '../repositories/configuracao_maquina_repository.dart';

/// Use case para atualizar uma configuração de máquina
///
/// Este use case é responsável por validar e atualizar uma
/// configuração existente no sistema.
class UpdateConfiguracaoMaquina
    implements UseCase<ConfiguracaoMaquina, UpdateConfiguracaoMaquinaParams> {
  final ConfiguracaoMaquinaRepository repository;

  UpdateConfiguracaoMaquina(this.repository);

  @override
  Future<Either<Failure, ConfiguracaoMaquina>> call(
    UpdateConfiguracaoMaquinaParams params,
  ) async {
    // Valida o ID
    if (params.id <= 0) {
      return Left(
        ValidationFailure(message: 'ID da configuração deve ser maior que 0.'),
      );
    }

    // Valida a configuração
    if (!params.configuracao.isValid) {
      return Left(
        ValidationFailure(
          message:
              'Dados da configuração são inválidos. Verifique os campos obrigatórios.',
        ),
      );
    }

    // Verifica se a configuração existe
    final existingConfigResult = await repository.getConfiguracaoMaquinaById(
      params.id,
    );

    return existingConfigResult.fold((failure) => Left(failure), (
      existingConfig,
    ) async {
      // Se a chave de configuração foi alterada, verifica se não há conflito
      if (existingConfig.chaveConfiguracao !=
          params.configuracao.chaveConfiguracao) {
        final conflictResult = await repository
            .getConfiguracaoByMaquinaAndChave(
              params.configuracao.registroMaquinaId,
              params.configuracao.chaveConfiguracao,
            );

        return conflictResult.fold(
          (failure) async {
            // Se não encontrou (esperado), prossegue com a atualização
            if (failure is ServerFailure &&
                failure.message.contains('não encontrada')) {
              return await repository.updateConfiguracaoMaquina(
                params.id,
                params.configuracao,
              );
            }
            // Outros erros são propagados
            return Left(failure);
          },
          (conflictConfig) {
            // Se encontrou uma configuração com a mesma chave, retorna erro
            return Left(
              ValidationFailure(
                message:
                    'Já existe uma configuração com a chave "${params.configuracao.chaveConfiguracao}" para esta máquina.',
              ),
            );
          },
        );
      }

      // Se a chave não foi alterada, atualiza diretamente
      return await repository.updateConfiguracaoMaquina(
        params.id,
        params.configuracao,
      );
    });
  }
}

/// Parâmetros para atualizar configuração de máquina
class UpdateConfiguracaoMaquinaParams extends Equatable {
  final int id;
  final ConfiguracaoMaquina configuracao;

  const UpdateConfiguracaoMaquinaParams({
    required this.id,
    required this.configuracao,
  });

  @override
  List<Object> get props => [id, configuracao];

  @override
  String toString() {
    return 'UpdateConfiguracaoMaquinaParams(id: $id, configuracao: $configuracao)';
  }
}