abstract class SonoffRepository {
  Future<bool> ligarRele();
  Future<bool> desligarRele();
  Future<bool> verificarStatusRele();
}