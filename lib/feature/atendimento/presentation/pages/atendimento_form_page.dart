import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/atendimento.dart';
import '../form/atendimento_form_cubit.dart';
import '../form/atendimento_form_state.dart';

class AtendimentoFormPage extends StatefulWidget {
  const AtendimentoFormPage({super.key});

  @override
  State<AtendimentoFormPage> createState() => _AtendimentoFormPageState();
}

class _AtendimentoFormPageState extends State<AtendimentoFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  DateTime _dataCriacao = DateTime.now();
  String? _imagemPath;
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    final AtendimentoFormState state =
        context.read<AtendimentoFormCubit>().state;
    final Atendimento? at = state.atual;
    if (at != null) {
      _nomeCtrl.text = at.nome;
      _descCtrl.text = at.descricao;
      _dataCriacao = at.dataCriacao;
      _imagemPath = at.imagemPath;
      _ativo = at.ativo;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? picked =
          await picker.pickImage(source: source, maxWidth: 1024);
      if (picked != null) {
        setState(() {
          _imagemPath = picked.path;
        });
        context
            .read<AtendimentoFormCubit>()
            .atualizarCampos(imagemPath: picked.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao acessar câmera/galeria: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AtendimentoFormCubit, AtendimentoFormState>(
      listener: (BuildContext context, AtendimentoFormState state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Atendimento'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<AtendimentoFormCubit, AtendimentoFormState>(
            builder: (BuildContext context, AtendimentoFormState state) {
              return Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                      ),
                      validator: (String? value) =>
                          value == null || value.isEmpty ? 'Obrigatório' : null,
                      onChanged: (String v) => context
                          .read<AtendimentoFormCubit>()
                          .atualizarCampos(nome: v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                      ),
                      maxLines: 3,
                      onChanged: (String v) => context
                          .read<AtendimentoFormCubit>()
                          .atualizarCampos(descricao: v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        const Text('Criado em: '),
                        Text(
                          '${_dataCriacao.day.toString().padLeft(2, '0')}/'
                          '${_dataCriacao.month.toString().padLeft(2, '0')}/'
                          '${_dataCriacao.year}',
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _dataCriacao,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _dataCriacao = picked);
                              context
                                  .read<AtendimentoFormCubit>()
                                  .atualizarCampos(dataCriacao: picked);
                            }
                          },
                          child: const Text('Alterar'),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('Ativo'),
                      value: _ativo,
                      onChanged: (bool v) {
                        setState(() => _ativo = v);
                        context
                            .read<AtendimentoFormCubit>()
                            .atualizarCampos(ativo: v);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _imagemPath != null
                              ? Image.file(
                                  File(_imagemPath!),
                                  height: 160,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 160,
                                  alignment: Alignment.center,
                                  color: Colors.grey.shade200,
                                  child: const Text('Nenhuma imagem'),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Câmera'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo),
                          label: const Text('Galeria'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.salvando
                            ? null
                            : () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  context
                                      .read<AtendimentoFormCubit>()
                                      .atualizarCampos(
                                    nome: _nomeCtrl.text,
                                    descricao: _descCtrl.text,
                                    dataCriacao: _dataCriacao,
                                    ativo: _ativo,
                                  );
                                  await context
                                      .read<AtendimentoFormCubit>()
                                      .salvar();
                                  if (mounted) Navigator.pop(context, true);
                                }
                              },
                        child: state.salvando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
