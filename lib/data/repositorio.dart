import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/configuracao.dart';
import '../core/modelos.dart';
import 'banco.dart';

/// v2: leitores.excluidoEm e meses.versaoCalendario.
const versaoBackup = 2;

/// Versão das festas automáticas aplicada aos meses (ver calendario_liturgico.dart).
const versaoCalendarioAtual = 1;

/// Um mês da escala com suas celebrações e vagas.
class MesEscala {
  const MesEscala({
    required this.ano,
    required this.mes,
    required this.publicado,
    required this.seed,
    required this.pastorais,
    required this.celebracoes,
    required this.vagas,
  });
  final int ano;
  final int mes;
  final bool publicado;
  final int seed;

  /// Sobrescrita das pastorais neste mês (null = padrão das configurações).
  final List<ConfigPastoral>? pastorais;
  final List<Celebracao> celebracoes;
  final List<Vaga> vagas;

  Vaga? vaga(int celebracaoId, Funcao f) {
    for (final v in vagas) {
      if (v.celebracaoId == celebracaoId && v.funcao == f) return v;
    }
    return null;
  }
}

class _Passo {
  _Passo(this.descricao, this.antes, this.depois);
  final String descricao;
  final Map<String, dynamic> antes;
  final Map<String, dynamic> depois;
}

/// Pilha de desfazer/refazer com instantâneos dos dados de leitores e escala.
class PilhaDesfazer {
  static const limite = 50;
  final _desfazer = <_Passo>[];
  final _refazer = <_Passo>[];

  bool get podeDesfazer => _desfazer.isNotEmpty;
  bool get podeRefazer => _refazer.isNotEmpty;
  String? get proximoDesfazer => _desfazer.isEmpty ? null : _desfazer.last.descricao;
  String? get proximoRefazer => _refazer.isEmpty ? null : _refazer.last.descricao;

  void _empilhar(_Passo p) {
    _desfazer.add(p);
    if (_desfazer.length > limite) _desfazer.removeAt(0);
    _refazer.clear();
  }

  void limpar() {
    _desfazer.clear();
    _refazer.clear();
  }
}

String _csv(Iterable<String> xs) => xs.join(',');
List<String> _descsv(String s) => s.isEmpty ? const [] : s.split(',');

class Repositorio {
  Repositorio(this.db);
  final Banco db;
  final pilha = PilhaDesfazer();
  final _mudancas = StreamController<void>.broadcast();

  /// Emite sempre que algo é gravado.
  Stream<void> get mudancas => _mudancas.stream;

  void _mudou() => _mudancas.add(null);

  Future<void> fechar() async {
    await _mudancas.close();
    await db.close();
  }

  // -------------------------------------------------------------------------
  // Conversões
  // -------------------------------------------------------------------------

  Leitor _leitor(LeitorRow r, List<RegraRow> regras) => Leitor(
        id: r.id,
        nome: r.nome,
        vaiLer: r.vaiLer,
        fazAnimacao: FazAnimacao.values.byName(r.fazAnimacao),
        leDomingo: r.leDomingo,
        horariosDomingo: _descsv(r.horariosDomingo).toSet(),
        leQuinta: LeQuinta.values.byName(r.leQuinta),
        leFesta: r.leFesta,
        soPastoral: r.soPastoral,
        regras: [
          for (final g in regras)
            RegraEpoca.fromJson((jsonDecode(g.dados) as Map).cast<String, dynamic>()),
        ],
        parId: r.parId,
        ultimaParticipacao: r.ultimaParticipacao == null ? null : parseDataIso(r.ultimaParticipacao!),
        observacoes: r.observacoes,
        excluidoEm: r.excluidoEm == null ? null : DateTime.tryParse(r.excluidoEm!),
      );

  LeitoresCompanion _leitorCompanion(Leitor l) => LeitoresCompanion(
        nome: Value(l.nome.trim()),
        vaiLer: Value(l.vaiLer),
        fazAnimacao: Value(l.fazAnimacao.name),
        leDomingo: Value(l.leDomingo),
        horariosDomingo: Value(_csv(horariosDomingoPadrao.where(l.horariosDomingo.contains).followedBy(
            l.horariosDomingo.where((h) => !horariosDomingoPadrao.contains(h))))),
        leQuinta: Value(l.leQuinta.name),
        leFesta: Value(l.leFesta),
        soPastoral: Value(l.soPastoral),
        parId: Value(l.parId),
        ultimaParticipacao: Value(l.ultimaParticipacao == null ? null : dataIso(l.ultimaParticipacao!)),
        observacoes: Value(l.observacoes),
      );

