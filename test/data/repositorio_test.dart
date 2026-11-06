import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/core/configuracao.dart';
import 'package:manejador_leitores/core/modelos.dart';
import 'package:manejador_leitores/data/banco.dart';
import 'package:manejador_leitores/data/repositorio.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Repositorio repo;

  setUp(() => repo = Repositorio(Banco(NativeDatabase.memory())));
  tearDown(() => repo.fechar());

  test('salva leitor com regras e mantém o par bidirecional', () async {
    final a = await repo.salvarLeitor(const Leitor(id: 0, nome: 'Ana'));
    final b = await repo.salvarLeitor(const Leitor(id: 0, nome: 'Beto'));
    final c = await repo.salvarLeitor(const Leitor(id: 0, nome: 'Cida'));

    var ls = await repo.leitores();
    await repo.salvarLeitor(ls.firstWhere((l) => l.id == a).copyWith(
          parId: () => b,
          regras: [const RegraEpoca(padrao: PadraoData.faixaDiasMes, diaDe: 1, diaAte: 7)],
        ));
    ls = await repo.leitores();
    Leitor por(int id) => ls.firstWhere((l) => l.id == id);
    expect(por(a).parId, b);
    expect(por(b).parId, a);
    expect(por(a).regras.single.diaAte, 7);

    // Troca o par de B para C: A perde o par.
    await repo.salvarLeitor(por(b).copyWith(parId: () => c));
    ls = await repo.leitores();
    expect(por(a).parId, isNull);
    expect(por(b).parId, c);
    expect(por(c).parId, b);

    // Remove de um lado, remove do outro.
    await repo.salvarLeitor(por(c).copyWith(parId: () => null));
    ls = await repo.leitores();
    expect(por(b).parId, isNull);
  });

  test('abre o mês uma única vez e cria vagas', () async {
    const cfg = Configuracao();
    final m1 = await repo.abrirMes(2026, 6, cfg);
    final m2 = await repo.abrirMes(2026, 6, cfg);
    // 12 de domingo + 3 quintas + Corpus Christi, Sagrado Coração e São João.
    expect(m1.celebracoes, hasLength(18));
    expect(m2.celebracoes.map((c) => c.id), m1.celebracoes.map((c) => c.id));
    expect(m1.vagas, hasLength(12 * 4 + 3 * 3 + 3 * 4));
    expect(m1.publicado, isFalse);
  });

  test('leitores importados usam os padrões: não lê quinta nem festa', () async {
    await repo.importarNomes(['Ana', 'Beto']);
    final ls = await repo.leitores();
    expect(ls.map((l) => l.leQuinta), everyElement(LeQuinta.nao));
    expect(ls.map((l) => l.leFesta), everyElement(isFalse));
    expect(ls.map((l) => l.leDomingo), everyElement(isTrue));
  });

  test('exclusão lógica: some da lista, fica na escala, restaura com o par', () async {
    final rosa = await repo.salvarLeitor(const Leitor(id: 0, nome: 'Rosa', regras: [
      RegraEpoca(padrao: PadraoData.faixaDiasMes, diaDe: 1, diaAte: 7),
    ]));
    final tita = await repo.salvarLeitor(const Leitor(id: 0, nome: 'Tita'));
    await repo.salvarLeitor((await repo.leitores()).firstWhere((l) => l.id == rosa).copyWith(parId: () => tita));
    final m = await repo.abrirMes(2026, 6, const Configuracao());
    final cel = m.celebracoes.first;
    await repo.definirVaga(Vaga(celebracaoId: cel.id, funcao: Funcao.leitura1, leitorId: rosa, travada: true));

    await repo.excluirLeitores([rosa]);
    expect((await repo.leitores()).map((l) => l.nome), ['Tita']);
    expect((await repo.leitores()).single.parId, isNull, reason: 'quem ficou perde o par');
    expect((await repo.mesEscala(2026, 6)).vaga(cel.id, Funcao.leitura1)!.leitorId, rosa);
    final excluidos = await repo.leitoresExcluidos();
    expect(excluidos.single.nome, 'Rosa');
    expect(excluidos.single.excluidoEm, isNotNull);
    expect((await repo.leitorComNome('rosa'))!.excluidoEm, isNotNull);

    await repo.restaurarLeitores([rosa]);
    final ls = await repo.leitores();
    expect(ls.map((l) => l.nome), ['Rosa', 'Tita']);
    expect(ls.firstWhere((l) => l.id == rosa).regras, hasLength(1), reason: 'volta com as configurações');
    expect(ls.firstWhere((l) => l.id == tita).parId, rosa, reason: 'par refeito');

    expect(await repo.desfazer(), 'Restaurar leitor');
    expect(await repo.leitores(), hasLength(1));
    expect(await repo.desfazer(), 'Excluir leitor');
    expect(await repo.leitores(), hasLength(2));
  });

  test('edição em lote em um único passo de desfazer', () async {
    await repo.importarNomes(['Ana', 'Beto', 'Cida']);
    final ls = await repo.leitores();
    await repo.atualizarLeitores([
      for (final l in ls.take(2)) l.copyWith(leQuinta: LeQuinta.asVezes, leFesta: true),
    ]);
    var depois = await repo.leitores();
    expect(depois.map((l) => l.leQuinta), [LeQuinta.asVezes, LeQuinta.asVezes, LeQuinta.nao]);
    expect(await repo.desfazer(), 'Editar 2 leitores');
    depois = await repo.leitores();
    expect(depois.map((l) => l.leQuinta), everyElement(LeQuinta.nao));
  });

  test('mês criado antes das festas automáticas recebe as festas uma vez', () async {
    const cfg = Configuracao();
    final m = await repo.abrirMes(2026, 6, cfg);
    // Simula um mês da v1.0: sem festas e com versaoCalendario 0.
    final festas = m.celebracoes.where((c) => c.tipo == TipoCelebracao.festa).map((c) => c.id).toList();
    for (final id in festas) {
      await repo.excluirCelebracao(id);
    }
    await repo.db.customStatement('UPDATE meses SET versao_calendario = 0');
    final reaberto = await repo.abrirMes(2026, 6, cfg);
    expect(reaberto.celebracoes.where((c) => c.tipo == TipoCelebracao.festa), hasLength(3));
    // Abrir de novo não duplica.
    expect((await repo.abrirMes(2026, 6, cfg)).celebracoes, hasLength(reaberto.celebracoes.length));
    expect(await repo.incluirFestasDoCalendario(2026, 6, cfg), 0);
  });

  test('pilha de desfazer guarda no máximo 50 passos', () async {
    for (var i = 0; i < 55; i++) {
      await repo.salvarLeitor(Leitor(id: 0, nome: 'L$i'));
    }
    var desfeitos = 0;
    while (await repo.desfazer() != null) {
      desfeitos++;
    }
    expect(desfeitos, 50);
    expect(await repo.leitores(), hasLength(5));
  });

  test('histórico considera só datas anteriores quando pedido', () async {
    final id = await repo.salvarLeitor(const Leitor(id: 0, nome: 'Tita'));
    final jun = await repo.abrirMes(2026, 6, const Configuracao());
    final jul = await repo.abrirMes(2026, 7, const Configuracao());
    await repo.definirVaga(Vaga(celebracaoId: jun.celebracoes.first.id, funcao: Funcao.preces, leitorId: id));
    await repo.definirVaga(Vaga(celebracaoId: jul.celebracoes.first.id, funcao: Funcao.preces, leitorId: id));
    expect((await repo.historico())[id], hasLength(2));
    expect((await repo.historico(antesDe: DateTime.utc(2026, 7, 1)))[id], [jun.celebracoes.first.data]);
  });

  test('pastorais do mês podem ser sobrescritas', () async {
    const cfg = Configuracao();
    await repo.abrirMes(2026, 6, cfg);
    await repo.aplicarPastoraisDoMes(2026, 6, [
      const ConfigPastoral(nome: pastoralTercoMulheres, posicaoDomingo: 1, hora: '18:00'),
      const ConfigPastoral(nome: pastoralTercoHomens, posicaoDomingo: 2, hora: '09:00'),
    ], cfg);
    final m = await repo.mesEscala(2026, 6);
    final pastorais = m.celebracoes.where((c) => c.atribuicao == Atribuicao.pastoral).map((c) => (c.data.day, c.hora));
    expect(pastorais, [(7, '18:00'), (14, '09:00')]);
    expect(m.pastorais, hasLength(2));
  });

  test('backup exporta e restaura tudo', () async {
    await repo.salvarLeitor(const Leitor(id: 0, nome: 'Selma', soPastoral: pastoralTercoMulheres));
    await repo.abrirMes(2026, 6, const Configuracao());
    await repo.salvarConfiguracao(const Configuracao(intervaloMinimoSemanas: 6));
    await repo.marcarEnviado(DateTime.utc(2026, 6, 7), true);
    final backup = await repo.exportarBackup();

    final outro = Repositorio(Banco(NativeDatabase.memory()));
    await outro.restaurarBackup(backup);
    expect((await outro.leitores()).single.soPastoral, pastoralTercoMulheres);
    expect((await outro.mesEscala(2026, 6)).celebracoes, hasLength(18));
    expect((await outro.configuracao()).intervaloMinimoSemanas, 6);
    expect(await outro.diasEnviados(), {DateTime.utc(2026, 6, 7)});
    await outro.fechar();

    expect(() => repo.restaurarBackup({'app': 'outro'}), throwsFormatException);
  });

  test('restaura backup da v1.0 (sem as colunas novas)', () async {
    await repo.salvarLeitor(const Leitor(id: 0, nome: 'Selma'));
    await repo.abrirMes(2026, 6, const Configuracao());
    final b = await repo.exportarBackup();
    final dados = b['dados'] as Map<String, dynamic>;
    for (final l in dados['leitores'] as List) {
      (l as Map).remove('excluidoEm');
    }
    for (final m in dados['meses'] as List) {
      (m as Map).remove('versaoCalendario');
    }
    b['versao'] = 1;

    final outro = Repositorio(Banco(NativeDatabase.memory()));
    await outro.restaurarBackup(b);
    expect((await outro.leitores()).single.nome, 'Selma');
    expect((await outro.mesEscala(2026, 6)).celebracoes, isNotEmpty);
    await outro.fechar();
  });
}
