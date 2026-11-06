import 'configuracao.dart';
import 'modelos.dart';

/// Uma missa do dia com os nomes já resolvidos (null = vaga vazia).
class MissaDoDia {
  const MissaDoDia(this.celebracao, this.nomes);
  final Celebracao celebracao;
  final Map<Funcao, String?> nomes;
}

const _diasSemana = [
  'segunda-feira',
  'terça-feira',
  'quarta-feira',
  'quinta-feira',
  'sexta-feira',
  'sábado',
  'domingo',
];

String diaSemanaExtenso(DateTime d) => _diasSemana[d.weekday - 1];

String saudacao(DateTime agora) {
  if (agora.hour < 12) return 'Bom dia';
  if (agora.hour < 18) return 'Boa tarde';
  return 'Boa noite';
}

String dataCurta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${(d.year % 100).toString().padLeft(2, '0')}';

const aDefinir = '(a definir)';

/// Substitui os placeholders. Valor `null` remove a linha do placeholder e
/// a linha de rótulo imediatamente anterior (ex.: "Segunda leitura").
String preencherModelo(String modelo, Map<String, String?> valores) {
  final saida = <String>[];
  for (final linha in modelo.split('\n')) {
    final omitir = valores.entries.any((e) => e.value == null && linha.contains('{${e.key}}'));
    if (omitir) {
      if (saida.isNotEmpty && saida.last.isNotEmpty && !saida.last.contains('{')) saida.removeLast();
      continue;
    }
    saida.add(linha);
  }
  var texto = saida.join('\n');
  valores.forEach((k, v) {
    if (v != null) texto = texto.replaceAll('{$k}', v);
  });
  return texto;
}

bool _ehDiaDeQuinta(List<MissaDoDia> missas) =>
    missas.every((m) => m.celebracao.tipo == TipoCelebracao.quinta);

// Palavras que continuam com maiúscula ao passar o nome litúrgico para minúsculas.
const _maiusculas = {
  'deus', 'senhor', 'jesus', 'cristo', 'maria', 'josé', 'joão', 'batista', 'pedro', 'paulo',
  'aparecida', 'espírito', 'rei', 'universo', 'imaculada', 'conceição', 'natal', 'páscoa',
  'pentecostes', 'trindade', 'corpus', 'christi', 'sagrado', 'coração', 'advento', 'quaresma',
};

/// "32º DOMINGO DO TEMPO COMUM" → "32º domingo do tempo comum";
/// "NOSSO SENHOR JESUS CRISTO, REI DO UNIVERSO" → "Nosso Senhor Jesus Cristo, Rei do Universo".
String nomeLiturgicoLegivel(String nome) {
  final t = nome.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (t != t.toUpperCase()) return t; // já veio em caixa mista: respeita
  final palavras = t.toLowerCase().split(' ');
  for (var i = 0; i < palavras.length; i++) {
    final p = palavras[i];
    final limpa = p.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');
    final nomeProprio = _maiusculas.contains(limpa) || (limpa == 'santo' && i > 0 && palavras[i - 1].toLowerCase() == 'espírito');
    if (nomeProprio || (i == 0 && RegExp(r'^\p{L}', unicode: true).hasMatch(p))) {
      final k = p.indexOf(RegExp(r'\p{L}', unicode: true));
      palavras[i] = p.substring(0, k) + p[k].toUpperCase() + p.substring(k + 1);
    }
  }
  return palavras.join(' ');
}

/// Nome do arquivo do PDF compartilhado:
/// "Liturgia Missa 08-11-2026 32º domingo do tempo comum.pdf".
/// (O Android não aceita "/" em nome de arquivo.)
String nomeArquivoLiturgia(DateTime dia, String? nomeLiturgico) {
  final data = '${dia.day.toString().padLeft(2, '0')}-${dia.month.toString().padLeft(2, '0')}-${dia.year}';
  final nome = nomeLiturgico == null || nomeLiturgico.trim().isEmpty
      ? ''
      : ' ${nomeLiturgicoLegivel(nomeLiturgico).replaceAll(RegExp(r'[\\/:*?"<>|]'), '-')}';
  return 'Liturgia Missa $data$nome.pdf';
}

/// Se o envio da véspera inclui o PDF da liturgia (domingo e festa).
bool levaPdf(List<Celebracao> celebracoesDoDia) => celebracoesDoDia
    .any((c) => c.tipo == TipoCelebracao.domingo || c.tipo == TipoCelebracao.festa);

String _nome(MissaDoDia m, Funcao f) {
  final n = m.nomes[f];
  return (n == null || n.trim().isEmpty) ? aDefinir : n;
}

/// Monta a mensagem de lembrete enviada na véspera.
String montarMensagem({
  required List<MissaDoDia> missas,
  required ModelosMensagem modelos,
  required DateTime agora,
  bool escalaAtualizada = false,
}) {
  final ordenadas = [...missas]..sort((a, b) => a.celebracao.instante.compareTo(b.celebracao.instante));
  final dia = ordenadas.first.celebracao.data;
  final comum = <String, String?>{
    'saudacao': saudacao(agora),
    'diaSemana': diaSemanaExtenso(dia),
    'data': dataCurta(dia),
    'escalaAtualizada': escalaAtualizada ? 'Escala atualizada\n\n' : '',
  };

  if (_ehDiaDeQuinta(ordenadas)) {
    final m = ordenadas.first;
    final c = m.celebracao;
    return preencherModelo(modelos.quinta, {
      ...comum,
      'hora': horaExibicao(c.hora),
      'animador': _nome(m, Funcao.animador),
      'leitura1': _nome(m, Funcao.leitura1),
      'leitura2': c.funcoes.contains(Funcao.leitura2) ? _nome(m, Funcao.leitura2) : null,
      'preces': _nome(m, Funcao.preces),
    });
  }

  final ehDomingo = ordenadas.any((m) => m.celebracao.tipo == TipoCelebracao.domingo);
  final nomeLit = ordenadas
      .map((m) => m.celebracao.nomeLiturgico)
      .firstWhere((n) => n != null && n.trim().isNotEmpty, orElse: () => null);
  final cabecalho = preencherModelo(modelos.domingoCabecalho, {
    ...comum,
    'nomeFesta': (!ehDomingo && nomeLit != null) ? ' – $nomeLit' : '',
  });

  final blocos = <String>[];
  for (final m in ordenadas) {
    final c = m.celebracao;
    final temNomes = c.funcoes.any((f) => (m.nomes[f] ?? '').trim().isNotEmpty);
    if (c.atribuicao != Atribuicao.leitores && !temNomes) {
      blocos.add('Missa das ${horaExibicao(c.hora)}\n\nLeitores: ${c.atribuicaoTexto ?? c.atribuicao.rotulo}');
      continue;
    }
    String? valor(Funcao f) => c.funcoes.contains(f) ? _nome(m, f) : null;
    blocos.add(preencherModelo(modelos.domingoBloco, {
      'hora': horaExibicao(c.hora),
      'animador': valor(Funcao.animador),
      'leitura1': valor(Funcao.leitura1),
      'leitura2': valor(Funcao.leitura2),
      'leitura3': valor(Funcao.leitura3),
      'epistola': valor(Funcao.epistola),
      'preces': valor(Funcao.preces),
    }));
  }
  return '$cabecalho${blocos.join('\n\n')}\n\n${modelos.domingoRodape}';
}
