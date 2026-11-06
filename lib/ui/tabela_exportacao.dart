import 'package:flutter/material.dart';

import '../core/modelos.dart';
import '../data/repositorio.dart';

const mesesExtenso = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

String dataBr(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Agrupa as celebrações por dia; dias seguidos só de comunidade ficam juntos.
List<List<Celebracao>> gruposDaEscala(List<Celebracao> celebracoes) {
  final ordenadas = [...celebracoes]..sort((a, b) => a.instante.compareTo(b.instante));
  final grupos = <List<Celebracao>>[];
  bool soComunidade(List<Celebracao> g) => g.every((c) => c.atribuicao == Atribuicao.comunidade);
  for (final c in ordenadas) {
    if (grupos.isNotEmpty) {
      final ultimo = grupos.last;
      final mesmoDia = ultimo.last.data == c.data;
      final comunidadesSeguidas = soComunidade(ultimo) &&
          c.atribuicao == Atribuicao.comunidade &&
          c.data.difference(ultimo.last.data).inDays <= 1;
      if (mesmoDia || comunidadesSeguidas) {
        ultimo.add(c);
        continue;
      }
    }
    grupos.add([c]);
  }
  return grupos;
}

/// Tabela da escala no layout da paróquia, usada na exportação PNG/PDF.
///
/// Todas as linhas têm altura fixa, então o tamanho total é conhecido antes
/// de desenhar ([tamanho]).
class TabelaExportacao extends StatelessWidget {
  const TabelaExportacao({super.key, required this.mes, required this.nomes});

  final MesEscala mes;

  /// Nome de cada leitor por id.
  final Map<int, String> nomes;

  static const largura = 800.0;
  static const _margem = 24.0;
  static const _alturaLinha = 22.0;
  static const _larguras = [0.15, 0.10, 0.20, 0.19, 0.18, 0.18];
  static const _amarelo = Color(0xFFFFFF00);
  static const _vermelho = Color(0xFFD00000);
  static const _fonte = 'Roboto';

  /// Celebração com 3ª leitura/epístola (Vigília Pascal) ocupa uma linha a mais.
  static bool temLinhaExtra(Celebracao c) =>
      c.atribuicao != Atribuicao.comunidade && c.funcoes.any((f) => f.extra);

  static int _linhas(MesEscala mes) {
    final grupos = gruposDaEscala(mes.celebracoes);
    final extras = mes.celebracoes.where(temLinhaExtra).length;
    // título + cabeçalho + (branco + linhas) por grupo + extras + branco final + rodapé
    return 2 + grupos.fold<int>(0, (s, g) => s + 1 + g.length) + extras + 2;
  }

  /// +1 px para as bordas esquerda e superior da tabela.
  static Size tamanho(MesEscala mes) => Size(largura, _margem * 2 + _linhas(mes) * _alturaLinha + 1);

  double _w(int i) => (largura - _margem * 2 - 1) * _larguras[i];
  double _wDe(int de, int ate) => [for (var i = de; i <= ate; i++) _w(i)].fold(0, (a, b) => a + b);

  TextStyle _estilo({bool negrito = false, Color cor = Colors.black, double tamanho = 12.5}) => TextStyle(
        fontFamily: _fonte,
        fontSize: tamanho,
        fontWeight: negrito ? FontWeight.w700 : FontWeight.w400,
        color: cor,
        height: 1.1,
      );

  Widget _celula(
    double largura,
    String texto, {
    TextStyle? estilo,
    Color? fundo,
    bool destacarTexto = false,
  }) {
    final t = Text(
      texto,
      maxLines: 1,
      softWrap: false,
      style: estilo ?? _estilo(),
      textAlign: TextAlign.center,
    );
    return Container(
      width: largura,
      height: _alturaLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(width: 0.6),
          bottom: BorderSide(width: 0.6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      alignment: Alignment.center,
      child: texto.isEmpty
          ? null
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: destacarTexto || fundo != null
                  ? Container(color: fundo ?? _amarelo, padding: const EdgeInsets.symmetric(horizontal: 1), child: t)
                  : t,
            ),
    );
  }

  String _nome(Vaga? v) {
    if (v == null) return '';
    if (v.leitorId != null) return nomes[v.leitorId] ?? v.nomeLivre ?? '';
    return v.nomeLivre ?? '';
  }

  Widget _linhaCelebracao(Celebracao c) {
    final pastoral = c.atribuicao == Atribuicao.pastoral;
    if (c.atribuicao == Atribuicao.comunidade) {
      final vermelho = _estilo(negrito: true, cor: _vermelho);
      return Row(children: [
        _celula(_w(0), dataBr(c.data), estilo: vermelho),
        _celula(_w(1), c.hora, estilo: vermelho),
        _celula(_wDe(2, 5), c.atribuicaoTexto ?? '', estilo: vermelho),
      ]);
    }
    // Festas em sábado com data em negrito.
    final destaqueData = (c.tipo == TipoCelebracao.festa || c.tipo == TipoCelebracao.especial) &&
        c.data.weekday == DateTime.saturday;
    final funcoes = [Funcao.animador, Funcao.leitura1, Funcao.leitura2, Funcao.preces];
    final principal = Row(children: [
      _celula(_w(0), dataBr(c.data), estilo: _estilo(negrito: destaqueData)),
      _celula(_w(1), c.hora, estilo: _estilo(negrito: destaqueData), destacarTexto: pastoral),
      for (var i = 0; i < funcoes.length; i++)
        _celula(
          _w(i + 2),
          c.funcoes.contains(funcoes[i]) ? _nome(mes.vaga(c.id, funcoes[i])) : '',
          destacarTexto: pastoral,
        ),
    ]);
    if (!temLinhaExtra(c)) return principal;
    String extra(Funcao f, String rotulo) {
      if (!c.funcoes.contains(f)) return '';
      final n = _nome(mes.vaga(c.id, f));
      return n.isEmpty ? '$rotulo:' : '$rotulo: $n';
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      principal,
      Row(children: [
        _celula(_w(0), ''),
        _celula(_w(1), ''),
        _celula(_w(2), ''),
        _celula(_w(3), extra(Funcao.leitura3, '3ª'), destacarTexto: pastoral),
        _celula(_w(4), extra(Funcao.epistola, 'Epístola'), destacarTexto: pastoral),
        _celula(_w(5), ''),
      ]),
    ]);
  }

  Widget _linhaVazia() => Row(children: [for (var i = 0; i < 6; i++) _celula(_w(i), '')]);

  @override
  Widget build(BuildContext context) {
    final grupos = gruposDaEscala(mes.celebracoes);
    final titulo = 'ESCALA DOS LEITORES — MÊS DE ${mesesExtenso[mes.mes - 1].toUpperCase()}';
    final rodape = Text.rich(
      TextSpan(style: _estilo(tamanho: 12), children: [
        const TextSpan(text: 'OBSERVAÇÃO: ** '),
        TextSpan(text: 'Os dias que estão em ', style: _estilo(negrito: true, tamanho: 12)),
        TextSpan(
          text: ' amarelo ',
          style: _estilo(negrito: true, tamanho: 12).copyWith(backgroundColor: _amarelo),
        ),
        TextSpan(text: " são 'Pastorais' que proclamam as leituras.", style: _estilo(negrito: true, tamanho: 12)),
      ]),
      maxLines: 1,
    );

    return Container(
      color: Colors.white,
      width: tamanho(mes).width,
      height: tamanho(mes).height,
      padding: const EdgeInsets.all(_margem),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(width: 0.6), top: BorderSide(width: 0.6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [_celula(_wDe(0, 5), titulo, estilo: _estilo(negrito: true))]),
            Row(children: [
              _celula(_w(0), 'DATA', estilo: _estilo(negrito: true)),
              _celula(_w(1), 'HORÁRIO', estilo: _estilo(negrito: true)),
              for (final (i, f) in [Funcao.animador, Funcao.leitura1, Funcao.leitura2, Funcao.preces].indexed)
                _celula(_w(i + 2), f.cabecalho, estilo: _estilo(negrito: true)),
            ]),
            for (final g in grupos) ...[
              _linhaVazia(),
              for (final c in g) _linhaCelebracao(c),
            ],
            _linhaVazia(),
            Container(
              width: _wDe(0, 5),
              height: _alturaLinha,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(width: 0.6), bottom: BorderSide(width: 0.6)),
              ),
              alignment: Alignment.center,
              child: FittedBox(fit: BoxFit.scaleDown, child: rodape),
            ),
          ],
        ),
      ),
    );
  }
}
