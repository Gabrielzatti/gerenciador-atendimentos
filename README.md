Gestão de Atendimentos (Flutter + SQLite)

Este projeto é um aplicativo Flutter para gestão de atendimentos, permitindo abrir, editar, acompanhar e finalizar atendimentos. Ele usa SQLite (sqflite) para persistência de dados, BLoC (Cubit) para gerenciamento de estado, e injeção de dependência com GetIt e Injectable.

Tecnologias Utilizadas

Flutter (SDK 3.x)

Dart

Gerenciamento de Estado

flutter_bloc (usando Cubit)

equatable (para comparação de estados)

Injeção de Dependência

get_it, injectable e build_runner

injectable_generator

Banco de Dados Local

sqflite

path

Imagens e Câmera

image_picker

Banco de Dados

O banco de dados utiliza SQLite, e a tabela atendimentos possui os campos principais:

CREATE TABLE atendimentos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  descricao TEXT NOT NULL,
  imagem_path TEXT,
  data_criacao TEXT NOT NULL,
  status TEXT NOT NULL,
  observacoes TEXT,
  ativo INTEGER NOT NULL DEFAULT 1,
  excluido INTEGER NOT NULL DEFAULT 0
);

Fluxo da Aplicação
1. Lista de Atendimentos

Tela inicial com filtros (nome e status) e lista de atendimentos. Cada item da lista tem opções de editar, ir para execução, excluir ou ativar/desativar.

2. Cadastro/Edição de Atendimento

Permite criar ou editar um atendimento. Inclui campos como nome, descrição, data, status e imagem (opcional).

3. Execução do Atendimento

Tela focada no acompanhamento do atendimento, permitindo tirar fotos ou anexar imagens. Ao finalizar, o status é alterado para "Finalizado".

Configuração

Criar um projeto Flutter vazio (se necessário):

flutter create atendimentos_android


Substituir a pasta lib/ pelo conteúdo deste repositório.

Ajustar o pubspec.yaml:
Inclua as dependências necessárias, como flutter_bloc, sqflite, get_it, injectable, e outras.

Rodar o comando para baixar dependências:

flutter pub get


Gerar o arquivo de injeção (se necessário):

flutter pub run build_runner build --delete-conflicting-outputs


Configurar permissões:

Android: No AndroidManifest.xml, adicione permissões para câmera.

iOS: No Info.plist, adicione permissões para acessar a câmera e a galeria.

Rodar o aplicativo:
Conecte um dispositivo ou use um emulador e execute:

flutter run
