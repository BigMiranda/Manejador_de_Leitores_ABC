import 'dart:math';

import 'modelos.dart';
import 'regras_epoca.dart';

enum TipoAviso {
  vagaSemCandidato('Vaga sem candidato'),
  parNaoAtendido('Par não atendido'),
  abaixoIntervalo('Abaixo do intervalo mínimo');

  const TipoAviso(this.rotulo);
  final String rotulo;
}

class Aviso {
  const Aviso(this.tipo, this.mensagem, {this.celebracaoId, this.leitorId});
  final TipoAviso tipo;
  final String mensagem;
  final int? celebracaoId;
  final int? leitorId;

  @override
  String toString() => '${tipo.rotulo}: $mensagem';
}

class ConfigEscala {
  const ConfigEscala({this.intervaloMinimoDias = 28, this.refazerDestravadas = false});
  final int intervaloMinimoDias;

  /// Também refaz as células destravadas que já estão preenchidas.
  final bool refazerDestravadas;
}

class ResultadoEscala {
  const ResultadoEscala(this.vagas, this.avisos);
  final List<Vaga> vagas;
  final List<Aviso> avisos;
}

// Pesos da pontuação, em "dias equivalentes".
const _bonusPreferencia = 30.0;
const _penalidadePrefereNao = 30.0;
const _penalidadeQuintaAsVezes = 21.0;
const _bonusAnimadorPrefere = 14.0;
const _penalidadeAnimadorEmLeitura = 7.0;
const _penalidadeIntervalo = 1000.0;
const _semParticipacao = 3650;
const _jitterMaximo = 4;

String _quando(Celebracao c) =>
    '${c.data.day.toString().padLeft(2, '0')}/${c.data.month.toString().padLeft(2, '0')} ${horaExibicao(c.hora)}';

/// Histórico de participações por leitor (datas só-dia, ordenadas).
class Historico {
  Historico([Map<int, List<DateTime>>? inicial]) {
    inicial?.forEach((id, datas) => _datas[id] = [...datas.map(soDia)]..sort());
  }

  final Map<int, List<DateTime>> _datas = {};

  Map<int, List<DateTime>> get mapa => _datas;

  void adicionar(int leitorId, DateTime data) {
    final l = _datas.putIfAbsent(leitorId, () => []);
    l.add(soDia(data));
    l.sort();
  }

  void remover(int leitorId, DateTime data) => _datas[leitorId]?.remove(soDia(data));

  /// Última participação estritamente antes de [data] (considera a carga manual).
  DateTime? ultimaAntes(Leitor l, DateTime data) {
    DateTime? ultima = l.ultimaParticipacao == null ? null : soDia(l.ultimaParticipacao!);
    if (ultima != null && !ultima.isBefore(data)) ultima = null;
    for (final d in _datas[l.id] ?? const <DateTime>[]) {
      if (d.isBefore(data) && (ultima == null || d.isAfter(ultima))) ultima = d;
    }
    return ultima;
  }

  DateTime? proximaDepois(int leitorId, DateTime data) {
    for (final d in _datas[leitorId] ?? const <DateTime>[]) {
      if (d.isAfter(data)) return d;
    }
    return null;
  }

  /// Menor distância (dias) entre [data] e outra participação em dia diferente.
  int? menorDistancia(Leitor l, DateTime data) {
    int? menor;
    final todas = [...?_datas[l.id], if (l.ultimaParticipacao != null) soDia(l.ultimaParticipacao!)];
    for (final d in todas) {
      final dist = d.difference(data).inDays.abs();
      if (dist == 0) continue;
      if (menor == null || dist < menor) menor = dist;
    }
    return menor;
  }

  int contarEm12Meses(int leitorId, DateTime ate) {
    final de = ate.subtract(const Duration(days: 365));
    return (_datas[leitorId] ?? const <DateTime>[])
        .where((d) => d.isAfter(de) && !d.isAfter(ate))
        .length;
  }
}