  Celebracao _celebracao(CelebracaoRow r) => Celebracao(
        id: r.id,
        data: parseDataIso(r.data),
        hora: r.hora,
        tipo: TipoCelebracao.values.byName(r.tipo),
        funcoes: [for (final f in _descsv(r.funcoes)) Funcao.values.byName(f)],
        nomeLiturgico: r.nomeLiturgico,
        atribuicao: Atribuicao.values.byName(r.atribuicao),
        atribuicaoTexto: r.atribuicaoTexto,
        pdfUrl: r.pdfUrl,
        pdfArquivo: r.pdfArquivo,
        pdfStatus: StatusPdf.values.byName(r.pdfStatus),
      );

  CelebracoesCompanion _celebracaoCompanion(Celebracao c) => CelebracoesCompanion(
        data: Value(dataIso(c.data)),
        hora: Value(c.hora),
        tipo: Value(c.tipo.name),
        nomeLiturgico: Value(c.nomeLiturgico),
        funcoes: Value(_csv(Funcao.values.where(c.funcoes.contains).map((f) => f.name))),
        atribuicao: Value(c.atribuicao.name),
        atribuicaoTexto: Value(c.atribuicaoTexto),
        pdfUrl: Value(c.pdfUrl),
        pdfArquivo: Value(c.pdfArquivo),
        pdfStatus: Value(c.pdfStatus.name),
      );

  Vaga _vaga(VagaRow r) => Vaga(
        celebracaoId: r.celebracaoId,
        funcao: Funcao.values.byName(r.funcao),
        leitorId: r.leitorId,
        nomeLivre: r.nomeLivre,
        travada: r.travada,
      );

  VagasCompanion _vagaCompanion(Vaga v) => VagasCompanion(
        celebracaoId: Value(v.celebracaoId),
        funcao: Value(v.funcao.name),
        leitorId: Value(v.leitorId),
        nomeLivre: Value(v.nomeLivre),
        travada: Value(v.travada),
      );

  // -------------------------------------------------------------------------
  // Instantâneos (desfazer e backup)
  // -------------------------------------------------------------------------

  /// Tabelas cobertas pelo desfazer: leitores e escala.
  static const _tabelasDesfazer = ['leitores', 'regras', 'celebracoes', 'vagas', 'meses'];
  static const _todasTabelas = [..._tabelasDesfazer, 'envios', 'configs'];

  TableInfo<Table, DataClass> _tabela(String nome) => switch (nome) {
        'leitores' => db.leitores,
        'regras' => db.regras,
        'celebracoes' => db.celebracoes,
        'vagas' => db.vagas,
        'meses' => db.meses,
        'envios' => db.envios,
        'configs' => db.configs,
        _ => throw ArgumentError(nome),
      } as TableInfo<Table, DataClass>;

  DataClass _deJson(String tabela, Map<String, dynamic> j) => switch (tabela) {
        'leitores' => LeitorRow.fromJson(j),
        'regras' => RegraRow.fromJson(j),
        'celebracoes' => CelebracaoRow.fromJson(j),
        'vagas' => VagaRow.fromJson(j),
        // Backups v1 não têm versaoCalendario.
        'meses' => MesRow.fromJson({'versaoCalendario': 0, ...j}),
        'envios' => EnvioRow.fromJson(j),
        'configs' => ConfigRow.fromJson(j),
        _ => throw ArgumentError(tabela),
      };

  Future<Map<String, dynamic>> _instantaneo(List<String> tabelas) async {
    final out = <String, dynamic>{};
    for (final t in tabelas) {
      final linhas = await db.select(_tabela(t)).get();
      out[t] = [for (final l in linhas) l.toJson()];
    }
    return out;
  }

