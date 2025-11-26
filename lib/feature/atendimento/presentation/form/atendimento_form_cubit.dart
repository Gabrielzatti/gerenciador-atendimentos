import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/atendimento.dart';
import '../../domain/atendimento_repository.dart';
import 'atendimento_form_state.dart';

class AtendimentoFormCubit extends Cubit<AtendimentoFormState> {
  AtendimentoFormCubit(
    this._repo, {
    Atendimento? inicial,
  }) : super(AtendimentoFormState(atual: inicial));

  final AtendimentoRepository _repo;

  void atualizarCampos({
    String? nome,
    String? descricao,
    String? imagemPath,
    DateTime? dataCriacao,
    AtendimentoStatus? status,
    String? observacoes,
    bool? ativo,
  }) {
    final Atendimento atual = state.atual ??
        Atendimento(
          nome: '',
          descricao: '',
          dataCriacao: DateTime.now(),
        );

    emit(
      state.copyWith(
        atual: atual.copyWith(
          nome: nome,
          descricao: descricao,
          imagemPath: imagemPath,
          dataCriacao: dataCriacao,
          status: status,
          observacoes: observacoes,
          ativo: ativo,
        ),
      ),
    );
  }

  Future<void> salvar() async {
    final Atendimento? atual = state.atual;
    if (atual == null || atual.nome.trim().isEmpty) {
      emit(state.copyWith(error: 'Nome é obrigatório'));
      return;
    }

    emit(state.copyWith(salvando: true, error: null));
    try {
      await _repo.salvar(atual);
      emit(state.copyWith(salvando: false));
    } catch (e) {
      emit(
        state.copyWith(
          salvando: false,
          error: e.toString(),
        ),
      );
    }
  }
}
