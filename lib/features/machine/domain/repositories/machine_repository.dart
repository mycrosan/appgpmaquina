import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/carcaca.dart';
import '../entities/matriz.dart';
import '../entities/machine_config.dart';

/// Repositório abstrato para operações com máquinas, carcaças e matrizes
/// Define os contratos para gerenciamento de dados relacionados às máquinas
abstract class MachineRepository {
  /// Busca uma carcaça pelo seu código
  /// 
  /// [codigo] - código de 6 dígitos da carcaça
  /// Retorna [Carcaca] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Carcaca>> getCarcacaByCodigo(String codigo);

  /// Busca uma carcaça pelo seu ID
  /// 
  /// [id] - ID único da carcaça
  /// Retorna [Carcaca] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Carcaca>> getCarcacaById(int id);

  /// Lista todas as carcaças ativas
  /// 
  /// Retorna [List<Carcaca>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<Carcaca>>> getAllCarcacas();

  /// Lista carcaças filtradas por matriz
  /// 
  /// [matrizId] - ID da matriz para filtrar
  /// Retorna [List<Carcaca>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<Carcaca>>> getCarcacasByMatriz(int matrizId);

  /// Cria uma nova carcaça
  /// 
  /// [carcaca] - dados da carcaça a ser criada
  /// Retorna [Carcaca] criada em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Carcaca>> createCarcaca(Carcaca carcaca);

  /// Atualiza uma carcaça existente
  /// 
  /// [carcaca] - dados atualizados da carcaça
  /// Retorna [Carcaca] atualizada em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Carcaca>> updateCarcaca(Carcaca carcaca);

  /// Remove uma carcaça (soft delete)
  /// 
  /// [id] - ID da carcaça a ser removida
  /// Retorna [void] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, void>> deleteCarcaca(int id);

  /// Busca uma matriz pelo seu ID
  /// 
  /// [id] - ID único da matriz
  /// Retorna [Matriz] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Matriz>> getMatrizById(int id);

  /// Busca uma matriz pelo seu código
  /// 
  /// [codigo] - código único da matriz
  /// Retorna [Matriz] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Matriz>> getMatrizByCodigo(String codigo);

  /// Lista todas as matrizes ativas
  /// 
  /// Retorna [List<Matriz>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<Matriz>>> getAllMatrizes();

  /// Lista matrizes filtradas por marca
  /// 
  /// [marca] - marca para filtrar
  /// Retorna [List<Matriz>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<Matriz>>> getMatrizesByMarca(String marca);

  /// Lista matrizes filtradas por tamanho
  /// 
  /// [tamanho] - tamanho para filtrar (ex: 205/55R16)
  /// Retorna [List<Matriz>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<Matriz>>> getMatrizesByTamanho(String tamanho);

  /// Cria uma nova matriz
  /// 
  /// [matriz] - dados da matriz a ser criada
  /// Retorna [Matriz] criada em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Matriz>> createMatriz(Matriz matriz);

  /// Atualiza uma matriz existente
  /// 
  /// [matriz] - dados atualizados da matriz
  /// Retorna [Matriz] atualizada em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Matriz>> updateMatriz(Matriz matriz);

  /// Remove uma matriz (soft delete)
  /// 
  /// [id] - ID da matriz a ser removida
  /// Retorna [void] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, void>> deleteMatriz(int id);

  /// Verifica se uma carcaça pode ser processada
  /// 
  /// [carcacaId] - ID da carcaça
  /// Retorna [bool] indicando se pode ser processada ou [Failure] em caso de erro
  Future<Either<Failure, bool>> canProcessCarcaca(int carcacaId);

  /// Busca carcaças por critérios de pesquisa
  /// 
  /// [searchTerm] - termo de busca (código, matriz, etc.)
  /// Retorna [List<Carcaca>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<Carcaca>>> searchCarcacas(String searchTerm);

  /// Busca matrizes por critérios de pesquisa
  /// 
  /// [searchTerm] - termo de busca (nome, código, marca, etc.)
  /// Retorna [List<Matriz>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<Matriz>>> searchMatrizes(String searchTerm);

  /// Sincroniza dados locais com o servidor
  /// 
  /// Retorna [void] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, void>> syncData();

  /// Verifica se há dados locais não sincronizados
  /// 
  /// Retorna [bool] indicando se há dados pendentes de sincronização
  Future<Either<Failure, bool>> hasPendingSync();

  /// Salva a configuração da máquina
  /// 
  /// [config] - configuração da máquina a ser salva
  /// Retorna [MachineConfig] salva em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, MachineConfig>> saveMachineConfig(MachineConfig config);

  /// Busca a configuração atual da máquina
  /// 
  /// [deviceId] - ID do dispositivo
  /// [userId] - ID do usuário
  /// Retorna [MachineConfig] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, MachineConfig?>> getCurrentMachineConfig(String deviceId, String userId);

  /// Remove a configuração da máquina
  /// 
  /// [deviceId] - ID do dispositivo
  /// [userId] - ID do usuário
  /// Retorna [void] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, void>> removeMachineConfig(String deviceId, String userId);
}