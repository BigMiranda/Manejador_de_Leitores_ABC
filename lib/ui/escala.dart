import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/abc_parser.dart';
import '../core/configuracao.dart';
import '../core/escala.dart';
import '../core/modelos.dart';
import '../core/utilitarios.dart';
import '../data/repositorio.dart';
import '../services/exportacao.dart';
import '../state/providers.dart';
import 'celebracao_form.dart';
import 'comum.dart';
import 'estatisticas.dart';
import 'tabela_exportacao.dart';

final _sugestoesProvider = FutureProvider.family<List<EdicaoAbc>, (int, int)>((ref, m) async {
  final mes = await ref.watch(mesProvider(m).future);
  return ref.watch(abcProvider).sugestoesDeFestas(m.$1, m.$2, mes.celebracoes);
});

final _sincronizados = <(int, int)>{};

/// Sincroniza os PDFs do mês ao abri-lo (uma vez por mês e execução).
Future<void> sincronizarMesEmSegundoPlano(WidgetRef ref, (int, int) m, {bool forcar = false}) async {
  if (!forcar && _sincronizados.contains(m)) return;
  _sincronizados.add(m);
  try {
    final fim = DateTime.utc(m.$1, m.$2 + 1, 0);
    await ref.read(abcProvider).sincronizarPeriodo(DateTime.utc(m.$1, m.$2, 1), fim);
  } catch (_) {
    // Sem rede: tenta de novo na próxima execução ou pela rotina diária.
  }
}

class EscalaPage extends ConsumerWidget {
  const EscalaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(mesSelecionadoProvider);
    final mes = ref.watch(mesProvider(sel));
    final avisos = ref.watch(avisosProvider)[sel] ?? const <Aviso>[];
    if (mes.hasValue) Future.microtask(() => sincronizarMesEmSegundoPlano(ref, sel));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(mesSelecionadoProvider.notifier).somar(-1),
          ),
          InkWell(
            onTap: () async {
              final m = await escolherMes(context, sel);
              if (m != null) ref.read(mesSelecionadoProvider.notifier).ir(m);
            },
            child: Text('${mesesExtenso[sel.$2 - 1]} ${sel.$1}'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(mesSelecionadoProvider.notifier).somar(1),
          ),
        ]),
        actions: [
          const BotoesDesfazer(),
          if (mes.hasValue) _MenuEscala(mes.requireValue),
        ],
      ),
      floatingActionButton: mes.hasValue
          ? FloatingActionButton.extended(
              onPressed: () => gerarMes(context, ref, mes.requireValue),
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Gerar'),
            )
          : null,
      body: Carregando(mes, builder: (m) {
        final leitores = ref.watch(leitoresProvider).value ?? const <Leitor>[];
        final sugestoes = ref.watch(_sugestoesProvider(sel)).value ?? const <EdicaoAbc>[];
        final elegiveis = leitores.where((l) => l.doRodizioGeral).length;
        final vagas = contarVagasRodizio(m.celebracoes);
        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Chip(
                avatar: Icon(m.publicado ? Icons.verified : Icons.edit_note, size: 18),
                label: Text(m.publicado ? 'Publicado' : 'Rascunho'),
              ),
              if (avisos.isNotEmpty)
                ActionChip(
                  avatar: const Icon(Icons.warning_amber, size: 18),
                  label: Text('${avisos.length} aviso(s)'),
                  onPressed: () => mostrarAvisos(context, avisos),
                ),
              Text(
                '$vagas vagas · $elegiveis elegíveis'
                '${vagas == 0 ? '' : ' · cada leitor lê a cada ~${(elegiveis / vagas).toStringAsFixed(1).replaceAll('.', ',')} meses'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ]),
          ),
          for (final s in sugestoes)
            Card(
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.celebration_outlined),
                title: Text('${s.nome}, ${dataCurtaBr(s.data)}'),
                subtitle: const Text('Festa no ABC Litúrgico. Adicionar? Quais horários?'),
                trailing: TextButton(
                  onPressed: () => adicionarFesta(context, ref, s),
                  child: const Text('Adicionar'),
                ),
              ),
            ),
          Expanded(child: TabelaEscala(mes: m, leitores: leitores)),
        ]);
      }),
    );
  }
}

