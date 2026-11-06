import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/core/modelos.dart';
import 'package:manejador_leitores/data/repositorio.dart';
import 'package:manejador_leitores/ui/tabela_exportacao.dart';

/// Aceita diferenças mínimas de antialiasing entre Windows e o Linux do CI.
class _ComparadorTolerante extends LocalFileComparator {
  _ComparadorTolerante(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final r = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (r.passed || r.diffPercent <= 0.02) return true;
    throw FlutterError(await generateFailureOutput(r, golden, basedir));
  }
}

const _todas = [Funcao.animador, Funcao.leitura1, Funcao.leitura2, Funcao.preces];
const _semSegunda = [Funcao.animador, Funcao.leitura1, Funcao.preces];

/// Junho/2026, igual à escala usada hoje pela paróquia.
MesEscala junho2026() {
  final cels = <Celebracao>[];
  final vagas = <Vaga>[];
  var id = 0;
  void add(int dia, String hora, TipoCelebracao tipo, List<String> nomes,
      {List<Funcao> funcoes = _todas, Atribuicao atribuicao = Atribuicao.leitores, String? texto}) {
    id++;
    cels.add(Celebracao(
      id: id,
      data: DateTime.utc(2026, 6, dia),
      hora: hora,
      tipo: tipo,
      funcoes: funcoes,
      atribuicao: atribuicao,
      atribuicaoTexto: texto,
    ));
    for (final (i, f) in funcoes.indexed) {
      if (i < nomes.length && nomes[i].isNotEmpty) vagas.add(Vaga(celebracaoId: id, funcao: f, nomeLivre: nomes[i]));
    }
  }

  const dom = TipoCelebracao.domingo;
  const qui = TipoCelebracao.quinta;
  add(4, '19:00', qui, ['Luiz do Vale', 'Eva', 'Leidiane', 'Graciana']);
  add(7, '07:00', dom, ['Laude', 'Dona Isa', 'Maria Cida', 'Luiz Fernando']);
  add(7, '09:00', dom, ['Drica', 'Karol', 'Elaine', 'Valdeir']);
  add(7, '18:00', dom, ['Leonilda', 'Eliane', 'Mary', 'Maria José'],
      atribuicao: Atribuicao.pastoral, texto: pastoralTercoMulheres);
  add(10, '19:30', TipoCelebracao.especial, [],
      atribuicao: Atribuicao.comunidade, texto: 'Comunidades Divino Espirito Santo e São Judas Tadeu');
  add(11, '19:30', TipoCelebracao.especial, [],
      atribuicao: Atribuicao.comunidade, texto: 'Comunidades São Francisco de Assis e Nsa. Sra. Aparecida');
  add(12, '19:30', TipoCelebracao.especial, [],
      atribuicao: Atribuicao.comunidade, texto: 'Pastoral Apostolado da Oração');
  add(13, '08:30', TipoCelebracao.festa, ['Juliana', 'Penha', 'Cicero'], funcoes: _semSegunda);
  add(13, '18:00', TipoCelebracao.festa, ['Luiz Battistini', 'Beatriz', 'Marcos'], funcoes: _semSegunda);
  add(14, '07:00', dom, ['João Bosco', 'Sr Luisinho', 'Luciano', 'Cristiane']);
  add(14, '09:00', dom, ['Luiz do Vale', 'Beto', 'Erivaldo', 'Claudionor'],
      atribuicao: Atribuicao.pastoral, texto: pastoralTercoHomens);
  add(14, '18:00', dom, ['Paulinha', 'Sr Adão', 'Leticia', 'Carla']);
  add(18, '19:30', qui, ['Antonio Aureliano', 'Matheus', 'Maria Antonia'], funcoes: _semSegunda);
  add(21, '07:00', dom, ['Silmara', 'Luiz Sampaio', 'Rosa', 'Tita']);
  add(21, '09:00', dom, ['Helo', 'Luciene', 'Marcia', 'Juliana Araujo']);
  add(21, '18:00', dom, ['Débora', 'Claudiana', 'Marilia Miranda', 'Matheus Miranda']);
  add(25, '19:30', qui, ['Marlene', 'Sandra', 'Marcio'], funcoes: _semSegunda);
  add(28, '07:00', dom, ['Ramaiana', 'Valdenir', 'Maria José Pereira', 'Adriana']);
  add(28, '09:00', dom, ['Bia', 'Selma', 'Camila', 'Clelio']);
  add(28, '18:00', dom, ['Camila Leal', 'Lucas', 'Rose', 'Jennifer']);

  return MesEscala(
    ano: 2026,
    mes: 6,
    publicado: true,
    seed: 0,
    pastorais: null,
    celebracoes: cels,
    vagas: vagas,
  );
}

Future<void> _carregarFonte() async {
  final loader = FontLoader('Roboto')
    ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _carregarFonte();
    goldenFileComparator = _ComparadorTolerante(Uri.parse('test/ui/exportacao_golden_test.dart'));
  });

  test('comunidades seguidas ficam no mesmo grupo', () {
    final grupos = gruposDaEscala(junho2026().celebracoes);
    expect(grupos.map((g) => g.map((c) => c.data.day).toList()), [
      [4],
      [7, 7, 7],
      [10, 11, 12],
      [13, 13],
      [14, 14, 14],
      [18],
      [21, 21, 21],
      [25],
      [28, 28, 28],
    ]);
  });

  testWidgets('tabela de exportação de junho/2026', (tester) async {
    final mes = junho2026();
    final tamanho = TabelaExportacao.tamanho(mes);
    tester.view.physicalSize = tamanho * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: RepaintBoundary(child: TabelaExportacao(mes: mes, nomes: const {})),
      ),
    ));
    expect(tamanho.width * 2, greaterThanOrEqualTo(1240));
    // A fonte é rasterizada de forma diferente em cada sistema: uma referência por SO
    // (a do Linux, usada no CI, é gerada pelo workflow "Atualizar goldens").
    await expectLater(
      find.byType(TabelaExportacao),
      matchesGoldenFile('goldens/${Platform.operatingSystem}/escala_junho_2026.png'),
    );
  });
}
