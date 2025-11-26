import 'package:injectable/injectable.dart';

import '../../feature/atendimento/data/atendimento_dao.dart';

@module
abstract class AppModule {
  @lazySingleton
  AtendimentoDao get atendimentoDao => AtendimentoDao();
}
