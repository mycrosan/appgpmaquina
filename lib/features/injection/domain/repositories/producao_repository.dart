import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/producao_response.dart';

/// Repository para operações relacionadas à produção
abstract class ProducaoRepository {
  /// Busca dados da carcaça pelo número da etiqueta
  /// 
  /// Retorna [Right] com lista de [ProducaoResponse] se bem-sucedido
  /// Retorna [Left] com [Failure] se houver erro
  Future<Either<Failure, List<ProducaoResponse>>> pesquisarCarcaca(String numeroEtiqueta);
}