  Future<void> _restaurar(Map<String, dynamic> dados, List<String> tabelas) async {
    await db.transaction(() async {
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final t in tabelas.reversed) {
        await db.delete(_tabela(t)).go();
      }
      await db.batch((b) {
        for (final t in tabelas) {
          final linhas = (dados[t] as List?) ?? const [];
          b.insertAll(_tabela(t), [
            for (final l in linhas) _deJson(t, (l as Map).cast<String, dynamic>()) as Insertable<DataClass>,
          ]);
        }
      });
    });
  }

  /// Executa [acao] registrando um passo de desfazer.
  Future<T> _registrar<T>(String descricao, Future<T> Function() acao) async {
    final antes = await _instantaneo(_tabelasDesfazer);
    final r = await db.transaction(acao);
    final depois = await _instantaneo(_tabelasDesfazer);
    pilha._empilhar(_Passo(descricao, antes, depois));
    _mudou();
    return r;
  }

  /// Desfaz o último passo e devolve a descrição (ou null).
  Future<String?> desfazer() async {
    if (!pilha.podeDesfazer) return null;
    final p = pilha._desfazer.removeLast();
    await _restaurar(p.antes, _tabelasDesfazer);
    pilha._refazer.add(p);
    _mudou();
    return p.descricao;
  }

  Future<String?> refazer() async {
    if (!pilha.podeRefazer) return null;
    final p = pilha._refazer.removeLast();
    await _restaurar(p.depois, _tabelasDesfazer);
    pilha._desfazer.add(p);
    _mudou();
    return p.descricao;
  }

  /// Backup completo e versionado.
  Future<Map<String, dynamic>> exportarBackup() async => {
        'app': 'manejador_leitores_abc',
        'versao': versaoBackup,
        'criadoEm': DateTime.now().toIso8601String(),
        'dados': await _instantaneo(_todasTabelas),
      };

  /// Restaura um backup (substitui tudo). Limpa a pilha de desfazer.
  Future<void> restaurarBackup(Map<String, dynamic> backup) async {
    if (backup['app'] != 'manejador_leitores_abc') {
      throw const FormatException('Arquivo não é um backup do Manejador de Leitores.');
    }
    final versao = backup['versao'] as int? ?? 0;
    if (versao > versaoBackup) {
      throw FormatException('Backup de versão mais nova ($versao). Atualize o app.');
    }
    await _restaurar((backup['dados'] as Map).cast<String, dynamic>(), _todasTabelas);
    pilha.limpar();
    _mudou();
  }

  // -------------------------------------------------------------------------
  // Leitores
  // -------------------------------------------------------------------------

  /// Leitores ativos (com [incluirExcluidos], também os excluídos).
  Future<List<Leitor>> leitores({bool incluirExcluidos = false}) async {
    final q = db.select(db.leitores)..orderBy([(t) => OrderingTerm.asc(t.nome.collate(Collate.noCase))]);
    if (!incluirExcluidos) q.where((t) => t.excluidoEm.isNull());
    final linhas = await q.get();
    final regras = await db.select(db.regras).get();
    final porLeitor = <int, List<RegraRow>>{};
    for (final g in regras) {
      porLeitor.putIfAbsent(g.leitorId, () => []).add(g);
    }
    return [for (final r in linhas) _leitor(r, porLeitor[r.id] ?? const [])];
  }

  /// Leitor (ativo ou excluído) com esse nome, ignorando maiúsculas e acentos.
  Future<Leitor?> leitorComNome(String nome, {int? excetoId}) async {
    final alvo = normalizarNome(nome);
    for (final l in await leitores(incluirExcluidos: true)) {
      if (l.id != excetoId && normalizarNome(l.nome) == alvo) return l;
    }
    return null;
  }

  Future<List<Leitor>> leitoresExcluidos() async =>
      (await leitores(incluirExcluidos: true)).where((l) => l.excluidoEm != null).toList()
        ..sort((a, b) => b.excluidoEm!.compareTo(a.excluidoEm!));

  /// Insere (id 0) ou atualiza o leitor, mantendo o par bidirecional.
  Future<int> salvarLeitor(Leitor l) => _registrar(l.id == 0 ? 'Novo leitor' : 'Editar ${l.nome}', () async {
        var id = l.id;
        int? parAntigo;
        if (id == 0) {
          id = await db.into(db.leitores).insert(_leitorCompanion(l));
        } else {
          parAntigo = (await (db.select(db.leitores)..where((t) => t.id.equals(id))).getSingle()).parId;
          await (db.update(db.leitores)..where((t) => t.id.equals(id))).write(_leitorCompanion(l));
        }
        await (db.delete(db.regras)..where((t) => t.leitorId.equals(id))).go();
        for (final r in l.regras) {
          await db.into(db.regras).insert(RegrasCompanion.insert(leitorId: id, dados: jsonEncode(r.toJson())));
        }
        await _ajustarPar(id, parAntigo, l.parId);
        return id;
      });

  Future<void> _ajustarPar(int id, int? antigo, int? novo) async {
    if (antigo == novo) return;
    if (antigo != null) {
      await (db.update(db.leitores)..where((t) => t.id.equals(antigo) & t.parId.equals(id)))
          .write(const LeitoresCompanion(parId: Value(null)));
    }
    if (novo != null) {
      final parceiro = await (db.select(db.leitores)..where((t) => t.id.equals(novo))).getSingleOrNull();
      if (parceiro == null) return;
      final terceiro = parceiro.parId;
      if (terceiro != null && terceiro != id) {
        await (db.update(db.leitores)..where((t) => t.id.equals(terceiro) & t.parId.equals(novo)))
            .write(const LeitoresCompanion(parId: Value(null)));
      }
      await (db.update(db.leitores)..where((t) => t.id.equals(novo))).write(LeitoresCompanion(parId: Value(id)));
    }
  }

  /// Exclusão lógica: o leitor some da lista e da geração. As escalas já
  /// feitas continuam com o nome dele. Quem lia junto com ele perde o par.
  Future<void> excluirLeitores(List<int> ids) =>
      _registrar(ids.length == 1 ? 'Excluir leitor' : 'Excluir ${ids.length} leitores', () async {
        final agora = DateTime.now().toIso8601String();
        await (db.update(db.leitores)..where((t) => t.id.isIn(ids)))
            .write(LeitoresCompanion(excluidoEm: Value(agora)));
        await (db.update(db.leitores)..where((t) => t.parId.isIn(ids) & t.id.isNotIn(ids)))
            .write(const LeitoresCompanion(parId: Value(null)));
      });

  /// Restaura leitores excluídos, refazendo o par se o outro ainda estiver livre.
  Future<void> restaurarLeitores(List<int> ids) =>
      _registrar(ids.length == 1 ? 'Restaurar leitor' : 'Restaurar ${ids.length} leitores', () async {
        await (db.update(db.leitores)..where((t) => t.id.isIn(ids)))
            .write(const LeitoresCompanion(excluidoEm: Value(null)));
        for (final id in ids) {
          final l = await (db.select(db.leitores)..where((t) => t.id.equals(id))).getSingle();
          if (l.parId == null) continue;
          final par = await (db.select(db.leitores)..where((t) => t.id.equals(l.parId!))).getSingleOrNull();
          final livre = par != null && par.excluidoEm == null && (par.parId == null || par.parId == id);
          if (livre) {
            await (db.update(db.leitores)..where((t) => t.id.equals(par.id)))
                .write(LeitoresCompanion(parId: Value(id)));
          } else {
            await (db.update(db.leitores)..where((t) => t.id.equals(id)))
                .write(const LeitoresCompanion(parId: Value(null)));
          }
        }
      });

  /// Grava vários leitores num só passo de desfazer (edição em lote; não mexe no par).
  Future<void> atualizarLeitores(List<Leitor> ls) =>
      _registrar('Editar ${ls.length} leitores', () async {
        for (final l in ls) {
          await (db.update(db.leitores)..where((t) => t.id.equals(l.id)))
              .write(_leitorCompanion(l).copyWith(parId: const Value.absent()));
          await (db.delete(db.regras)..where((t) => t.leitorId.equals(l.id))).go();
          for (final r in l.regras) {
            await db.into(db.regras).insert(RegrasCompanion.insert(leitorId: l.id, dados: jsonEncode(r.toJson())));
          }
        }
      });

  /// Novos leitores com os valores padrão de [Leitor].
  Future<void> importarNomes(List<String> nomes) => _registrar('Importar ${nomes.length} leitores', () async {
        for (final n in nomes) {
          await db.into(db.leitores).insert(_leitorCompanion(Leitor(id: 0, nome: n.trim())));
        }
      });

  // -------------------------------------------------------------------------
  // Meses, celebrações e vagas
  // -------------------------------------------------------------------------

  String _prefixoMes(int ano, int mes) => '${ano.toString().padLeft(4, '0')}-${mes.toString().padLeft(2, '0')}-';

  Future<void> _inserirCelebracao(Celebracao c) async {
    final id = await db.into(db.celebracoes).insert(_celebracaoCompanion(c));
    for (final f in c.funcoes) {
      await db.into(db.vagas).insert(VagasCompanion.insert(celebracaoId: id, funcao: f.name));
    }
  }

  /// Abre o mês, criando domingos, quintas, festas do calendário e vagas na
  /// primeira vez. Rascunhos criados antes das festas automáticas as recebem
  /// uma vez (meses publicados só pelo menu "Incluir festas do calendário").
  Future<MesEscala> abrirMes(int ano, int mes, Configuracao cfg) async {
    var mudou = false;
    await db.transaction(() async {
      final existe = await (db.select(db.meses)..where((t) => t.ano.equals(ano) & t.mes.equals(mes))).getSingleOrNull();
      if (existe == null) {
        mudou = true;
        await db.into(db.meses).insert(MesesCompanion.insert(
              ano: ano,
              mes: mes,
              seed: Value(ano * 100 + mes),
              versaoCalendario: const Value(versaoCalendarioAtual),
            ));
        for (final c in gerarCelebracoesDoMes(ano, mes, cfg)) {
          await _inserirCelebracao(c);
        }
      } else if (existe.versaoCalendario < versaoCalendarioAtual) {
        if (existe.status != 'publicado') mudou = await _incluirFestas(ano, mes, cfg) > 0;
        await (db.update(db.meses)..where((t) => t.ano.equals(ano) & t.mes.equals(mes)))
            .write(const MesesCompanion(versaoCalendario: Value(versaoCalendarioAtual)));
      }
    });
    if (mudou) _mudou();
    return mesEscala(ano, mes);
  }

  /// Acrescenta ao mês as festas do calendário que faltam. Na quinta de festa,
  /// a missa de quinta sai se ainda não tiver ninguém escalado.
  Future<int> _incluirFestas(int ano, int mes, Configuracao cfg) async {
    final atuais = (await (db.select(db.celebracoes)..where((t) => t.data.like('${_prefixoMes(ano, mes)}%'))).get())
        .map(_celebracao)
        .toList();
    final vagas = await vagasDe(atuais.map((c) => c.id));
    var alteracoes = 0;
    for (final nova in gerarCelebracoesDoMes(ano, mes, cfg)) {
      if (nova.tipo == TipoCelebracao.domingo && nova.nomeLiturgico != null) {
        for (final c in atuais.where((c) => c.data == nova.data && c.hora == nova.hora && c.nomeLiturgico == null)) {
          await (db.update(db.celebracoes)..where((t) => t.id.equals(c.id)))
              .write(CelebracoesCompanion(nomeLiturgico: Value(nova.nomeLiturgico)));
          alteracoes++;
        }
        continue;
      }
      if (nova.tipo != TipoCelebracao.festa) continue;
      if (atuais.any((c) => c.data == nova.data && c.hora == nova.hora)) continue;
      if (nova.data.weekday == DateTime.thursday) {
        for (final q in atuais.where((c) => c.data == nova.data && c.tipo == TipoCelebracao.quinta)) {
          final vazia = vagas.where((v) => v.celebracaoId == q.id).every((v) => v.vazia && !v.travada);
          if (vazia) await (db.delete(db.celebracoes)..where((t) => t.id.equals(q.id))).go();
        }
      }
      await _inserirCelebracao(nova);
      atuais.add(nova);
      alteracoes++;
    }
    return alteracoes;
  }

  /// Menu "Incluir festas do calendário" (vale também para meses publicados).
  Future<int> incluirFestasDoCalendario(int ano, int mes, Configuracao cfg) =>
      _registrar('Incluir festas do calendário', () => _incluirFestas(ano, mes, cfg));

  Future<MesEscala> mesEscala(int ano, int mes) async {
    final m = await (db.select(db.meses)..where((t) => t.ano.equals(ano) & t.mes.equals(mes))).getSingleOrNull();
    final cels = await (db.select(db.celebracoes)
          ..where((t) => t.data.like('${_prefixoMes(ano, mes)}%'))
          ..orderBy([(t) => OrderingTerm.asc(t.data), (t) => OrderingTerm.asc(t.hora)]))
        .get();
    final ids = cels.map((c) => c.id).toList();
    final vagas = ids.isEmpty ? <VagaRow>[] : await (db.select(db.vagas)..where((t) => t.celebracaoId.isIn(ids))).get();
    return MesEscala(
      ano: ano,
      mes: mes,
      publicado: m?.status == 'publicado',
      seed: m?.seed ?? ano * 100 + mes,
      pastorais: m?.pastorais == null
          ? null
          : [
              for (final p in jsonDecode(m!.pastorais!) as List)
                ConfigPastoral.fromJson((p as Map).cast<String, dynamic>()),
            ],
      celebracoes: cels.map(_celebracao).toList(),
      vagas: vagas.map(_vaga).toList(),
    );
  }

  Future<List<(int, int, bool)>> mesesCadastrados() async {
    final ms = await (db.select(db.meses)..orderBy([(t) => OrderingTerm.asc(t.ano), (t) => OrderingTerm.asc(t.mes)])).get();
    return [for (final m in ms) (m.ano, m.mes, m.status == 'publicado')];
  }

  Future<List<Celebracao>> celebracoesEntre(DateTime de, DateTime ate) async {
    final linhas = await (db.select(db.celebracoes)
          ..where((t) => t.data.isBetweenValues(dataIso(de), dataIso(ate)))
          ..orderBy([(t) => OrderingTerm.asc(t.data), (t) => OrderingTerm.asc(t.hora)]))
        .get();
    return linhas.map(_celebracao).toList();
  }

  Future<List<Vaga>> vagasDe(Iterable<int> celebracaoIds) async {
    final ids = celebracaoIds.toList();
    if (ids.isEmpty) return const [];
    return (await (db.select(db.vagas)..where((t) => t.celebracaoId.isIn(ids))).get()).map(_vaga).toList();
  }

  /// Participações por leitor. Com [antesDe], só as anteriores a essa data.
  Future<Map<int, List<DateTime>>> historico({DateTime? antesDe}) async {
    final q = db.select(db.vagas).join([
      innerJoin(db.celebracoes, db.celebracoes.id.equalsExp(db.vagas.celebracaoId)),
    ])
      ..where(db.vagas.leitorId.isNotNull());
    if (antesDe != null) q.where(db.celebracoes.data.isSmallerThanValue(dataIso(antesDe)));
    final out = <int, List<DateTime>>{};
    for (final linha in await q.get()) {
      final v = linha.readTable(db.vagas);
      final c = linha.readTable(db.celebracoes);
      out.putIfAbsent(v.leitorId!, () => []).add(parseDataIso(c.data));
    }
    for (final l in out.values) {
      l.sort();
    }
    return out;
  }

  Future<int> salvarCelebracao(Celebracao c) =>
      _registrar(c.id <= 0 ? 'Nova celebração' : 'Editar celebração', () async {
        var id = c.id;
        if (id <= 0) {
          id = await db.into(db.celebracoes).insert(_celebracaoCompanion(c));
        } else {
          await (db.update(db.celebracoes)..where((t) => t.id.equals(id))).write(_celebracaoCompanion(c));
        }
        final nomes = c.funcoes.map((f) => f.name).toList();
        await (db.delete(db.vagas)..where((t) => t.celebracaoId.equals(id) & t.funcao.isNotIn(nomes))).go();
        for (final f in c.funcoes) {
          await db.into(db.vagas).insert(
                VagasCompanion.insert(celebracaoId: id, funcao: f.name),
                mode: InsertMode.insertOrIgnore,
              );
        }
        return id;
      });

  Future<void> excluirCelebracao(int id) => _registrar('Excluir celebração', () async {
        await (db.delete(db.celebracoes)..where((t) => t.id.equals(id))).go();
      });

  /// Atualiza só os dados do PDF (sem passo de desfazer).
  Future<void> atualizarPdf(int celebracaoId, {String? url, String? arquivo, required StatusPdf status}) async {
    await (db.update(db.celebracoes)..where((t) => t.id.equals(celebracaoId))).write(CelebracoesCompanion(
      pdfUrl: Value(url),
      pdfArquivo: Value(arquivo),
      pdfStatus: Value(status.name),
    ));
    _mudou();
  }

  /// Grava uma célula. Edição manual trava a célula por padrão.
  Future<void> definirVaga(Vaga v, {String? descricao}) =>
      _registrar(descricao ?? 'Editar escala', () async {
        await db.into(db.vagas).insertOnConflictUpdate(_vagaCompanion(v));
      });

  /// Grava várias células de uma vez (gerar/recalcular/sortear).
  Future<void> aplicarVagas(List<Vaga> vagas, String descricao, {(int, int, int)? seedDoMes}) =>
      _registrar(descricao, () async {
        await db.batch((b) {
          for (final v in vagas) {
            b.insert(db.vagas, _vagaCompanion(v), onConflict: DoUpdate((_) => _vagaCompanion(v)));
          }
        });
        if (seedDoMes != null) {
          final (ano, mes, seed) = seedDoMes;
          await (db.update(db.meses)..where((t) => t.ano.equals(ano) & t.mes.equals(mes)))
              .write(MesesCompanion(seed: Value(seed)));
        }
      });

  Future<void> definirPublicado(int ano, int mes, bool publicado) =>
      _registrar(publicado ? 'Publicar mês' : 'Voltar a rascunho', () async {
        await (db.update(db.meses)..where((t) => t.ano.equals(ano) & t.mes.equals(mes)))
            .write(MesesCompanion(status: Value(publicado ? 'publicado' : 'rascunho')));
      });

  /// Aplica a configuração de pastorais do mês ([override] null = padrão).
  /// Células destravadas das missas que mudam de atribuição são limpas.
  Future<void> aplicarPastoraisDoMes(int ano, int mes, List<ConfigPastoral>? override, Configuracao cfg) =>
      _registrar('Pastorais do mês', () async {
        await (db.update(db.meses)..where((t) => t.ano.equals(ano) & t.mes.equals(mes))).write(MesesCompanion(
          pastorais: Value(override == null ? null : jsonEncode([for (final p in override) p.toJson()])),
        ));
        final ps = override ?? cfg.pastorais;
        final cels = (await (db.select(db.celebracoes)..where((t) => t.data.like('${_prefixoMes(ano, mes)}%'))).get())
            .map(_celebracao);
        for (final c in cels) {
          if (c.tipo != TipoCelebracao.domingo || c.atribuicao == Atribuicao.comunidade) continue;
          ConfigPastoral? alvo;
          for (final p in ps) {
            if (p.hora == c.hora && domingoNaPosicao(ano, mes, p.posicaoDomingo) == c.data) alvo = p;
          }
          final novaAtribuicao = alvo == null ? Atribuicao.leitores : Atribuicao.pastoral;
          if (novaAtribuicao == c.atribuicao && alvo?.nome == c.atribuicaoTexto) continue;
          await (db.update(db.celebracoes)..where((t) => t.id.equals(c.id))).write(CelebracoesCompanion(
            atribuicao: Value(novaAtribuicao.name),
            atribuicaoTexto: Value(alvo?.nome),
          ));
          await (db.update(db.vagas)..where((t) => t.celebracaoId.equals(c.id) & t.travada.equals(false)))
              .write(const VagasCompanion(leitorId: Value(null), nomeLivre: Value(null)));
        }
      });

  // -------------------------------------------------------------------------
  // Envios (lembretes da véspera)
  // -------------------------------------------------------------------------

  Future<Set<DateTime>> diasEnviados() async =>
      {for (final e in await db.select(db.envios).get()) parseDataIso(e.data)};

  Future<void> marcarEnviado(DateTime dia, bool enviado) async {
    if (enviado) {
      await db.into(db.envios).insertOnConflictUpdate(
            EnviosCompanion.insert(data: dataIso(dia), enviadoEm: DateTime.now().toIso8601String()),
          );
    } else {
      await (db.delete(db.envios)..where((t) => t.data.equals(dataIso(dia)))).go();
    }
    _mudou();
  }

  // -------------------------------------------------------------------------
  // Configurações
  // -------------------------------------------------------------------------

  Future<String?> valor(String chave) async =>
      (await (db.select(db.configs)..where((t) => t.chave.equals(chave))).getSingleOrNull())?.valor;

  Future<void> definirValor(String chave, String? valor) async {
    if (valor == null) {
      await (db.delete(db.configs)..where((t) => t.chave.equals(chave))).go();
    } else {
      await db.into(db.configs).insertOnConflictUpdate(ConfigsCompanion.insert(chave: chave, valor: valor));
    }
    _mudou();
  }

  Future<Configuracao> configuracao() async {
    final v = await valor('configuracao');
    return v == null ? const Configuracao() : Configuracao.fromJson((jsonDecode(v) as Map).cast<String, dynamic>());
  }

  Future<void> salvarConfiguracao(Configuracao c) => definirValor('configuracao', jsonEncode(c.toJson()));
}
