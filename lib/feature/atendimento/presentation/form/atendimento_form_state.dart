import 'package:equatable/equatable.dart';

import '../../domain/atendimento.dart';

class AtendimentoFormState extends Equatable {
  const AtendimentoFormState({
    this.atual,
    this.salvando = false,
    this.error,
  });

  final Atendimento? atual;
  final bool salvando;
  final String? error;

  AtendimentoFormState copyWith({
    Atendimento? atual,
    bool? salvando,
    String? error,
  }) {
    return AtendimentoFormState(
      atual: atual ?? this.atual,
      salvando: salvando ?? this.salvando,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[atual, salvando, error];
}
