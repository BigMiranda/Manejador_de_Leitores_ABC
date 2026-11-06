import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'banco.g.dart';

/// Datas são guardadas como texto "aaaa-mm-dd"; horas como "HH:mm".
@DataClassName('LeitorRow')
class Leitores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().unique()();
  BoolColumn get vaiLer => boolean().withDefault(const Constant(true))();
  TextColumn get fazAnimacao => text().withDefault(const Constant('nao'))();
  BoolColumn get leDomingo => boolean().withDefault(const Constant(true))();
  TextColumn get horariosDomingo => text().withDefault(const Constant('07:00,09:00,18:00'))();
  TextColumn get leQuinta => text().withDefault(const Constant('sim'))();
  BoolColumn get leFesta => boolean().withDefault(const Constant(true))();
  TextColumn get soPastoral => text().nullable()();
  IntColumn get parId => integer().nullable()();
  TextColumn get ultimaParticipacao => text().nullable()();
  TextColumn get observacoes => text().withDefault(const Constant(''))();
}

@DataClassName('RegraRow')
class Regras extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get leitorId => integer().references(Leitores, #id, onDelete: KeyAction.cascade)();

  /// [RegraEpoca] serializada em JSON.
  TextColumn get dados => text()();
}

@DataClassName('CelebracaoRow')
class Celebracoes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get data => text()();
  TextColumn get hora => text()();
  TextColumn get tipo => text()();
  TextColumn get nomeLiturgico => text().nullable()();

  /// Nomes de [Funcao] separados por vírgula.
  TextColumn get funcoes => text()();
  TextColumn get atribuicao => text().withDefault(const Constant('leitores'))();
  TextColumn get atribuicaoTexto => text().nullable()();
  TextColumn get pdfUrl => text().nullable()();
  TextColumn get pdfArquivo => text().nullable()();

  /// pendente | ok | naoPublicado
  TextColumn get pdfStatus => text().withDefault(const Constant('pendente'))();
}

@DataClassName('VagaRow')
class Vagas extends Table {
  IntColumn get celebracaoId => integer().references(Celebracoes, #id, onDelete: KeyAction.cascade)();
  TextColumn get funcao => text()();
  IntColumn get leitorId => integer().nullable()();
  TextColumn get nomeLivre => text().nullable()();
  BoolColumn get travada => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {celebracaoId, funcao};
}

@DataClassName('MesRow')
class Meses extends Table {
  IntColumn get ano => integer()();
  IntColumn get mes => integer()();

  /// rascunho | publicado
  TextColumn get status => text().withDefault(const Constant('rascunho'))();
  IntColumn get seed => integer().withDefault(const Constant(0))();

  /// Sobrescrita das pastorais neste mês (JSON), ou null para usar o padrão.
  TextColumn get pastorais => text().nullable()();

  @override
  Set<Column> get primaryKey => {ano, mes};
}

@DataClassName('EnvioRow')
class Envios extends Table {
  TextColumn get data => text()();
  TextColumn get enviadoEm => text()();

  @override
  Set<Column> get primaryKey => {data};
}

@DataClassName('ConfigRow')
class Configs extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {chave};
}

@DriftDatabase(tables: [Leitores, Regras, Celebracoes, Vagas, Meses, Envios, Configs])
class Banco extends _$Banco {
  Banco([QueryExecutor? executor])
      : super(executor ??
            driftDatabase(
              name: 'leitores_abc',
              native: const DriftNativeOptions(shareAcrossIsolates: true),
            ));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
