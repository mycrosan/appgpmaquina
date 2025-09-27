import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Classe abstrata base para todos os use cases da aplicação
/// Implementa o padrão Command com Either para tratamento de erros
abstract class UseCase<Type, Params> {
  /// Executa o use case e retorna Either<Failure, Type>
  /// - Left: Falha na execução
  /// - Right: Sucesso com o resultado
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case sem parâmetros
abstract class UseCaseNoParams<Type> {
  /// Executa o use case sem parâmetros
  Future<Either<Failure, Type>> call();
}

/// Classe para representar ausência de parâmetros
class NoParams {
  const NoParams();
}

/// Use case síncrono com parâmetros
abstract class SyncUseCase<Type, Params> {
  /// Executa o use case de forma síncrona
  Either<Failure, Type> call(Params params);
}

/// Use case síncrono sem parâmetros
abstract class SyncUseCaseNoParams<Type> {
  /// Executa o use case de forma síncrona sem parâmetros
  Either<Failure, Type> call();
}