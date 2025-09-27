import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/carcaca.dart';
import '../repositories/machine_repository.dart';

/// Caso de uso para buscar uma carcaça pelo seu código
/// 
/// Valida o código e busca a carcaça correspondente no sistema
class GetCarcacaByCodigo implements UseCase<Carcaca, GetCarcacaByCodigoParams> {
  final MachineRepository repository;

  GetCarcacaByCodigo(this.repository);

  @override
  Future<Either<Failure, Carcaca>> call(GetCarcacaByCodigoParams params) async {
    // Validação do código
    if (params.codigo.isEmpty) {
      return Left(ValidationFailure(
        message: 'Código da carcaça não pode estar vazio',
      ));
    }

    // Remove espaços e converte para maiúsculo
    final codigoLimpo = params.codigo.trim().toUpperCase();

    // Verifica se o código tem 6 dígitos
    if (codigoLimpo.length != 6) {
      return Left(ValidationFailure(
        message: 'Código da carcaça deve ter exatamente 6 dígitos',
      ));
    }

    // Verifica se o código contém apenas números
    if (!RegExp(r'^\d{6}$').hasMatch(codigoLimpo)) {
      return Left(ValidationFailure(
        message: 'Código da carcaça deve conter apenas números',
      ));
    }

    // Busca a carcaça no repositório
    final result = await repository.getCarcacaByCodigo(codigoLimpo);

    return result.fold(
      (failure) => Left(failure),
      (carcaca) {
        // Verifica se a carcaça está ativa
        if (!carcaca.isActive) {
          return Left(ValidationFailure(
            message: 'Carcaça ${carcaca.codigo} está inativa',
          ));
        }

        // Verifica se a carcaça pode ser processada
        if (!carcaca.canBeProcessed) {
          return Left(ValidationFailure(
            message: 'Carcaça ${carcaca.codigo} não pode ser processada',
          ));
        }

        return Right(carcaca);
      },
    );
  }
}

/// Parâmetros para o caso de uso GetCarcacaByCodigo
class GetCarcacaByCodigoParams extends Equatable {
  final String codigo;

  const GetCarcacaByCodigoParams({
    required this.codigo,
  });

  @override
  List<Object> get props => [codigo];

  @override
  String toString() => 'GetCarcacaByCodigoParams(codigo: $codigo)';
}