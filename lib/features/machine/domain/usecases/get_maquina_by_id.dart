import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/registro_maquina.dart';
import '../repositories/registro_maquina_repository.dart';

/// Use case para buscar uma máquina por ID
/// Implementa o padrão UseCase para operações de domínio
class GetMaquinaById implements UseCase<RegistroMaquina, GetMaquinaByIdParams> {
  final RegistroMaquinaRepository repository;

  GetMaquinaById(this.repository);

  @override
  Future<Either<Failure, RegistroMaquina>> call(
    GetMaquinaByIdParams params,
  ) async {
    return await repository.getMaquinaById(params.id);
  }
}

/// Parâmetros para o use case GetMaquinaById
class GetMaquinaByIdParams {
  final int id;

  const GetMaquinaByIdParams({required this.id});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetMaquinaByIdParams && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}