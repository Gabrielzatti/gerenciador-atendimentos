import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'core/di/app_module.dart';
import 'feature/atendimento/data/atendimento_dao.dart';
import 'feature/atendimento/data/atendimento_repository_impl.dart';
import 'feature/atendimento/domain/atendimento_repository.dart';

extension GetItInjectableX on GetIt {
  GetIt init({
    String? environment,
    EnvironmentFilter? environmentFilter,
  }) {
    final GetItHelper gh = GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final AppModule appModule = _$AppModule();

    gh.lazySingleton<AtendimentoDao>(() => appModule.atendimentoDao);
    gh.lazySingleton<AtendimentoRepository>(
      () => AtendimentoRepositoryImpl(
        gh<AtendimentoDao>(),
      ),
    );

    return this;
  }
}

class _$AppModule extends AppModule {}

class GetItHelper {
  GetItHelper(this.getIt, this.environment, this.environmentFilter);

  final GetIt getIt;
  final String? environment;
  final EnvironmentFilter? environmentFilter;

  void lazySingleton<T extends Object>(T Function() factoryFunc) {
    getIt.registerLazySingleton<T>(factoryFunc);
  }

  T call<T extends Object>() => getIt<T>();
}