Future<(int, int)?> escolherMes(BuildContext context, (int, int) atual) {
  var ano = atual.$1;
  return showDialog<(int, int)>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, set) => AlertDialog(
        title: Row(children: [
          IconButton(onPressed: () => set(() => ano--), icon: const Icon(Icons.chevron_left)),
          Expanded(child: Center(child: Text('$ano'))),
          IconButton(onPressed: () => set(() => ano++), icon: const Icon(Icons.chevron_right)),
        ]),
        content: SizedBox(
          width: 300,
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (var m = 1; m <= 12; m++)
              ChoiceChip(
                label: Text(mesesExtenso[m - 1].substring(0, 3)),
                selected: ano == atual.$1 && m == atual.$2,
                onSelected: (_) => Navigator.pop(c, (ano, m)),
              ),
          ]),
        ),
      ),
    ),
  );
}

void mostrarAvisos(BuildContext context, List<Aviso> avisos) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => ListView(children: [
      for (final a in avisos)
        ListTile(
          leading: Icon(switch (a.tipo) {
            TipoAviso.vagaSemCandidato => Icons.person_off_outlined,
            TipoAviso.parNaoAtendido => Icons.people_outline,
            TipoAviso.abaixoIntervalo => Icons.timelapse,
          }),
          title: Text(a.tipo.rotulo),
          subtitle: Text(a.mensagem),
        ),
    ]),
  );
}

/// Gera/recalcula o mês (só células destravadas).
Future<void> gerarMes(BuildContext context, WidgetRef ref, MesEscala m, {bool alternativa = false}) async {
  var refazer = alternativa;
  if (!alternativa) {
    final temPreenchidas = m.vagas.any((v) => !v.travada && !v.vazia);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: const Text('Gerar/Recalcular mês'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Preenche as células vazias e destravadas. Células travadas e linhas de comunidade não mudam.'),
            if (temPreenchidas)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: refazer,
                onChanged: (v) => set(() => refazer = v ?? false),
                title: const Text('Refazer também as destravadas já preenchidas'),
              ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Gerar')),
          ],
        ),
      ),
    );
    if (ok != true) return;
  }
  final repo = ref.read(repoProvider);
  final leitores = await ref.read(leitoresProvider.future);
  final cfg = await ref.read(configProvider.future);
  final hist = await ref.read(historicoAntesProvider((m.ano, m.mes)).future);
  final seed = alternativa ? m.seed + 1 : m.seed;
  final r = gerarEscala(
    leitores: leitores,
    celebracoes: m.celebracoes,
    vagas: m.vagas,
    historico: hist,
    config: ConfigEscala(intervaloMinimoDias: cfg.intervaloMinimoSemanas * 7, refazerDestravadas: refazer),
    seed: seed,
  );
  await repo.aplicarVagas(
    r.vagas,
    alternativa ? 'Sortear alternativa' : 'Gerar escala',
    seedDoMes: (m.ano, m.mes, seed),
  );
  ref.read(avisosProvider.notifier).definir((m.ano, m.mes), r.avisos);
  if (!context.mounted) return;
  avisar(
    context,
    r.avisos.isEmpty ? 'Escala gerada sem avisos.' : 'Escala gerada com ${r.avisos.length} aviso(s).',
    acao: r.avisos.isEmpty
        ? null
        : SnackBarAction(label: 'Ver', onPressed: () => mostrarAvisos(context, r.avisos)),
  );
}

