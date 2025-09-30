import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/configuracao_maquina.dart';
import '../repositories/configuracao_maquina_repository.dart';

/// Use case para criar uma nova configuração de máquina
///
/// Este use case é responsável por validar e criar uma nova
/// configuração de máquina no sistema.
class CreateConfiguracaoMaquina
    implements UseCase<ConfiguracaoMaquina, ConfiguracaoMaquina> {
  final ConfiguracaoMaquinaRepository repository;

  CreateConfiguracaoMaquina(this.repository);

  @override
  Future<Either<Failure, ConfiguracaoMaquina>> call(
    ConfiguracaoMaquina configuracao,
  ) async {
    // Valida a configuração antes de criar
    if (!configuracao.isValid) {
      return Left(
        ValidationFailure(
          message:
              'Dados da configuração são inválidos. Verifique os campos obrigatórios.',
        ),
      );
    }

    // Verifica se a chave de configuração já existe para a máquina
    final existingConfigResult = await repository
        .getConfiguracaoByMaquinaAndChave(
          configuracao.registroMaquinaId,
          configuracao.chaveConfiguracao,
        );

    return existingConfigResult.fold(
      (failure) async {
        // Se não encontrou (esperado), prossegue com a criação
        if (failure is ServerFailure &&
            failure.message.contains('não encontrada')) {
          return await repository.createConfiguracaoMaquina(configuracao);
        }
        // Outros erros são propagados
        return Left(failure);
      },
      (existingConfig) {
        // Se encontrou uma configuração existente, retorna erro
        return Left(
          ValidationFailure(
            message:
                'Já existe uma configuração com a chave "${configuracao.chaveConfiguracao}" para esta máquina.',
          ),
        );
      },
    );
  }
}