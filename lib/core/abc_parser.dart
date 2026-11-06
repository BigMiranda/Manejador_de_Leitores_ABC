import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'modelos.dart';

/// Uma edição do ABC Litúrgico (folheto da missa).
class EdicaoAbc {
  const EdicaoAbc({required this.nome, required this.data, required this.pdfUrl, this.folhetoUrl});
  final String nome;
  final DateTime data;
  final String pdfUrl;
  final String? folhetoUrl;

  @override
  String toString() => '${dataIso(data)} $nome $pdfUrl';
}

const _meses = {
  'janeiro': 1,
  'fevereiro': 2,
  'março': 3,
  'marco': 3,
  'abril': 4,
  'maio': 5,
  'junho': 6,
  'julho': 7,
  'agosto': 8,
  'setembro': 9,
  'outubro': 10,
  'novembro': 11,
  'dezembro': 12,
};

final _reData = RegExp(
  r'(\d{1,2})\s+de\s+(janeiro|fevereiro|março|marco|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro)\s+de\s+(\d{4})',
  caseSensitive: false,
);

/// Converte "15 de novembro de 2026" em data (só dia).
DateTime? parseDataExtenso(String texto) {
  final m = _reData.firstMatch(texto);
  if (m == null) return null;
  return DateTime.utc(int.parse(m.group(3)!), _meses[m.group(2)!.toLowerCase()]!, int.parse(m.group(1)!));
}

bool _ehPdf(String href) => RegExp(r'\.pdf($|[?#])', caseSensitive: false).hasMatch(href);

List<String> _textos(Element e) {
  final out = <String>[];
  void visitar(Node n) {
    if (n is Text) {
      final t = n.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (t.isNotEmpty) out.add(t);
    }
    for (final c in n.nodes) {
      visitar(c);
    }
  }

  visitar(e);
  return out;
}

int _maiusculas(String s) => s.split('').where((c) => c != c.toLowerCase()).length;

/// Extrai as edições (nome, data e PDF) da página de listagem do ABC Litúrgico.
///
/// Robusto a mudanças de layout: parte de cada link `.pdf` e sobe na árvore
/// até achar o bloco que também contém a data por extenso.
List<EdicaoAbc> parseAbcLiturgico(String html) {
  final doc = html_parser.parse(html);
  final vistos = <String>{};
  final out = <EdicaoAbc>[];
  for (final a in doc.querySelectorAll('a[href]')) {
    final href = a.attributes['href']!.trim();
    if (!_ehPdf(href) || vistos.contains(href)) continue;

    Element? bloco = a.parent;
    DateTime? data;
    for (var nivel = 0; bloco != null && nivel < 12; nivel++, bloco = bloco.parent) {
      final pdfsNoBloco = bloco
          .querySelectorAll('a[href]')
          .map((x) => x.attributes['href']!.trim())
          .where(_ehPdf)
          .toSet();
      if (pdfsNoBloco.length > 1) {
        bloco = null;
        break;
      }
      data = parseDataExtenso(bloco.text);
      if (data != null) break;
    }
    if (bloco == null || data == null) continue;

    final candidatos = _textos(bloco).where((t) {
      final l = t.toLowerCase();
      return t.length > 3 && !_reData.hasMatch(t) && !l.endsWith('.pdf') && l != 'folheto';
    }).toList()
      ..sort((x, y) => _maiusculas(y).compareTo(_maiusculas(x)));
    if (candidatos.isEmpty) continue;

    String? folheto;
    for (final link in bloco.querySelectorAll('a[href]')) {
      if (link.text.trim().toLowerCase() == 'folheto') folheto = link.attributes['href'];
    }

    vistos.add(href);
    out.add(EdicaoAbc(nome: candidatos.first, data: data, pdfUrl: href, folhetoUrl: folheto));
  }
  return out;
}

/// Índice data → edição. O site tem rótulos errados, por isso a
/// associação com a celebração é SEMPRE pela data.
Map<DateTime, EdicaoAbc> indexarPorData(List<EdicaoAbc> edicoes) {
  final m = <DateTime, EdicaoAbc>{};
  for (final e in edicoes) {
    m.putIfAbsent(soDia(e.data), () => e);
  }
  return m;
}
