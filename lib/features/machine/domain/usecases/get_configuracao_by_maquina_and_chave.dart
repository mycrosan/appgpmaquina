import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/configuracao_maquina.dart';
import '../repositories/configuracao_maquina_repository.dart';

/// Use case para buscar configuração por máquina e chave
///
/// Este use case é responsável por recuperar uma configuração
/// específica através do ID da máquina e da chave de configuração.
class GetConfiguracaoByMaquinaAndChave
    implements
        UseCase<ConfiguracaoMaquina, GetConfiguracaoByMaquinaAndChaveParams> {
  final ConfiguracaoMaquinaRepository repository;

  GetConfiguracaoByMaquinaAndChave(this.repository);

  @override
  Future<Either<Failure, ConfiguracaoMaquina>> call(
    GetConfiguracaoByMaquinaAndChaveParams params,
  ) async {
    // Valida o ID da máquina
    if (params.registroMaquinaId <= 0) {
      return Left(
        ValidationFailure(message: 'ID da máquina deve ser maior que 0.'),
      );
    }

    // Valida a chave de configuração
    if (params.chaveConfiguracao.trim().isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Chave de configuração não pode estar vazia.',
        ),
      );
    }

    return await repository.getConfiguracaoByMaquinaAndChave(
      params.registroMaquinaId,
      params.chaveConfiguracao.trim(),
    );
  }
}

/// Parâmetros para buscar configuração por máquina e chave
class GetConfiguracaoByMaquinaAndChaveParams extends Equatable {
  final int registroMaquinaId;
  final String chaveConfiguracao;

  const GetConfiguracaoByMaquinaAndChaveParams({
    required this.registroMaquinaId,
    required this.chaveConfiguracao,
  });

  @override
  List<Object> get props => [registroMaquinaId, chaveConfiguracao];

  @override
  String toString() {
    return 'GetConfiguracaoByMaquinaAndChaveParams(registroMaquinaId: $registroMaquinaId, chaveConfiguracao: $chaveConfiguracao)';
  }
}