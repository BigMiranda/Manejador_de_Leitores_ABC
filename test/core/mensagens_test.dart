import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/core/configuracao.dart';
import 'package:manejador_leitores/core/mensagens.dart';
import 'package:manejador_leitores/core/modelos.dart';

const modelos = ModelosMensagem();

Celebracao domingo(int id, String hora, {Atribuicao atribuicao = Atribuicao.leitores, String? texto}) => Celebracao(
      id: id,
      data: DateTime.utc(2026, 6, 7),
      hora: hora,
      tipo: TipoCelebracao.domingo,
      funcoes: Funcao.values,
      atribuicao: atribuicao,
      atribuicaoTexto: texto,
    );

void main() {
  test('saudação por horário', () {
    expect(saudacao(DateTime(2026, 6, 6, 11, 59)), 'Bom dia');
    expect(saudacao(DateTime(2026, 6, 6, 12)), 'Boa tarde');
    expect(saudacao(DateTime(2026, 6, 6, 17, 59)), 'Boa tarde');
    expect(saudacao(DateTime(2026, 6, 6, 18)), 'Boa noite');
  });

  test('mensagem de domingo com três missas', () {
    final texto = montarMensagem(
      modelos: modelos,
      agora: DateTime(2026, 6, 6, 14),
      missas: [
        MissaDoDia(domingo(3, '18:00', atribuicao: Atribuicao.pastoral, texto: pastoralTercoMulheres), {
          Funcao.animador: 'Leonilda',
          Funcao.leitura1: 'Eliane',
          Funcao.leitura2: 'Mary',
          Funcao.preces: 'Maria José',
        }),
        MissaDoDia(domingo(1, '07:00'), {
          Funcao.animador: 'Laude',
          Funcao.leitura1: 'Dona Isa',
          Funcao.leitura2: 'Maria Cida',
          Funcao.preces: 'Luiz Fernando',
        }),
        MissaDoDia(domingo(2, '09:00'), {
          Funcao.animador: 'Drica',
          Funcao.leitura1: 'Karol',
          Funcao.leitura2: null,
          Funcao.preces: 'Valdeir',
        }),
      ],
    );
    expect(texto, '''Boa tarde! A paz a todos vocês.
Passando para lembrar a escala das missas de
amanhã domingo 07/06/26.

Missa das 7:00

Animador
Laude
Primeira leitura
Dona Isa
Segunda leitura
Maria Cida
Preces
Luiz Fernando

Missa das 9:00

Animador
Drica
Primeira leitura
Karol
Segunda leitura
(a definir)
Preces
Valdeir

Missa das 18:00

Animador
Leonilda
Primeira leitura
Eliane
Segunda leitura
Mary
Preces
Maria José

Boa missa a todos.

Peço encarecidamente que todos cheguem com 30 minutos de antecedência.
Desde já agradeço a atenção e a vida de cada um!''');
  });

  test('pastoral sem nomes, escala atualizada e festa sem 2ª leitura', () {
    final festa = Celebracao(
      id: 1,
      data: DateTime.utc(2026, 11, 2),
      hora: '09:00',
      tipo: TipoCelebracao.festa,
      nomeLiturgico: 'Finados',
      funcoes: const [Funcao.animador, Funcao.leitura1, Funcao.preces],
    );
    final pastoral = Celebracao(
      id: 2,
      data: DateTime.utc(2026, 11, 2),
      hora: '18:00',
      tipo: TipoCelebracao.festa,
      funcoes: Funcao.values,
      atribuicao: Atribuicao.pastoral,
      atribuicaoTexto: pastoralTercoHomens,
    );
    final texto = montarMensagem(
      modelos: modelos,
      agora: DateTime(2026, 11, 1, 19, 5),
      escalaAtualizada: true,
      missas: [
        MissaDoDia(festa, {Funcao.animador: 'Bia', Funcao.leitura1: 'Selma', Funcao.preces: 'Clelio'}),
        MissaDoDia(pastoral, const {}),
      ],
    );
    expect(texto, '''Boa noite! A paz a todos vocês.
Passando para lembrar a escala das missas de
amanhã segunda-feira 02/11/26 – Finados.

Escala atualizada

Missa das 9:00

Animador
Bia
Primeira leitura
Selma
Preces
Clelio

Missa das 18:00

Leitores: Terço dos Homens

Boa missa a todos.

Peço encarecidamente que todos cheguem com 30 minutos de antecedência.
Desde já agradeço a atenção e a vida de cada um!''');
  });

  test('mensagem de quinta', () {
    final quinta = Celebracao(
      id: 1,
      data: DateTime.utc(2026, 6, 18),
      hora: '19:30',
      tipo: TipoCelebracao.quinta,
      funcoes: const [Funcao.animador, Funcao.leitura1, Funcao.preces],
    );
    final texto = montarMensagem(
      modelos: modelos,
      agora: DateTime(2026, 6, 17, 9, 30),
      missas: [
        MissaDoDia(quinta, {Funcao.animador: 'Antonio Aureliano', Funcao.leitura1: 'Matheus', Funcao.preces: null}),
      ],
    );
    expect(texto, '''Bom dia, a paz de Cristo e o amor de Maria a todos!

Passando para confirmar a presença dos leitores na missa de amanhã, 18/06/26 às 19:30.

Animação: Antonio Aureliano
Leitura: Matheus
Preces: (a definir)

Peço encarecidamente que todos cheguem com 30 minutos de antecedência.
Desde já agradeço a atenção e compreensão de todos, que Deus abençoe infinitamente a vida de cada um!

Boa missa a todos!''');
  });

  test('PDF só vai em domingo e festa', () {
    expect(levaPdf([domingo(1, '07:00')]), isTrue);
    expect(
      levaPdf([
        Celebracao(id: 1, data: DateTime.utc(2026, 6, 4), hora: '19:30', tipo: TipoCelebracao.quinta, funcoes: const []),
      ]),
      isFalse,
    );
  });
}
