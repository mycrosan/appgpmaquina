import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/configuracao_maquina_repository.dart';

/// Use case para deletar uma configuração de máquina
///
/// Este use case é responsável por realizar a exclusão lógica
/// de uma configuração de máquina do sistema.
class DeleteConfiguracaoMaquina
    implements UseCase<void, DeleteConfiguracaoMaquinaParams> {
  final ConfiguracaoMaquinaRepository repository;

  DeleteConfiguracaoMaquina(this.repository);

  @override
  Future<Either<Failure, void>> call(
    DeleteConfiguracaoMaquinaParams params,
  ) async {
    // Valida o ID
    if (params.id <= 0) {
      return Left(
        ValidationFailure(message: 'ID da configuração deve ser maior que 0.'),
      );
    }

    // Realiza a exclusão lógica diretamente
    // O backend irá lidar com verificações de existência e múltiplas configurações
    return await repository.deleteConfiguracaoMaquina(params.id);
  }
}

/// Parâmetros para deletar configuração de máquina
class DeleteConfiguracaoMaquinaParams extends Equatable {
  final int id;

  const DeleteConfiguracaoMaquinaParams({required this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() {
    return 'DeleteConfiguracaoMaquinaParams(id: $id)';
  }
}