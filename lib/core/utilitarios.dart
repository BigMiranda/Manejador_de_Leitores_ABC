import 'escala.dart';
import 'configuracao.dart';
import 'modelos.dart';

// ---------------------------------------------------------------------------
// Importação de nomes colados
// ---------------------------------------------------------------------------

class PreviaImportacao {
  const PreviaImportacao({required this.novos, required this.jaExistem, required this.repetidosNaLista});
  final List<String> novos;
  final List<String> jaExistem;
  final List<String> repetidosNaLista;

  String get resumo {
    final partes = ['${novos.length} ${novos.length == 1 ? 'novo' : 'novos'}'];
    if (jaExistem.isNotEmpty) partes.add('${jaExistem.length} já ${jaExistem.length == 1 ? 'existe' : 'existem'}');
    if (repetidosNaLista.isNotEmpty) partes.add('${repetidosNaLista.length} repetidos na lista');
    return partes.join(', ');
  }
}

final _marcador = RegExp(r'^\s*(?:\d+\s*[.)\-–:]\s*|[-•*–·]\s*)');

String limparLinhaImportacao(String linha) =>
    linha.replaceFirst(_marcador, '').replaceAll(RegExp(r'\s+'), ' ').trim();

PreviaImportacao analisarImportacao(String texto, Iterable<String> existentes) {
  final jaCadastrados = existentes.map(normalizarNome).toSet();
  final vistos = <String>{};
  final novos = <String>[];
  final jaExistem = <String>[];
  final repetidos = <String>[];
  for (final bruta in texto.split(RegExp(r'\r?\n'))) {
    final nome = limparLinhaImportacao(bruta);
    if (nome.isEmpty) continue;
    final chave = normalizarNome(nome);
    if (vistos.contains(chave)) {
      repetidos.add(nome);
      continue;
    }
    vistos.add(chave);
    (jaCadastrados.contains(chave) ? jaExistem : novos).add(nome);
  }
  return PreviaImportacao(novos: novos, jaExistem: jaExistem, repetidosNaLista: repetidos);
}

// ---------------------------------------------------------------------------
// Retenção de backups
// ---------------------------------------------------------------------------

class InfoBackup {
  const InfoBackup(this.id, this.criadoEm);
  final String id;
  final DateTime criadoEm;
}

class PlanoRetencao {
  const PlanoRetencao({required this.mensais, required this.apagar});
  final Set<String> mensais;
  final Set<String> apagar;
}

/// O último backup de cada mês é "mensal" e fica para sempre; os demais
/// ("semanais") são apagados quando passam de 3 meses.
PlanoRetencao planejarRetencao(List<InfoBackup> backups, DateTime agora) {
  final ultimoDoMes = <(int, int), InfoBackup>{};
  for (final b in backups) {
    final k = (b.criadoEm.year, b.criadoEm.month);
    final atual = ultimoDoMes[k];
    if (atual == null || b.criadoEm.isAfter(atual.criadoEm)) ultimoDoMes[k] = b;
  }
  final mensais = ultimoDoMes.values.map((b) => b.id).toSet();
  final limite = DateTime(agora.year, agora.month - 3, agora.day, agora.hour, agora.minute);
  final apagar = {
    for (final b in backups)
      if (!mensais.contains(b.id) && b.criadoEm.isBefore(limite)) b.id,
  };
  return PlanoRetencao(mensais: mensais, apagar: apagar);
}

// ---------------------------------------------------------------------------
// Estatísticas
// ---------------------------------------------------------------------------

class EstatisticaLeitor {
  const EstatisticaLeitor(this.leitor, this.ultima, this.proxima, this.qtd12m);
  final Leitor leitor;
  final DateTime? ultima;
  final DateTime? proxima;
  final int qtd12m;
}

class Estatisticas {
  const Estatisticas({
    required this.vagas,
    required this.elegiveis,
    required this.intervaloMedioMeses,
    required this.media12m,
    required this.porLeitor,
  });

  /// Vagas preenchíveis pelo rodízio geral no mês.
  final int vagas;
  final int elegiveis;

  /// "Cada leitor lê a cada ~X meses".
  final double intervaloMedioMeses;
  final double media12m;
  final List<EstatisticaLeitor> porLeitor;

  bool muitoAcima(EstatisticaLeitor e) => media12m > 0 && e.qtd12m > media12m * 1.5;
  bool muitoAbaixo(EstatisticaLeitor e) => media12m > 0 && e.qtd12m < media12m * 0.5;
}

int contarVagasRodizio(List<Celebracao> celebracoes) => celebracoes
    .where((c) => c.atribuicao == Atribuicao.leitores)
    .fold(0, (s, c) => s + c.funcoes.length);

/// [historico] contém todas as participações conhecidas (inclusive futuras,
/// para calcular a "próxima"). [referencia] é o dia de hoje.
Estatisticas calcularEstatisticas({
  required List<Leitor> leitores,
  required List<Celebracao> celebracoesDoMes,
  required Map<int, List<DateTime>> historico,
  required DateTime referencia,
}) {
  final hoje = soDia(referencia);
  final hist = Historico(historico);
  final vagas = contarVagasRodizio(celebracoesDoMes);
  final elegiveis = leitores.where((l) => l.doRodizioGeral).length;
  final porLeitor = [
    for (final l in leitores.where((l) => l.vaiLer))
      EstatisticaLeitor(
        l,
        hist.ultimaAntes(l, hoje.add(const Duration(days: 1))),
        hist.proximaDepois(l.id, hoje),
        hist.contarEm12Meses(l.id, hoje),
      ),
  ]..sort((a, b) => normalizarNome(a.leitor.nome).compareTo(normalizarNome(b.leitor.nome)));
  final geral = porLeitor.where((e) => e.leitor.doRodizioGeral).toList();
  final media = geral.isEmpty ? 0.0 : geral.fold(0, (s, e) => s + e.qtd12m) / geral.length;
  return Estatisticas(
    vagas: vagas,
    elegiveis: elegiveis,
    intervaloMedioMeses: vagas == 0 ? 0 : elegiveis / vagas,
    media12m: media,
    porLeitor: porLeitor,
  );
}

/// Simula os próximos [meses] meses (sem salvar) e devolve quantas vezes
/// cada leitor seria escalado.
Map<int, int> simularMeses({
  required List<Leitor> leitores,
  required Configuracao config,
  required Map<int, List<DateTime>> historico,
  required int ano,
  required int mes,
  int meses = 12,
  int seed = 0,
}) {
  final hist = {for (final e in historico.entries) e.key: [...e.value]};
  final contagem = <int, int>{};
  for (var i = 0; i < meses; i++) {
    final alvo = DateTime.utc(ano, mes + i, 1);
    final cels = gerarCelebracoesDoMes(alvo.year, alvo.month, config);
    final r = gerarEscala(
      leitores: leitores,
      celebracoes: cels,
      vagas: const [],
      historico: hist,
      config: ConfigEscala(intervaloMinimoDias: config.intervaloMinimoSemanas * 7),
      seed: seed + i,
    );
    final porId = {for (final c in cels) c.id: c};
    for (final v in r.vagas) {
      if (v.leitorId == null) continue;
      contagem[v.leitorId!] = (contagem[v.leitorId!] ?? 0) + 1;
      hist.putIfAbsent(v.leitorId!, () => []).add(porId[v.celebracaoId]!.data);
    }
  }
  return contagem;
}
