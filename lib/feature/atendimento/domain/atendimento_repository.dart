import 'atendimento.dart';

abstract class AtendimentoRepository {
  Future<List<Atendimento>> listar({
    String? filtroNome,
    AtendimentoStatus? filtroStatus,
  });

  Future<void> salvar(Atendimento atendimento);

  Future<void> excluirLogico(int id);

  Future<void> alterarAtivo(int id, bool ativo);
}
