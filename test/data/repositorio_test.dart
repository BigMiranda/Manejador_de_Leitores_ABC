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
    expect(m1.celebracoes, hasLength(16));
    expect(m2.celebracoes.map((c) => c.id), m1.celebracoes.map((c) => c.id));
    expect(m1.vagas, hasLength(4 * 3 * 4 + 4 * 3));
    expect(m1.publicado, isFalse);
  });

  test('excluir leitor preserva o nome na escala e desfazer restaura', () async {
    final id = await repo.salvarLeitor(const Leitor(id: 0, nome: 'Rosa'));
    final m = await repo.abrirMes(2026, 6, const Configuracao());
    final cel = m.celebracoes.first;
    await repo.definirVaga(Vaga(celebracaoId: cel.id, funcao: Funcao.leitura1, leitorId: id, travada: true));

    await repo.excluirLeitor(id);
    var v = (await repo.mesEscala(2026, 6)).vaga(cel.id, Funcao.leitura1)!;
    expect(v.leitorId, isNull);
    expect(v.nomeLivre, 'Rosa');
    expect(await repo.leitores(), isEmpty);

    expect(await repo.desfazer(), 'Excluir leitor');
    v = (await repo.mesEscala(2026, 6)).vaga(cel.id, Funcao.leitura1)!;
    expect(v.leitorId, id);
    expect((await repo.leitores()).single.nome, 'Rosa');

    expect(await repo.refazer(), 'Excluir leitor');
    expect(await repo.leitores(), isEmpty);
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
    expect((await outro.mesEscala(2026, 6)).celebracoes, hasLength(16));
    expect((await outro.configuracao()).intervaloMinimoSemanas, 6);
    expect(await outro.diasEnviados(), {DateTime.utc(2026, 6, 7)});
    await outro.fechar();

    expect(() => repo.restaurarBackup({'app': 'outro'}), throwsFormatException);
  });
}
