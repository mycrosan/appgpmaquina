import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/producao_response.dart';
import '../../domain/repositories/producao_repository.dart';
import '../datasources/producao_remote_datasource.dart';

/// Implementação do repository para operações de produção
class ProducaoRepositoryImpl implements ProducaoRepository {
  final ProducaoRemoteDataSource remoteDataSource;

  ProducaoRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ProducaoResponse>>> pesquisarCarcaca(String numeroEtiqueta) async {
    try {
      final result = await remoteDataSource.pesquisarCarcaca(numeroEtiqueta);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(DeviceFailure(message: 'Erro inesperado: $e'));
    }
  }
}