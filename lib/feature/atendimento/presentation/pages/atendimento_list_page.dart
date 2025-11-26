import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:atendimentos_android/injection.dart';
import '../../domain/atendimento.dart';
import '../../domain/atendimento_repository.dart';
import '../form/atendimento_form_cubit.dart';
import '../list/atendimento_list_cubit.dart';
import '../list/atendimento_list_state.dart';
import 'atendimento_execucao_page.dart';
import 'atendimento_form_page.dart';

class AtendimentoListPage extends StatelessWidget {
  const AtendimentoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimentos'),
      ),
      body: Column(
        children: <Widget>[
          const _Filtros(),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<AtendimentoListCubit, AtendimentoListState>(
              builder: (BuildContext context, AtendimentoListState state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.itens.isEmpty) {
                  return const Center(
                    child: Text('Nenhum atendimento cadastrado.'),
                  );
                }

                return ListView.builder(
                  itemCount: state.itens.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Atendimento at = state.itens[index];
                    return _ItemAtendimento(at: at);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final AtendimentoRepository repo = getIt<AtendimentoRepository>();
          final bool? created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => AtendimentoFormCubit(repo),
                child: const AtendimentoFormPage(),
              ),
            ),
          );
          if (created == true && context.mounted) {
            context.read<AtendimentoListCubit>().carregar();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AtendimentoListCubit, AtendimentoListState>(
      builder: (BuildContext context, AtendimentoListState state) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nome',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (String value) => context
                      .read<AtendimentoListCubit>()
                      .alterarFiltroNome(value),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<AtendimentoStatus?>(
                value: state.filtroStatus,
                hint: const Text('Status'),
                items: const <DropdownMenuItem<AtendimentoStatus?>>[
                  DropdownMenuItem<AtendimentoStatus?>(
                    value: null,
                    child: Text('Todos'),
                  ),
                  DropdownMenuItem<AtendimentoStatus?>(
                    value: AtendimentoStatus.ativo,
                    child: Text('Ativos'),
                  ),
                  DropdownMenuItem<AtendimentoStatus?>(
                    value: AtendimentoStatus.emAndamento,
                    child: Text('Em andamento'),
                  ),
                  DropdownMenuItem<AtendimentoStatus?>(
                    value: AtendimentoStatus.finalizado,
                    child: Text('Finalizados'),
                  ),
                ],
                onChanged: (AtendimentoStatus? value) => context
                    .read<AtendimentoListCubit>()
                    .alterarFiltroStatus(value),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ItemAtendimento extends StatelessWidget {
  const _ItemAtendimento({required this.at});

  final Atendimento at;

  Color _statusColor(AtendimentoStatus status, BuildContext context) {
    switch (status) {
      case AtendimentoStatus.ativo:
        return Colors.green;
      case AtendimentoStatus.emAndamento:
        return Colors.orange;
      case AtendimentoStatus.finalizado:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AtendimentoRepository repo = getIt<AtendimentoRepository>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: at.imagemPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(at.imagemPath!),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.image_not_supported),
        title: Text(
          at.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              at.descricao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Chip(
                  backgroundColor:
                      _statusColor(at.status, context).withOpacity(0.1),
                  label: Text(
                    at.status.label,
                    style: TextStyle(
                      color: _statusColor(at.status, context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${at.dataCriacao.day.toString().padLeft(2, '0')}/'
                  '${at.dataCriacao.month.toString().padLeft(2, '0')}/'
                  '${at.dataCriacao.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) async {
            final AtendimentoListCubit cubit =
                context.read<AtendimentoListCubit>();
            if (value == 'editar') {
              final bool? updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => AtendimentoFormCubit(repo, inicial: at),
                    child: const AtendimentoFormPage(),
                  ),
                ),
              );
              if (updated == true) {
                await cubit.carregar();
              }
            } else if (value == 'excluir') {
              if (at.id != null) {
                await cubit.excluirLogico(at.id!);
              }
            } else if (value == 'ativar') {
              if (at.id != null) {
                await cubit.alterarAtivo(at.id!, at.ativo);
              }
            } else if (value == 'execucao') {
              final bool? changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AtendimentoExecucaoPage(
                    atendimento: at,
                    repo: repo,
                  ),
                ),
              );
              if (changed == true) {
                await cubit.carregar();
              } else {
                await cubit.carregar();
              }
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'editar',
              child: Text('Editar'),
            ),
            const PopupMenuItem<String>(
              value: 'execucao',
              child: Text('Realizar atendimento'),
            ),
            PopupMenuItem<String>(
              value: 'ativar',
              child: Text(at.ativo ? 'Desativar' : 'Ativar'),
            ),
            const PopupMenuItem<String>(
              value: 'excluir',
              child: Text('Excluir'),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