class _MenuEscala extends ConsumerWidget {
  const _MenuEscala(this.m);
  final MesEscala m;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repoProvider);
    return PopupMenuButton<String>(
      onSelected: (op) async {
        switch (op) {
          case 'alternativa':
            await gerarMes(context, ref, m, alternativa: true);
          case 'publicar':
            await repo.definirPublicado(m.ano, m.mes, !m.publicado);
          case 'png':
          case 'pdf':
            final nomes = await ref.read(nomesProvider.future);
            await Exportacao.compartilhar(m, nomes, comoPdf: op == 'pdf');
          case 'nova':
            if (!context.mounted) return;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CelebracaoPage(
                  celebracao: Celebracao(
                    id: 0,
                    data: DateTime.utc(m.ano, m.mes, 1),
                    hora: '19:30',
                    tipo: TipoCelebracao.especial,
                    funcoes: const [Funcao.animador, Funcao.leitura1, Funcao.preces],
                  ),
                ),
              ),
            );
          case 'pastorais':
            if (!context.mounted) return;
            await showDialog(context: context, builder: (_) => PastoraisDoMesDialog(mes: m));
          case 'festas':
            final cfg = await ref.read(configProvider.future);
            final n = await repo.incluirFestasDoCalendario(m.ano, m.mes, cfg);
            if (context.mounted) {
              n == 0
                  ? avisar(context, 'Nenhuma festa do calendário faltando neste mês.')
                  : avisarComDesfazer(context, ref, '$n celebração(ões) do calendário incluída(s)');
            }
          case 'pdfs':
            final fim = DateTime.utc(m.ano, m.mes + 1, 0);
            if (context.mounted) avisar(context, 'Sincronizando com o ABC Litúrgico…');
            final r = await ref.read(abcProvider).sincronizarPeriodo(DateTime.utc(m.ano, m.mes, 1), fim, forcarBusca: true);
            if (context.mounted) avisar(context, r.resumo);
          case 'estatisticas':
            if (!context.mounted) return;
            await Navigator.push(context, MaterialPageRoute(builder: (_) => EstatisticasPage(ano: m.ano, mes: m.mes)));
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'alternativa', child: ListTile(leading: Icon(Icons.casino_outlined), title: Text('Sortear alternativa'))),
        PopupMenuItem(
          value: 'publicar',
          child: ListTile(
            leading: Icon(m.publicado ? Icons.edit_note : Icons.verified_outlined),
            title: Text(m.publicado ? 'Voltar a rascunho' : 'Publicar mês'),
          ),
        ),
        const PopupMenuItem(value: 'png', child: ListTile(leading: Icon(Icons.image_outlined), title: Text('Exportar PNG'))),
        const PopupMenuItem(value: 'pdf', child: ListTile(leading: Icon(Icons.picture_as_pdf_outlined), title: Text('Exportar PDF'))),
        const PopupMenuItem(value: 'nova', child: ListTile(leading: Icon(Icons.add), title: Text('Adicionar celebração'))),
        const PopupMenuItem(value: 'pastorais', child: ListTile(leading: Icon(Icons.groups_outlined), title: Text('Pastorais do mês'))),
        const PopupMenuItem(
          value: 'festas',
          child: ListTile(leading: Icon(Icons.celebration_outlined), title: Text('Incluir festas do calendário')),
        ),
        const PopupMenuItem(value: 'pdfs', child: ListTile(leading: Icon(Icons.sync), title: Text('Sincronizar PDFs do ABC'))),
        const PopupMenuItem(value: 'estatisticas', child: ListTile(leading: Icon(Icons.insights), title: Text('Estatísticas'))),
      ],
    );
  }
}

/// Tabela editável do mês, no mesmo formato da exportação.
class TabelaEscala extends ConsumerWidget {
  const TabelaEscala({super.key, required this.mes, required this.leitores});
  final MesEscala mes;
  final List<Leitor> leitores;

  static const _wData = 84.0;
  static const _wHora = 58.0;
  static const _wFuncao = 118.0;
  static const _altura = 44.0;
  static const _funcoes = [Funcao.animador, Funcao.leitura1, Funcao.leitura2, Funcao.preces];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final porId = {for (final l in leitores) l.id: l};
    final nomes = ref.watch(nomesProvider).value ?? const <int, String>{};
    final celPorId = {for (final c in mes.celebracoes) c.id: c};
    final grupos = gruposDaEscala(mes.celebracoes);
    final borda = BorderSide(color: Theme.of(context).dividerColor);

