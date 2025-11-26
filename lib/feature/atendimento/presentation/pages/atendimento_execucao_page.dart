import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/atendimento.dart';
import '../../domain/atendimento_repository.dart';

class AtendimentoExecucaoPage extends StatefulWidget {
  const AtendimentoExecucaoPage({
    super.key,
    required this.atendimento,
    required this.repo,
  });

  final Atendimento atendimento;
  final AtendimentoRepository repo;

  @override
  State<AtendimentoExecucaoPage> createState() =>
      _AtendimentoExecucaoPageState();
}

class _AtendimentoExecucaoPageState extends State<AtendimentoExecucaoPage> {
  late Atendimento _atual;
  final TextEditingController _obsCtrl = TextEditingController();
  String? _imagemPath;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _atual = widget.atendimento;
    _obsCtrl.text = _atual.observacoes ?? '';
    _imagemPath = _atual.imagemPath;
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

  Future<void> _atualizarStatus(AtendimentoStatus novoStatus) async {
    setState(() => _salvando = true);
    try {
      final Atendimento atualizado = _atual.copyWith(
        status: novoStatus,
        observacoes: _obsCtrl.text,
        imagemPath: _imagemPath,
      );
      await widget.repo.salvar(atualizado);
      if (!mounted) return;
      setState(() {
        _atual = atualizado;
        _salvando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Atendimento marcado como ${novoStatus.label}.'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool podeFinalizar =
        _atual.status != AtendimentoStatus.finalizado && !_salvando;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Execução do atendimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            Text(
              _atual.nome,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              _atual.descricao,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Criado em: '
              '${_atual.dataCriacao.day.toString().padLeft(2, '0')}/'
              '${_atual.dataCriacao.month.toString().padLeft(2, '0')}/'
              '${_atual.dataCriacao.year}',
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Text('Status atual: '),
                Chip(
                  label: Text(_atual.status.label),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Imagem do atendimento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _imagemPath != null
                ? Image.file(
                    File(_imagemPath!),
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    alignment: Alignment.center,
                    color: Colors.grey.shade200,
                    child: const Text('Nenhuma imagem'),
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
            const SizedBox(height: 16),
            TextField(
              controller: _obsCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observações / relatório',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            if (_salvando)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (_atual.status == AtendimentoStatus.ativo)
                    ElevatedButton(
                      onPressed: () =>
                          _atualizarStatus(AtendimentoStatus.emAndamento),
                      child: const Text('Marcar como EM ANDAMENTO'),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        podeFinalizar ? () => _atualizarStatus(AtendimentoStatus.finalizado) : null,
                    child: const Text('Finalizar atendimento'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
