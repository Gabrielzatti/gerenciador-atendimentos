import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature/atendimento/domain/atendimento_repository.dart';
import 'feature/atendimento/presentation/list/atendimento_list_cubit.dart';
import 'feature/atendimento/presentation/pages/atendimento_list_page.dart';
import 'injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const AtendimentosApp());
}

class AtendimentosApp extends StatelessWidget {
  const AtendimentosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AtendimentoRepository repo = getIt<AtendimentoRepository>();

    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<AtendimentoListCubit>(
          create: (_) => AtendimentoListCubit(repo)..carregar(),
        ),
      ],
      child: MaterialApp(
        title: 'Atendimentos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.light,
        ),
        home: const AtendimentoListPage(),
      ),
    );
  }
}