    Widget celula(double w, Widget? filho, {Color? fundo, VoidCallback? onTap, VoidCallback? onLongPress}) => InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            width: w,
            height: _altura,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: fundo, border: Border(right: borda, bottom: borda)),
            child: filho,
          ),
        );

    Widget cabecalho() => Row(children: [
          celula(_wData, const Text('DATA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          celula(_wHora, const Text('HORA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          for (final f in _funcoes)
            celula(_wFuncao, Text(f.cabecalho, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        ]);

    Widget linha(Celebracao c) {
      final pastoral = c.atribuicao == Atribuicao.pastoral;
      final fundoPastoral = pastoral ? const Color(0x55FFEB3B) : null;
      final cabecalhoCel = Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          '${diasSemanaCurtos[c.data.weekday - 1]} ${dataCurtaBr(c.data)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: c.tipo == TipoCelebracao.festa || c.tipo == TipoCelebracao.especial ? FontWeight.bold : null,
            color: c.atribuicao == Atribuicao.comunidade ? Colors.red.shade700 : null,
          ),
        ),
        if (c.nomeLiturgico != null)
          Text(c.nomeLiturgico!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9)),
      ]);
      void editar() =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => CelebracaoPage(celebracao: c)));
      final iconePdf = c.tipo == TipoCelebracao.domingo || c.tipo == TipoCelebracao.festa
          ? Icon(
              c.pdfStatus == StatusPdf.ok ? Icons.picture_as_pdf : Icons.picture_as_pdf_outlined,
              size: 12,
              color: c.pdfStatus == StatusPdf.ok ? Colors.green.shade700 : Colors.grey,
            )
          : null;
      final horaW = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(c.hora, style: TextStyle(fontSize: 12, color: c.atribuicao == Atribuicao.comunidade ? Colors.red.shade700 : null)),
        if (iconePdf != null) ...[const SizedBox(width: 2), iconePdf],
      ]);

      if (c.atribuicao == Atribuicao.comunidade) {
        return Row(children: [
          celula(_wData, cabecalhoCel, onTap: editar),
          celula(_wHora, horaW, onTap: editar),
          celula(
            _wFuncao * 4,
            Text(
              c.atribuicaoTexto ?? 'Comunidade',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onTap: editar,
          ),
        ]);
      }

      Set<int> ocupados(Funcao f) => {
            for (final v in mes.vagas)
              if (v.leitorId != null &&
                  !(v.celebracaoId == c.id && v.funcao == f) &&
                  celPorId[v.celebracaoId]?.data == c.data)
                v.leitorId!,
          };

      Widget vazia() => celula(_wFuncao, null, fundo: Theme.of(context).disabledColor.withValues(alpha: 0.05));

      Widget celulaVaga(Funcao f, {String? rotulo}) {
        if (!c.funcoes.contains(f)) return vazia();
        final v = mes.vaga(c.id, f) ?? Vaga(celebracaoId: c.id, funcao: f);
        final leitor = v.leitorId == null ? null : porId[v.leitorId];
        final nome = leitor?.nome ?? (v.leitorId != null ? nomes[v.leitorId] : null) ?? v.nomeLivre ?? '';
        // Leitor excluído que ainda está na escala também é conflito.
        final excluido = v.leitorId != null && leitor == null;
        final conflito = excluido ||
            (leitor != null && motivosInelegivel(leitor, c, f, ocupadosNoDia: ocupados(f)).isNotEmpty);
        return celula(
          _wFuncao,
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (rotulo != null) Text(rotulo, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Flexible(
                child: Text(
                  nome,
                  maxLines: rotulo == null ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: conflito ? Colors.red.shade700 : null,
                    fontStyle: v.leitorId == null && nome.isNotEmpty ? FontStyle.italic : null,
                    decoration: excluido ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (conflito) Icon(Icons.warning_amber, size: 13, color: Colors.red.shade700),
              if (v.travada) const Icon(Icons.lock, size: 12),
            ]),
          ]),
          fundo: fundoPastoral,
          onTap: () => editarVaga(context, ref, mes, c, v, leitores),
          onLongPress: () => ref.read(repoProvider).definirVaga(
                v.copyWith(travada: !v.travada),
                descricao: v.travada ? 'Destravar célula' : 'Travar célula',
              ),
        );
      }

      final principal = Row(children: [
        celula(_wData, cabecalhoCel, onTap: editar),
        celula(_wHora, horaW, fundo: fundoPastoral, onTap: editar),
        for (final f in _funcoes) celulaVaga(f),
      ]);
      if (!TabelaExportacao.temLinhaExtra(c)) return principal;
      // Vigília Pascal: 3ª leitura e epístola numa linha a mais.
      return Column(children: [
        principal,
        Row(children: [
          celula(_wData, null, onTap: editar),
          celula(_wHora, null, fundo: fundoPastoral),
          vazia(),
          celulaVaga(Funcao.leitura3, rotulo: '3ª LEITURA'),
          celulaVaga(Funcao.epistola, rotulo: 'EPÍSTOLA'),
          vazia(),
        ]),
      ]);
    }

    final largura = _wData + _wHora + _wFuncao * 4 + 1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: largura,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96, top: 8),
          children: [
            Container(
              decoration: BoxDecoration(border: Border(left: borda, top: borda)),
              child: Column(children: [
                cabecalho(),
                for (final g in grupos) ...[
                  Container(height: 8, decoration: BoxDecoration(border: Border(bottom: borda, right: borda))),
                  for (final c in g) linha(c),
                ],
              ]),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Toque numa célula para escolher o leitor. Edição manual trava a célula (cadeado). '
                'Segure a célula para travar/destravar. Toque na data para editar a celebração.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seletor de leitor para uma célula: elegíveis primeiro, conflitos sinalizados.
Future<void> editarVaga(
  BuildContext context,
  WidgetRef ref,
  MesEscala mes,
  Celebracao c,
  Vaga v,
  List<Leitor> leitores,
) async {
  final hist = Historico(await ref.read(historicoCompletoProvider.future));
  final celPorId = {for (final x in mes.celebracoes) x.id: x};
  final ocupados = {
    for (final o in mes.vagas)
      if (o.leitorId != null && !(o.celebracaoId == c.id && o.funcao == v.funcao) && celPorId[o.celebracaoId]?.data == c.data)
        o.leitorId!,
  };
  final itens = [
    for (final l in leitores)
      (l, motivosInelegivel(l, c, v.funcao, ocupadosNoDia: ocupados), hist.ultimaAntes(l, c.data)),
  ]..sort((a, b) {
      // Elegíveis primeiro; depois quem está há mais tempo sem ler.
      if (a.$2.isEmpty != b.$2.isEmpty) return a.$2.isEmpty ? -1 : 1;
      final ua = a.$3, ub = b.$3;
      if (ua == null && ub != null) return -1;
      if (ub == null && ua != null) return 1;
      if (ua != null && ub != null && ua != ub) return ua.compareTo(ub);
      return normalizarNome(a.$1.nome).compareTo(normalizarNome(b.$1.nome));
    });
  if (!context.mounted) return;
  final repo = ref.read(repoProvider);
  final resultado = await showModalBottomSheet<Vaga>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _SeletorLeitor(celebracao: c, vaga: v, itens: itens),
  );
  if (resultado != null) await repo.definirVaga(resultado);
}

class _SeletorLeitor extends StatefulWidget {
  const _SeletorLeitor({required this.celebracao, required this.vaga, required this.itens});
  final Celebracao celebracao;
  final Vaga vaga;
  final List<(Leitor, List<String>, DateTime?)> itens;

  @override
  State<_SeletorLeitor> createState() => _SeletorLeitorState();
}

class _SeletorLeitorState extends State<_SeletorLeitor> {
  var _busca = '';

  @override
  Widget build(BuildContext context) {
    final c = widget.celebracao;
    final v = widget.vaga;
    final filtrados = widget.itens.where((i) => normalizarNome(i.$1.nome).contains(normalizarNome(_busca))).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (context, scroll) => Column(children: [
        ListTile(
          title: Text('${v.funcao.rotulo} — ${diasSemanaCurtos[c.data.weekday - 1]} ${dataCurtaBr(c.data)} ${horaExibicao(c.hora)}'),
          subtitle: c.atribuicao == Atribuicao.pastoral ? Text('Pastoral: ${c.atribuicaoTexto}') : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Expanded(
              child: TextField(
                autofocus: false,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar ou digitar um nome',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (t) => setState(() => _busca = t),
              ),
            ),
          ]),
        ),
        Wrap(spacing: 8, children: [
          if (!v.vazia)
            TextButton.icon(
              onPressed: () => Navigator.pop(
                context,
                v.copyWith(leitorId: () => null, nomeLivre: () => null, travada: true),
              ),
              icon: const Icon(Icons.clear),
              label: const Text('Limpar'),
            ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, v.copyWith(travada: !v.travada)),
            icon: Icon(v.travada ? Icons.lock_open : Icons.lock),
            label: Text(v.travada ? 'Destravar' : 'Travar'),
          ),
          if (_busca.trim().isNotEmpty)
            TextButton.icon(
              onPressed: () => Navigator.pop(
                context,
                v.copyWith(leitorId: () => null, nomeLivre: () => _busca.trim(), travada: true),
              ),
              icon: const Icon(Icons.edit),
              label: Text('Usar "${_busca.trim()}"'),
            ),
        ]),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: scroll,
            itemCount: filtrados.length,
            itemBuilder: (_, i) {
              final (l, motivos, ultima) = filtrados[i];
              final elegivel = motivos.isEmpty;
              return ListTile(
                dense: true,
                selected: l.id == v.leitorId,
                leading: Icon(elegivel ? Icons.check_circle_outline : Icons.block,
                    color: elegivel ? Colors.green : Colors.red.shade300),
                title: Text(l.nome, style: TextStyle(color: elegivel ? null : Colors.grey)),
                subtitle: Text([
                  ultima == null ? 'Sem participação registrada' : 'Última: ${dataLongaBr(ultima)}',
                  ...motivos,
                ].join(' · ')),
                onTap: () => Navigator.pop(
                  context,
                  v.copyWith(leitorId: () => l.id, nomeLivre: () => null, travada: true),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

/// Sobrescreve, para o mês, o domingo e o horário de cada pastoral.
class PastoraisDoMesDialog extends ConsumerStatefulWidget {
  const PastoraisDoMesDialog({super.key, required this.mes});
  final MesEscala mes;

  @override
  ConsumerState<PastoraisDoMesDialog> createState() => _PastoraisDoMesDialogState();
}

class _PastoraisDoMesDialogState extends ConsumerState<PastoraisDoMesDialog> {
  List<ConfigPastoral>? _lista;

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(configProvider).value ?? const Configuracao();
    final lista = _lista ??= [...(widget.mes.pastorais ?? cfg.pastorais)];
    final horas = cfg.missasDomingo.map((m) => m.hora).toList();
    final domingos = [
      for (var p = 1; p <= 5; p++) (p, domingoNaPosicao(widget.mes.ano, widget.mes.mes, p)),
    ];
    return AlertDialog(
      title: Text('Pastorais em ${mesesExtenso[widget.mes.mes - 1]}'),
      content: SizedBox(
        width: 400,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final (i, p) in lista.indexed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(p.nome),
              subtitle: Row(children: [
                DropdownButton<int>(
                  value: p.posicaoDomingo,
                  items: [
                    const DropdownMenuItem(value: 0, child: Text('Nenhum')),
                    for (final (pos, d) in domingos)
                      if (d != null)
                        DropdownMenuItem(
                          value: pos,
                          child: Text('${pos == 5 ? 'Último' : '$posº'} dom (${dataCurtaBr(d)})'),
                        ),
                  ],
                  onChanged: (v) => setState(() => lista[i] = p.copyWith(posicaoDomingo: v)),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: horas.contains(p.hora) ? p.hora : horas.last,
                  items: [for (final h in horas) DropdownMenuItem(value: h, child: Text(horaExibicao(h)))],
                  onChanged: (v) => setState(() => lista[i] = p.copyWith(hora: v)),
                ),
              ]),
            ),
          const Text(
            'Células destravadas das missas que mudarem são limpas.',
            style: TextStyle(fontSize: 12),
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await ref.read(repoProvider).aplicarPastoraisDoMes(widget.mes.ano, widget.mes.mes, null, cfg);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Usar padrão'),
        ),
        FilledButton(
          onPressed: () async {
            await ref.read(repoProvider).aplicarPastoraisDoMes(widget.mes.ano, widget.mes.mes, lista, cfg);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
