import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/core/configuracao.dart';
import 'package:manejador_leitores/core/escala.dart';
import 'package:manejador_leitores/core/modelos.dart';

const cfg = Configuracao();

List<Leitor> leitoresFicticios(int n) => [
      for (var i = 1; i <= n; i++)
        Leitor(
          id: i,
          nome: 'Leitor $i',
          leQuinta: LeQuinta.sim,
          leFesta: true,
          fazAnimacao: i % 5 == 0
              ? FazAnimacao.simPrefere
              : i % 7 == 0
                  ? FazAnimacao.simPrefereLer
                  : FazAnimacao.nao,
        ),
    ];

Map<int, List<DateTime>> registrar(Map<int, List<DateTime>> hist, ResultadoEscala r, List<Celebracao> cels) {
  final porId = {for (final c in cels) c.id: c};
  for (final v in r.vagas) {
    if (v.leitorId != null) hist.putIfAbsent(v.leitorId!, () => []).add(porId[v.celebracaoId]!.data);
  }
  return hist;
}

void main() {
  test('é determinística para a mesma seed e muda com outra seed', () {
    final leitores = leitoresFicticios(60);
    final cels = gerarCelebracoesDoMes(2026, 6, cfg);
    List<int?> gerar(int seed) =>
        gerarEscala(leitores: leitores, celebracoes: cels, vagas: const [], seed: seed).vagas.map((v) => v.leitorId).toList();
    expect(gerar(1), gerar(1));
    expect(gerar(1), isNot(gerar(2)));
  });

  test('ninguém tem duas funções no mesmo dia e animador sempre faz animação', () {
    final leitores = leitoresFicticios(100);
    final cels = gerarCelebracoesDoMes(2026, 6, cfg);
    final r = gerarEscala(leitores: leitores, celebracoes: cels, vagas: const [], seed: 3);
    final porId = {for (final c in cels) c.id: c};
    final porLeitor = {for (final l in leitores) l.id: l};
    final vistos = <(int, DateTime)>{};
    for (final v in r.vagas.where((v) => v.leitorId != null)) {
      final dia = porId[v.celebracaoId]!.data;
      expect(vistos.add((v.leitorId!, dia)), isTrue, reason: 'leitor ${v.leitorId} repetido em $dia');
      if (v.funcao == Funcao.animador && porId[v.celebracaoId]!.atribuicao == Atribuicao.leitores) {
        expect(porLeitor[v.leitorId]!.fazAnimacao, isNot(FazAnimacao.nao));
      }
    }
  });

  test('"Sim, mas prefere ler" só anima se faltar quem prefere', () {
    final leitores = [
      const Leitor(id: 1, nome: 'Prefere', fazAnimacao: FazAnimacao.simPrefere, leQuinta: LeQuinta.sim),
      const Leitor(id: 2, nome: 'Prefere ler', fazAnimacao: FazAnimacao.simPrefereLer, leQuinta: LeQuinta.sim),
      for (var i = 3; i <= 10; i++) Leitor(id: i, nome: 'L$i', leQuinta: LeQuinta.sim),
    ];
    final c = Celebracao(
      id: 1,
      data: DateTime.utc(2026, 6, 4),
      hora: '19:30',
      tipo: TipoCelebracao.quinta,
      funcoes: const [Funcao.animador, Funcao.leitura1, Funcao.preces],
    );
    final r = gerarEscala(leitores: leitores, celebracoes: [c], vagas: const []);
    expect(r.vagas.firstWhere((v) => v.funcao == Funcao.animador).leitorId, 1);

    final semQuemPrefere = leitores.where((l) => l.id != 1).toList();
    final r2 = gerarEscala(leitores: semQuemPrefere, celebracoes: [c], vagas: const []);
    expect(r2.vagas.firstWhere((v) => v.funcao == Funcao.animador).leitorId, 2);

    final r3 = gerarEscala(leitores: leitores.where((l) => l.id > 2).toList(), celebracoes: [c], vagas: const []);
    expect(r3.vagas.firstWhere((v) => v.funcao == Funcao.animador).leitorId, isNull);
    expect(r3.avisos.single.tipo, TipoAviso.vagaSemCandidato);
  });

  test('respeita travas e só preenche células vazias por padrão', () {
    final leitores = leitoresFicticios(40);
    final cels = gerarCelebracoesDoMes(2026, 6, cfg);
    final primeira = cels.firstWhere((c) => c.atribuicao == Atribuicao.leitores);
    final travada = Vaga(celebracaoId: primeira.id, funcao: Funcao.leitura1, leitorId: 33, travada: true);
    final preenchida = Vaga(celebracaoId: primeira.id, funcao: Funcao.preces, leitorId: 34);
    final r = gerarEscala(leitores: leitores, celebracoes: cels, vagas: [travada, preenchida], seed: 9);
    Vaga achar(Funcao f) => r.vagas.firstWhere((v) => v.celebracaoId == primeira.id && v.funcao == f);
    expect(achar(Funcao.leitura1).leitorId, 33);
    expect(achar(Funcao.leitura1).travada, isTrue);
    expect(achar(Funcao.preces).leitorId, 34);

    final refeito = gerarEscala(
      leitores: leitores,
      celebracoes: cels,
      vagas: [travada, preenchida],
      seed: 9,
      config: const ConfigEscala(refazerDestravadas: true),
    );
    expect(refeito.vagas.firstWhere((v) => v.celebracaoId == primeira.id && v.funcao == Funcao.leitura1).leitorId, 33);
  });

  test('nunca mexe em comunidade e só propõe leitores da pastoral', () {
    final leitores = [
      ...leitoresFicticios(40),
      const Leitor(id: 101, nome: 'Mulher 1', soPastoral: pastoralTercoMulheres),
      const Leitor(id: 102, nome: 'Mulher 2', soPastoral: pastoralTercoMulheres),
    ];
    final cels = [
      ...gerarCelebracoesDoMes(2026, 6, cfg),
      Celebracao(
        id: 999,
        data: DateTime.utc(2026, 6, 10),
        hora: '19:30',
        tipo: TipoCelebracao.especial,
        funcoes: const [Funcao.animador, Funcao.leitura1, Funcao.preces],
        atribuicao: Atribuicao.comunidade,
        atribuicaoTexto: 'Comunidades Divino Espírito Santo e São Judas Tadeu',
      ),
    ];
    final r = gerarEscala(leitores: leitores, celebracoes: cels, vagas: const [], seed: 1);
    expect(r.vagas.where((v) => v.celebracaoId == 999).every((v) => v.vazia), isTrue);

    final mulheres = cels.firstWhere((c) => c.atribuicaoTexto == pastoralTercoMulheres);
    expect(mulheres.data, DateTime.utc(2026, 6, 7));
    expect(mulheres.hora, '18:00');
    final nomes = r.vagas.where((v) => v.celebracaoId == mulheres.id).map((v) => v.leitorId).toList();
    expect(nomes.whereType<int>().toSet(), {101, 102});
    expect(nomes.where((n) => n == null).length, 2, reason: 'faltam leitores: vagas ficam vazias');

    final foraDaPastoral = r.vagas.where((v) => v.celebracaoId != mulheres.id).map((v) => v.leitorId);
    expect(foraDaPastoral, isNot(contains(101)));
    expect(foraDaPastoral, isNot(contains(102)));
  });

  test('par "ler junto" fica na mesma celebração quando possível', () {
    final leitores = [
      const Leitor(id: 1, nome: 'Anima', fazAnimacao: FazAnimacao.simPrefere, parId: 2),
      const Leitor(id: 2, nome: 'Par', parId: 1),
      for (var i = 3; i <= 12; i++) Leitor(id: i, nome: 'L$i', ultimaParticipacao: DateTime.utc(2026, 5, 31)),
    ];
    final c = Celebracao(
      id: 1,
      data: DateTime.utc(2026, 6, 7),
      hora: '09:00',
      tipo: TipoCelebracao.domingo,
      funcoes: Funcao.values,
    );
    final r = gerarEscala(leitores: leitores, celebracoes: [c], vagas: const []);
    final ids = r.vagas.map((v) => v.leitorId).toList();
    expect(ids.first, 1);
    expect(ids, contains(2));
    expect(r.avisos.where((a) => a.tipo == TipoAviso.parNaoAtendido), isEmpty);

    // Par impedido: segue sem ele e avisa.
    final impedido = [
      leitores[0],
      Leitor(id: 2, nome: 'Par', parId: 1, regras: [
        RegraEpoca(inicio: DateTime.utc(2026, 6, 1), fim: DateTime.utc(2026, 6, 30)),
      ]),
      ...leitores.skip(2),
    ];
    final r2 = gerarEscala(leitores: impedido, celebracoes: [c], vagas: const []);
    expect(r2.vagas.map((v) => v.leitorId), isNot(contains(2)));
    expect(r2.avisos.where((a) => a.tipo == TipoAviso.parNaoAtendido), hasLength(1));
  });

  test('restrições fortes: domingo, horário, quinta, festa, impedimento e "não vai ler"', () {
    final c = Celebracao(
      id: 1,
      data: DateTime.utc(2026, 6, 7),
      hora: '07:00',
      tipo: TipoCelebracao.domingo,
      funcoes: const [Funcao.leitura1],
    );
    expect(motivosInelegivel(const Leitor(id: 1, nome: 'a', leDomingo: false), c, Funcao.leitura1), isNotEmpty);
    expect(motivosInelegivel(const Leitor(id: 1, nome: 'a', horariosDomingo: {'09:00'}), c, Funcao.leitura1), isNotEmpty);
    expect(motivosInelegivel(const Leitor(id: 1, nome: 'a', vaiLer: false), c, Funcao.leitura1), isNotEmpty);
    expect(motivosInelegivel(const Leitor(id: 1, nome: 'a'), c, Funcao.leitura1), isEmpty);
    final quinta = Celebracao(
        id: 2, data: DateTime.utc(2026, 6, 4), hora: '19:30', tipo: TipoCelebracao.quinta, funcoes: const []);
    expect(motivosInelegivel(const Leitor(id: 1, nome: 'a', leQuinta: LeQuinta.nao), quinta, Funcao.leitura1), isNotEmpty);
    expect(motivosInelegivel(const Leitor(id: 1, nome: 'a', leQuinta: LeQuinta.asVezes), quinta, Funcao.leitura1), isEmpty);
    expect(motivosInelegivel(const Leitor(id: 1, nome: 'a'), quinta, Funcao.leitura1), isNotEmpty,
        reason: 'por padrão não lê de quinta');
    final festa = Celebracao(
        id: 3, data: DateTime.utc(2026, 11, 2), hora: '09:00', tipo: TipoCelebracao.festa, funcoes: const []);
    expect(motivosInelegivel(const Leitor(id: 1, nome: 'a'), festa, Funcao.leitura1), isNotEmpty,
        reason: 'por padrão não lê em festa');
    expect(motivosInelegivel(const Leitor(id: 1, nome: 'a', leFesta: true), festa, Funcao.leitura1), isEmpty);
    expect(motivosInelegivel(Leitor(id: 1, nome: 'a', excluidoEm: DateTime(2026)), c, Funcao.leitura1), isNotEmpty);
  });

  test('justiça ao longo de 12 meses simulados com 100 leitores', () {
    final leitores = leitoresFicticios(100);
    var hist = <int, List<DateTime>>{};
    final avisosIntervalo = <Aviso>[];
    for (var i = 0; i < 12; i++) {
      final alvo = DateTime.utc(2026, 1 + i, 1);
      final cels = gerarCelebracoesDoMes(alvo.year, alvo.month, cfg);
      final r = gerarEscala(
        leitores: leitores,
        celebracoes: cels,
        vagas: const [],
        historico: hist,
        seed: i,
      );
      avisosIntervalo.addAll(r.avisos.where((a) => a.tipo == TipoAviso.abaixoIntervalo));
      expect(r.avisos.where((a) => a.tipo == TipoAviso.vagaSemCandidato), isEmpty);
      hist = registrar(hist, r, cels);
    }
    final leitoresComuns = leitores.where((l) => l.fazAnimacao == FazAnimacao.nao).map((l) => l.id);
    final contagens = [for (final id in leitoresComuns) hist[id]?.length ?? 0];
    final minimo = contagens.reduce((a, b) => a < b ? a : b);
    final maximo = contagens.reduce((a, b) => a > b ? a : b);
    expect(maximo - minimo, lessThanOrEqualTo(2), reason: 'rodízio desequilibrado: $minimo..$maximo');
    expect(avisosIntervalo, isEmpty, reason: 'com 100 leitores ninguém precisa ler com menos de 4 semanas');

    // Intervalo real entre participações de cada leitor comum.
    for (final id in leitoresComuns) {
      final datas = [...?hist[id]]..sort();
      for (var k = 1; k < datas.length; k++) {
        expect(datas[k].difference(datas[k - 1]).inDays, greaterThanOrEqualTo(28));
      }
    }
  });
}
