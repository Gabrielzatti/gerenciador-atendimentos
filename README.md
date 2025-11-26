# Gestão de Atendimentos (Flutter + SQLite)


## 1. Tecnologias utilizadas

- **Flutter** (SDK 3.x recomendado)
- **Dart**
- **Gerenciamento de estado**
  - [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (usando `Cubit`)
  - [`equatable`](https://pub.dev/packages/equatable) para comparação de estados
- **Injeção de dependência**
  - [`get_it`](https://pub.dev/packages/get_it)
  - [`injectable`](https://pub.dev/packages/injectable)
  - `build_runner` + `injectable_generator` para gerar `injection.config.dart`
- **Banco de dados local**
  - [`sqflite`](https://pub.dev/packages/sqflite)
  - [`path`](https://pub.dev/packages/path) para montar o caminho do arquivo do banco
- **Imagens e câmera**
  - [`image_picker`](https://pub.dev/packages/image_picker)

---

## 2. Estrutura de pastas

```text
lib/
├─ core/
│  ├─ database/
│  │  └─ app_database.dart        # Configuração do SQLite (sqflite)
│  └─ di/
│     └─ app_module.dart          # Módulo Injectable com provedores (DAO, etc.)
│
├─ feature/
│  └─ atendimento/
│     ├─ domain/
│     │  ├─ atendimento.dart      # Entidade + enum de status
│     │  └─ atendimento_repository.dart
│     │                            # Interface do repositório
│     ├─ data/
│     │  ├─ atendimento_dao.dart  # DAO: CRUD direto no SQLite
│     │  └─ atendimento_repository_impl.dart
│     │                            # Implementação do repositório usando o DAO
│     └─ presentation/
│        ├─ form/
│        │  ├─ atendimento_form_cubit.dart
│        │  └─ atendimento_form_state.dart
│        ├─ list/
│        │  ├─ atendimento_list_cubit.dart
│        │  └─ atendimento_list_state.dart
│        └─ pages/
│           ├─ atendimento_list_page.dart
│           ├─ atendimento_form_page.dart
│           └─ atendimento_execucao_page.dart
│
├─ injection.dart                  # Inicializa o GetIt com Injectable
├─ injection.config.dart           # ARQUIVO GERADO (não editar na mão)
└─ main.dart                       # Ponto de entrada do app
```

---

## 3. Banco de dados (`app_database.dart`)

O banco local é criado com o nome **`atendimentos.db`** usando `sqflite`.  
A tabela principal é:

```sql
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
```

- `status` é salvo como texto (`ativo`, `em_andamento`, `finalizado`).
- `ativo` e `excluido` são inteiros (`0` ou `1`) usados para **ativação/desativação lógica** e **exclusão lógica**.

Se você alterar a estrutura da tabela, será necessário:
1. Aumentar a constante `_dbVersion` em `app_database.dart`.
2. Implementar uma lógica de **migração** em `onUpgrade` (se desejar migrar dados).  

Se estiver apenas em desenvolvimento/testes, o jeito mais simples para “resetar” é **desinstalar o app do dispositivo/emulador** para que o banco seja recriado do zero.

---

## 4. Injeção de dependência (GetIt + Injectable)

- `lib/injection.dart`
  - Define o `GetIt getIt = GetIt.instance;`
  - Possui a função `configureDependencies()` anotada com `@InjectableInit()`.
- `lib/injection.config.dart`
  - Gerado automaticamente pelo `injectable_generator`.
  - Registra:
    - `AtendimentoDao`
    - `AtendimentoRepositoryImpl` como implementação de `AtendimentoRepository`
- `lib/core/di/app_module.dart`
  - Define o módulo com `@module` e um `@lazySingleton` para `AtendimentoDao`.

No `main.dart`, antes de rodar o app, o código garante que as dependências estão configuradas:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const AtendimentosApp());
}
```

Sempre que você adicionar novas dependências anotadas com `@injectable` ou mudar `@module`s,
rode novamente o gerador (veja seção 6).

---

## 5. Fluxo da aplicação

### 5.1. Lista de Atendimentos (`AtendimentoListPage`)

Tela inicial da aplicação, com:

- **Filtros**:
  - Campo de texto para filtrar por **nome**.
  - Filtros por **status** (chips/botões): “Todos”, “Ativos”, “Em andamento”, “Finalizados”.
- **Lista**:
  - Mostra os atendimentos retornados por `AtendimentoListCubit`, que usa `AtendimentoRepository`.
- **Ações** em cada item (via menu/botão de contexto):
  - Editar atendimento.
  - Ir para tela de **execução**.
  - **Excluir logicamente** (marca `excluido = 1`).
  - **Ativar/Desativar** (`ativo = 1` ou `0`).

O estado da tela é representado por `AtendimentoListState`:

- `itens`: lista de `Atendimento`.
- `loading`: indica se está carregando.
- `filtroNome` / `filtroStatus`.
- `error`: mensagem de erro (se houver).

### 5.2. Cadastro/Edição (`AtendimentoFormPage`)

Usa `AtendimentoFormCubit` + `AtendimentoFormState`:

- Permite **criar** um atendimento ou **editar** um existente.
- Campos (podem variar levemente conforme a versão do código):
  - Nome
  - Descrição
  - Data de criação (com seletor de data)
  - Observações (opcional)
  - Status/ativo (switch ou controles equivalentes)
  - Imagem (opcional) – escolhida/registrada via `image_picker`

Ao salvar, o Cubit chama `AtendimentoRepository.salvar(atendimento)`, que decide:

- Se `id == null` → `insert`.
- Se `id != null` → `update`.

### 5.3. Execução do atendimento (`AtendimentoExecucaoPage`)

Tela focada na **execução/andamento** do atendimento:

- Permite **tirar fotos** ou **selecionar imagens da galeria** com `image_picker`.
- As imagens são salvas no caminho informado em `imagem_path` (usando `dart:io` `File`).
- Botão para **marcar o atendimento como “Finalizado”** (`AtendimentoStatus.finalizado`),
  geralmente exigindo que existam registros/imagens de execução.

---

## 6. Configurando o projeto (passo a passo)

### 6.1. Pré-requisitos

1. **Flutter instalado** (3.x recomendado)  
   Verifique com:
   ```bash
   flutter --version
   ```
2. **Dart SDK** já vem com o Flutter.
3. Editor/IDE:
   - VS Code com extensão Flutter/Dart, **ou**
   - Android Studio.

### 6.2. Copiando a pasta `lib/`

1. Crie um projeto Flutter vazio (se ainda não tiver):
   ```bash
   flutter create atendimentos_android
   ```

2. Apague a pasta `lib/` que o projeto criou automaticamente.

3. Copie a pasta `lib/` deste `.zip` e **substitua** a pasta `lib/` do seu projeto.

### 6.3. Ajustando o `pubspec.yaml`

No arquivo `pubspec.yaml` do seu projeto, em `dependencies:` / `dev_dependencies:`, garanta a inclusão dos pacotes abaixo (use as versões mais recentes do pub.dev):

- `flutter_bloc`
- `equatable`
- `get_it`
- `injectable`
- `sqflite`
- `path`
- `image_picker`

Em `dev_dependencies`:

- `build_runner`
- `injectable_generator`

> Não há problema em já existir outras dependências — apenas **adicione ou atualize** estas.

Depois de ajustar o `pubspec.yaml`, rode:

```bash
flutter pub get
```

### 6.4. Gerando (ou regenerando) `injection.config.dart`

Se você **alterar** as anotações de Injectable ou criar novos serviços, gere novamente o arquivo:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

No projeto enviado, o arquivo `lib/injection.config.dart` já está presente, então isso só é obrigatório se você fizer mudanças na DI.

### 6.5. Permissões de câmera/galeria

Como o app usa `image_picker`, é preciso configurar permissões de plataforma.

#### Android (`android/app/src/main/AndroidManifest.xml`)

Dentro da tag `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

E, dependendo da sua versão de SDK/estratégia de armazenamento, permissões para fotos/arquivos.
Consulte a documentação do `image_picker` para a versão que estiver usando.

#### iOS (`ios/Runner/Info.plist`)

Adicione chaves como:

```xml
<key>NSCameraUsageDescription</key>
<string>Este app precisa acessar a câmera para registrar fotos do atendimento.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Este app precisa acessar suas fotos para anexar imagens ao atendimento.</string>
```

---

## 7. Executando o app

Com tudo configurado (Flutter, dependências e permissões):

1. Conecte um **emulador** ou **dispositivo físico**.
2. Execute:

```bash
flutter run
```

ou use o botão **Run** da IDE.

A tela inicial será a `AtendimentoListPage`, com a lista (inicialmente vazia) de atendimentos.

---

## 8. Como estender o projeto

### 8.1. Adicionar novos campos aos atendimentos

1. **Modelo (`Atendimento`)**  
   - Edite `lib/feature/atendimento/domain/atendimento.dart`.
   - Adicione o novo campo na classe, no `toMap()` e em `fromMap()`.

2. **Banco (`AppDatabase`)**  
   - Atualize a tabela em `lib/core/database/app_database.dart`.
   - Aumente `_dbVersion` e implemente lógica em `onUpgrade` (se necessário).

3. **DAO e Repositório**  
   - Ajuste `AtendimentoDao` e `AtendimentoRepositoryImpl` para lidar com o novo campo.

4. **Telas**  
   - Atualize `AtendimentoFormPage` para incluir o campo no formulário.
   - Se quiser filtrar/listar, ajuste `AtendimentoListCubit`/`State` e a UI.

### 8.2. Adicionar novos módulos/funcionalidades

- Crie uma nova pasta em `feature/` (por exemplo, `feature/cliente/`).
- Siga o mesmo padrão:
  - `domain/` (entidades + interfaces)
  - `data/` (DAO + repositório)
  - `presentation/` (cubits, states, pages)
- Registre implementações em:
  - `app_module.dart` (quando for um provedor simples), ou
  - usando `@injectable` diretamente nas classes.
- Rode novamente o `build_runner` para atualizar `injection.config.dart`.

---

## 9. Resumo rápido (para usar “sem pensar muito”)

1. Criar/abrir um projeto Flutter.
2. Substituir a pasta `lib/` pela pasta `lib/` deste `.zip`.
3. Conferir/atualizar as dependências em `pubspec.yaml`:
   - `flutter_bloc`, `equatable`, `sqflite`, `path`, `image_picker`, `get_it`, `injectable`,
     `build_runner`, `injectable_generator`.
4. Rodar `flutter pub get`.
5. (Opcional) Rodar `flutter pub run build_runner build --delete-conflicting-outputs` se mexer na DI.
6. Ajustar permissões de câmera/galeria no Android/iOS.
7. Rodar `flutter run` e testar o fluxo:
   - Listar → Criar atendimento → Anexar imagem → Finalizar atendimento.

Se você me mandar também o `pubspec.yaml` ou o projeto completo, posso ajustar este README para ficar 100% alinhado com seu setup real.