/// Motivos que impedem o leitor de assumir a função (vazio = elegível).
///
/// [ocupadosNoDia] são os leitores já escalados no mesmo dia.
List<String> motivosInelegivel(
  Leitor l,
  Celebracao c,
  Funcao funcao, {
  Set<int> ocupadosNoDia = const {},
}) {
  final m = <String>[];
  if (l.excluidoEm != null) m.add('Leitor excluído');
  if (!l.vaiLer) m.add('Não vai ler');
  if (c.atribuicao == Atribuicao.pastoral) {
    if (l.soPastoral == null ||
        normalizarNome(l.soPastoral!) != normalizarNome(c.atribuicaoTexto ?? '')) {
      if (l.soPastoral != null) m.add('Só lê pela pastoral ${l.soPastoral}');
    }
  } else if (l.soPastoral != null) {
    m.add('Só lê pela pastoral ${l.soPastoral}');
  }
  if (avaliar(l, c) == Avaliacao.bloqueado) m.add('Impedimento de época');
  switch (c.tipo) {
    case TipoCelebracao.domingo:
      if (!l.leDomingo) {
        m.add('Não lê de domingo');
      } else if (!l.horariosDomingo.contains(c.hora)) {
        m.add('Não lê às ${horaExibicao(c.hora)}');
      }
    case TipoCelebracao.quinta:
      if (l.leQuinta == LeQuinta.nao) m.add('Não lê de quinta');
    case TipoCelebracao.festa:
    case TipoCelebracao.especial:
      if (!l.leFesta) m.add('Não lê em festa');
  }
  if (ocupadosNoDia.contains(l.id)) m.add('Já escalado neste dia');
  if (funcao == Funcao.animador && l.fazAnimacao == FazAnimacao.nao && c.atribuicao != Atribuicao.pastoral) {
    m.add('Não faz animação');
  }
  return m;
}

class _Candidato {
  _Candidato(this.leitor, this.pontos, this.qtd12m, this.abaixoIntervalo);
  final Leitor leitor;
  final double pontos;
  final int qtd12m;
  final bool abaixoIntervalo;
}

