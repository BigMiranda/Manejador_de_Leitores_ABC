import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/core/modelos.dart';
import 'package:manejador_leitores/core/regras_epoca.dart';

Celebracao cel(int a, int m, int d, {String hora = '09:00', TipoCelebracao? tipo}) {
  final data = DateTime.utc(a, m, d);
  return Celebracao(
    id: 1,
    data: data,
    hora: hora,
    tipo: tipo ??
        (data.weekday == DateTime.sunday
            ? TipoCelebracao.domingo
            : data.weekday == DateTime.thursday
                ? TipoCelebracao.quinta
                : TipoCelebracao.festa),
    funcoes: Funcao.values,
  );
}

Leitor com(List<RegraEpoca> regras) => Leitor(id: 1, nome: 'Ana', regras: regras);

void main() {
  test('sem regras é neutro', () {
    expect(avaliar(com([]), cel(2026, 6, 7)), Avaliacao.neutro);
  });

  test('período fixo é inclusivo nas duas pontas', () {
    final l = com([
      RegraEpoca(inicio: DateTime.utc(2026, 6, 7), fim: DateTime.utc(2026, 6, 14)),
    ]);
    expect(avaliar(l, cel(2026, 6, 7)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 6, 14)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 6, 21)), Avaliacao.neutro);
    expect(avaliar(l, cel(2026, 5, 31)), Avaliacao.neutro);
  });

  test('período anual recorrente que atravessa o ano', () {
    final l = com([
      const RegraEpoca(padrao: PadraoData.anualRecorrente, diaMesInicio: '15/12', diaMesFim: '15/01'),
    ]);
    expect(avaliar(l, cel(2026, 12, 20)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2027, 1, 3)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2027, 1, 15, tipo: TipoCelebracao.festa)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2027, 1, 17)), Avaliacao.neutro);
    expect(avaliar(l, cel(2026, 12, 13)), Avaliacao.neutro);
  });

  test('período anual dentro do mesmo ano', () {
    final l = com([
      const RegraEpoca(padrao: PadraoData.anualRecorrente, diaMesInicio: '01/07', diaMesFim: '31/07'),
    ]);
    expect(avaliar(l, cel(2026, 7, 5)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2027, 7, 4)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 8, 2)), Avaliacao.neutro);
  });

  test('faixa de dias do mês: domingos entre 1 e 7', () {
    final l = com([
      const RegraEpoca(abrangencia: Abrangencia.domingos, padrao: PadraoData.faixaDiasMes, diaDe: 1, diaAte: 7),
    ]);
    expect(avaliar(l, cel(2026, 6, 7)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 6, 4, hora: '19:30')), Avaliacao.neutro, reason: 'é quinta');
    expect(avaliar(l, cel(2026, 6, 14)), Avaliacao.neutro);
    expect(avaliar(l, cel(2026, 11, 1)), Avaliacao.bloqueado);
  });

  test('último domingo do mês', () {
    final l = com([
      const RegraEpoca(abrangencia: Abrangencia.domingos, padrao: PadraoData.posicaoNoMes, posicoes: {5}),
    ]);
    expect(avaliar(l, cel(2026, 6, 28)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 6, 21)), Avaliacao.neutro);
    // Novembro/2026 tem 5 domingos: o último é 29.
    expect(avaliar(l, cel(2026, 11, 29)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 11, 22)), Avaliacao.neutro);
  });

  test('posições múltiplas (1º e 3º) e quintas', () {
    final l = com([
      const RegraEpoca(abrangencia: Abrangencia.quintas, padrao: PadraoData.posicaoNoMes, posicoes: {1, 3}),
    ]);
    expect(avaliar(l, cel(2026, 6, 4, hora: '19:30')), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 6, 11, hora: '19:30')), Avaliacao.neutro);
    expect(avaliar(l, cel(2026, 6, 18, hora: '19:30')), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 6, 7)), Avaliacao.neutro, reason: 'domingo fora da abrangência');
  });

  test('horário específico', () {
    final l = com([
      const RegraEpoca(
        abrangencia: Abrangencia.horario,
        horario: '07:00',
        padrao: PadraoData.faixaDiasMes,
        diaDe: 1,
        diaAte: 31,
      ),
    ]);
    expect(avaliar(l, cel(2026, 6, 7, hora: '07:00')), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 6, 7, hora: '09:00')), Avaliacao.neutro);
  });

  test('vigência limita a regra', () {
    final l = com([
      RegraEpoca(
        padrao: PadraoData.faixaDiasMes,
        diaDe: 1,
        diaAte: 31,
        vigenciaDe: DateTime.utc(2026, 7, 1),
        vigenciaAte: DateTime.utc(2026, 7, 31),
      ),
    ]);
    expect(avaliar(l, cel(2026, 6, 28)), Avaliacao.neutro);
    expect(avaliar(l, cel(2026, 7, 5)), Avaliacao.bloqueado);
    expect(avaliar(l, cel(2026, 8, 2)), Avaliacao.neutro);
  });

  test('preferência dá bônus, prefere não dá penalidade e impedimento vence', () {
    const pref = RegraEpoca(tipo: TipoRegra.preferencia, padrao: PadraoData.faixaDiasMes, diaDe: 1, diaAte: 15);
    const naoPref = RegraEpoca(tipo: TipoRegra.prefereNao, padrao: PadraoData.faixaDiasMes, diaDe: 10, diaAte: 31);
    final l = com([pref, naoPref]);
    expect(avaliar(l, cel(2026, 6, 7)), Avaliacao.bonus);
    expect(avaliar(l, cel(2026, 6, 14)), Avaliacao.neutro);
    expect(avaliar(l, cel(2026, 6, 21)), Avaliacao.penalidade);
    final l2 = com([pref, RegraEpoca(inicio: DateTime.utc(2026, 6, 7), fim: DateTime.utc(2026, 6, 7))]);
    expect(avaliar(l2, cel(2026, 6, 7)), Avaliacao.bloqueado);
  });

  test('regras serializam e voltam iguais', () {
    final r = RegraEpoca(
      tipo: TipoRegra.preferencia,
      abrangencia: Abrangencia.horario,
      horario: '18:00',
      padrao: PadraoData.posicaoNoMes,
      posicoes: const {1, 5},
      vigenciaDe: DateTime.utc(2026, 1, 1),
      descricao: 'teste',
    );
    final volta = RegraEpoca.fromJson(r.toJson());
    expect(volta.toJson(), r.toJson());
  });
}
