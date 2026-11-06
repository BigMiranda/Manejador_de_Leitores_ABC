import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/core/abc_parser.dart';

void main() {
  final html = File('test/fixtures/abc_liturgico.html').readAsStringSync();

  test('converte data por extenso', () {
    expect(parseDataExtenso('15 de novembro de 2026'), DateTime.utc(2026, 11, 15));
    expect(parseDataExtenso('1 de Março de 2027'), DateTime.utc(2027, 3, 1));
    expect(parseDataExtenso('sem data'), isNull);
  });

  test('extrai as 24 edições da página salva', () {
    final edicoes = parseAbcLiturgico(html);
    expect(edicoes, hasLength(24));

    final primeira = edicoes.first;
    expect(primeira.nome, '4º DOMINGO DO ADVENTO');
    expect(primeira.data, DateTime.utc(2026, 12, 20));
    expect(primeira.pdfUrl, 'https://diocesesa.org.br/wp-content/uploads/2026/10/2818-4-Domingo-do-Advento.pdf');
    expect(primeira.folhetoUrl, 'https://diocesesa.org.br/2818-4-domingo-do-advento/');

    final porData = indexarPorData(edicoes);
    expect(porData[DateTime.utc(2026, 11, 22)]!.nome, 'NOSSO SENHOR JESUS CRISTO, REI DO UNIVERSO');
    expect(porData[DateTime.utc(2026, 11, 22)]!.pdfUrl, endsWith('/2814-Cristo-Rei.pdf'));
    expect(porData[DateTime.utc(2026, 11, 1)]!.nome, 'SOLENIDADE DE TODOS OS SANTOS');
    expect(porData[DateTime.utc(2026, 11, 2)]!.nome, 'COMEMORAÇÃO DE TODOS OS FIÉIS DEFUNTOS');
    expect(porData[DateTime.utc(2026, 10, 12)]!.nome, contains('APARECIDA'));
  });

  test('associa pela data mesmo com rótulo repetido no site', () {
    final porData = indexarPorData(parseAbcLiturgico(html));
    // O site rotula 11/10 e 18/10 como "28º DOMINGO": cada data tem seu PDF.
    final a = porData[DateTime.utc(2026, 10, 11)]!;
    final b = porData[DateTime.utc(2026, 10, 18)]!;
    expect(a.nome, b.nome);
    expect(a.pdfUrl, isNot(b.pdfUrl));
  });

  test('aceita layout diferente (fallback genérico)', () {
    const outro = '''
<ul>
  <li><h3>SOLENIDADE DE TODOS OS SANTOS</h3><p>1 de novembro de 2026</p>
      <a href="https://exemplo.org/2810-Todos-os-Santos.pdf">baixar</a></li>
  <li><span>Natal do Senhor</span><em>25 de dezembro de 2026</em>
      <a href="/x/2820-natal.PDF">PDF</a></li>
</ul>''';
    final e = parseAbcLiturgico(outro);
    expect(e, hasLength(2));
    expect(e[0].nome, 'SOLENIDADE DE TODOS OS SANTOS');
    expect(e[0].data, DateTime.utc(2026, 11, 1));
    expect(e[1].data, DateTime.utc(2026, 12, 25));
  });
}