/// Gera (ou completa) a escala de um conjunto de celebrações.
///
/// Função pura e determinística: as mesmas entradas e a mesma [seed]
/// produzem sempre a mesma saída. Nunca altera células travadas nem
/// celebrações de comunidade; nas de pastoral só preenche vagas vazias.
ResultadoEscala gerarEscala({
  required List<Leitor> leitores,
  required List<Celebracao> celebracoes,
  required List<Vaga> vagas,
  Map<int, List<DateTime>> historico = const {},
  ConfigEscala config = const ConfigEscala(),
  int seed = 0,
}) {
  final rng = Random(seed);
  final avisos = <Aviso>[];
  final porId = {for (final l in leitores) l.id: l};
  final cels = [...celebracoes]..sort((a, b) => a.instante.compareTo(b.instante));
  final celPorId = {for (final c in cels) c.id: c};

  // Estado mutável das vagas, indexado por (celebração, função).
  final estado = <(int, Funcao), Vaga>{};
  for (final v in vagas) {
    final c = celPorId[v.celebracaoId];
    var nova = v;
    if (c != null &&
        config.refazerDestravadas &&
        c.atribuicao == Atribuicao.leitores &&
        !v.travada) {
      nova = v.copyWith(leitorId: () => null, nomeLivre: () => null);
    }
    estado[(v.celebracaoId, v.funcao)] = nova;
  }
  for (final c in cels) {
    for (final f in c.funcoes) {
      estado.putIfAbsent((c.id, f), () => Vaga(celebracaoId: c.id, funcao: f));
    }
  }

  // Histórico = passado informado + o que já está preenchido no período.
  final hist = Historico(historico);
  for (final v in estado.values) {
    final c = celPorId[v.celebracaoId];
    if (c != null && v.leitorId != null) hist.adicionar(v.leitorId!, c.data);
  }

  Set<int> ocupadosNoDia(DateTime dia) => {
        for (final v in estado.values)
          if (v.leitorId != null && celPorId[v.celebracaoId]?.data == soDia(dia)) v.leitorId!,
      };

  _Candidato pontuar(Leitor l, Celebracao c, Funcao f) {
    final ultima = hist.ultimaAntes(l, c.data);
    var p = (ultima == null ? _semParticipacao : c.data.difference(ultima).inDays).toDouble();
    switch (avaliar(l, c)) {
      case Avaliacao.bonus:
        p += _bonusPreferencia;
      case Avaliacao.penalidade:
        p -= _penalidadePrefereNao;
      case _:
        break;
    }
    if (c.tipo == TipoCelebracao.quinta && l.leQuinta == LeQuinta.asVezes) p -= _penalidadeQuintaAsVezes;
    if (l.fazAnimacao == FazAnimacao.simPrefere) {
      p += f == Funcao.animador ? _bonusAnimadorPrefere : -_penalidadeAnimadorEmLeitura;
    }
    final dist = hist.menorDistancia(l, c.data);
    final abaixo = dist != null && dist < config.intervaloMinimoDias;
    if (abaixo) p -= _penalidadeIntervalo;
    p += rng.nextInt(_jitterMaximo);
    return _Candidato(l, p, hist.contarEm12Meses(l.id, c.data), abaixo);
  }

  _Candidato? escolher(Iterable<Leitor> pool, Celebracao c, Funcao f) {
    final cands = [for (final l in pool) pontuar(l, c, f)];
    if (cands.isEmpty) return null;
    cands.sort((a, b) {
      final p = b.pontos.compareTo(a.pontos);
      if (p != 0) return p;
      final q = a.qtd12m.compareTo(b.qtd12m);
      if (q != 0) return q;
      return a.leitor.id.compareTo(b.leitor.id);
    });
    return cands.first;
  }

  void atribuir(Celebracao c, Funcao f, _Candidato escolhido) {
    estado[(c.id, f)] = estado[(c.id, f)]!.copyWith(leitorId: () => escolhido.leitor.id, nomeLivre: () => null);
    hist.adicionar(escolhido.leitor.id, c.data);
    if (escolhido.abaixoIntervalo) {
      avisos.add(Aviso(
        TipoAviso.abaixoIntervalo,
        '${escolhido.leitor.nome} em ${_quando(c)}',
        celebracaoId: c.id,
        leitorId: escolhido.leitor.id,
      ));
    }
  }

  for (final c in cels) {
    if (c.atribuicao == Atribuicao.comunidade) continue;
    final funcoes = Funcao.values.where(c.funcoes.contains).toList();
    for (var i = 0; i < funcoes.length; i++) {
      final f = funcoes[i];
      final vaga = estado[(c.id, f)]!;
      if (vaga.travada || !vaga.vazia) continue;
      final ocupados = ocupadosNoDia(c.data);

      if (c.atribuicao == Atribuicao.pastoral) {
        final pool = leitores.where((l) => motivosInelegivel(l, c, f, ocupadosNoDia: ocupados).isEmpty &&
            l.soPastoral != null);
        final e = escolher(pool, c, f);
        if (e != null) atribuir(c, f, e);
        continue;
      }

      var pool = leitores.where((l) => motivosInelegivel(l, c, f, ocupadosNoDia: ocupados).isEmpty).toList();
      if (f == Funcao.animador) {
        final preferem = pool.where((l) => l.fazAnimacao == FazAnimacao.simPrefere).toList();
        if (preferem.isNotEmpty) pool = preferem;
      }
      final e = escolher(pool, c, f);
      if (e == null) {
        avisos.add(Aviso(TipoAviso.vagaSemCandidato, '${f.rotulo} em ${_quando(c)}', celebracaoId: c.id));
        continue;
      }
      atribuir(c, f, e);

      // Par "ler junto": tenta outra função da mesma celebração.
      final parId = e.leitor.parId;
      final par = parId == null ? null : porId[parId];
      if (par == null) continue;
      final jaNaCelebracao = funcoes.any((g) => estado[(c.id, g)]!.leitorId == par.id);
      if (jaNaCelebracao) continue;
      var colocado = false;
      for (final g in funcoes.skip(i + 1)) {
        final vg = estado[(c.id, g)]!;
        if (vg.travada || !vg.vazia) continue;
        if (motivosInelegivel(par, c, g, ocupadosNoDia: ocupadosNoDia(c.data)).isNotEmpty) continue;
        atribuir(c, g, pontuar(par, c, g));
        colocado = true;
        break;
      }
      if (!colocado) {
        avisos.add(Aviso(
          TipoAviso.parNaoAtendido,
          '${e.leitor.nome} sem ${par.nome} em ${_quando(c)}',
          celebracaoId: c.id,
          leitorId: e.leitor.id,
        ));
      }
    }
  }

  final ordem = {for (var i = 0; i < cels.length; i++) cels[i].id: i};
  final saida = estado.values.toList()
    ..sort((a, b) {
      final c = (ordem[a.celebracaoId] ?? 1 << 30).compareTo(ordem[b.celebracaoId] ?? 1 << 30);
      return c != 0 ? c : a.funcao.index.compareTo(b.funcao.index);
    });
  return ResultadoEscala(saida, avisos);
}
