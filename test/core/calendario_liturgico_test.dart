import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/core/calendario_liturgico.dart';
import 'package:manejador_leitores/core/configuracao.dart';
import 'package:manejador_leitores/core/modelos.dart';

DateTime d(int a, int m, int dia) => DateTime.utc(a, m, dia);
DateTime dataDe(String chave, int ano) => festaPorChave(chave)!.data(ano);

void main() {
  test('Páscoa', () {
    expect(pascoa(2024), d(2024, 3, 31));
    expect(pascoa(2025), d(2025, 4, 20));
    expect(pascoa(2026), d(2026, 4, 5));
    expect(pascoa(2027), d(2027, 3, 28));
    expect(pascoa(2038), d(2038, 4, 25));
  });

  test('datas móveis e transferências', () {
    expect(dataDe('cinzas', 2026), d(2026, 2, 18));
    expect(dataDe('quintaSanta', 2026), d(2026, 4, 2));
    expect(dataDe('vigiliaPascal', 2026), d(2026, 4, 4));
    expect(dataDe('corpusChristi', 2026), d(2026, 6, 4));
    expect(dataDe('sagradoCoracao', 2026), d(2026, 6, 12));
    // São José na Semana Santa vai para o sábado antes de Ramos (2008).
    expect(dataDe('saoJose', 2008), d(2008, 3, 15));
    // Anunciação na Semana Santa/oitava vai para a segunda após a oitava (2016).
    expect(dataDe('anunciacao', 2016), d(2016, 4, 4));
    // Imaculada no domingo vai para segunda (2024).
    expect(dataDe('imaculada', 2024), d(2024, 12, 9));
    // São João no mesmo dia do Sagrado Coração vai para 23/6 (2022).
    expect(dataDe('saoJoao', 2022), d(2022, 6, 23));
  });

  test('abril/2026: Quinta Santa no lugar da quinta, sexta sem missa, Vigília com 6 funções', () {
    final cels = gerarCelebracoesDoMes(2026, 4, const Configuracao());
    final dia2 = cels.where((c) => c.data == d(2026, 4, 2)).toList();
    expect(dia2, hasLength(1));
    expect(dia2.single.tipo, TipoCelebracao.festa);
    expect(dia2.single.hora, '19:30');
    expect(dia2.single.nomeLiturgico, contains('Lava-pés'));
    expect(cels.where((c) => c.data == d(2026, 4, 3)), isEmpty);
    final vigilia = cels.singleWhere((c) => c.data == d(2026, 4, 4));
    expect(vigilia.funcoes, [
      Funcao.animador,
      Funcao.leitura1,
      Funcao.leitura2,
      Funcao.leitura3,
      Funcao.epistola,
      Funcao.preces,
    ]);
    // A Páscoa é domingo normal.
    expect(cels.where((c) => c.data == d(2026, 4, 5)).map((c) => c.tipo), everyElement(TipoCelebracao.domingo));
  });

  test('dezembro/2026: festas, Noite de Natal substitui a quinta 24', () {
    final cels = gerarCelebracoesDoMes(2026, 12, const Configuracao());
    final festas = cels.where((c) => c.tipo == TipoCelebracao.festa).map((c) => (c.data.day, c.hora)).toList();
    expect(festas, [(8, '19:30'), (24, '20:00'), (25, '09:00')]);
    expect(cels.where((c) => c.data == d(2026, 12, 24) && c.tipo == TipoCelebracao.quinta), isEmpty);
  });

  test('festa desativada ou com outro horário', () {
    final cfg = const Configuracao().copyWith(festas: [
      for (final f in configFestasPadrao())
        if (f.chave == 'finados')
          f.copyWith(horas: ['07:00', '19:30'])
        else if (f.chave == 'imaculada')
          f.copyWith(ativa: false)
        else
          f,
    ]);
    final nov = gerarCelebracoesDoMes(2026, 11, cfg);
    expect(nov.where((c) => c.data == d(2026, 11, 2)).map((c) => c.hora), ['07:00', '19:30']);
    final dez = gerarCelebracoesDoMes(2026, 12, cfg);
    expect(dez.where((c) => c.data == d(2026, 12, 8)), isEmpty);
    expect(Configuracao.fromJson(cfg.toJson()).toJson(), cfg.toJson());
  });

  test('festa no domingo só dá nome às missas', () {
    // 2027: Finados é terça; 2025: Aparecida (12/10) é domingo.
    final out = gerarCelebracoesDoMes(2025, 10, const Configuracao());
    final dia12 = out.where((c) => c.data == d(2025, 10, 12)).toList();
    expect(dia12.map((c) => c.tipo), everyElement(TipoCelebracao.domingo));
    expect(dia12.map((c) => c.nomeLiturgico), everyElement('Nossa Senhora Aparecida'));
  });
}
