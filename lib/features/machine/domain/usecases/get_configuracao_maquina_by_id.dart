import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/configuracao_maquina.dart';
import '../repositories/configuracao_maquina_repository.dart';

/// Use case para buscar uma configuração de máquina por ID
///
/// Este use case é responsável por recuperar uma configuração
/// específica através do seu identificador único.
class GetConfiguracaoMaquinaById
    implements UseCase<ConfiguracaoMaquina, GetConfiguracaoMaquinaByIdParams> {
  final ConfiguracaoMaquinaRepository repository;

  GetConfiguracaoMaquinaById(this.repository);

  @override
  Future<Either<Failure, ConfiguracaoMaquina>> call(
    GetConfiguracaoMaquinaByIdParams params,
  ) async {
    // Valida o ID
    if (params.id <= 0) {
      return Left(
        ValidationFailure(message: 'ID da configuração deve ser maior que 0.'),
      );
    }

    return await repository.getConfiguracaoMaquinaById(params.id);
  }
}

/// Parâmetros para buscar configuração por ID
class GetConfiguracaoMaquinaByIdParams extends Equatable {
  final int id;

  const GetConfiguracaoMaquinaByIdParams({required this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() {
    return 'GetConfiguracaoMaquinaByIdParams(id: $id)';
  }
}