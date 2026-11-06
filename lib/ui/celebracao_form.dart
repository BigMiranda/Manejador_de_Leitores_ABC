import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../core/abc_parser.dart';
import '../core/configuracao.dart';
import '../core/modelos.dart';
import '../state/providers.dart';
import 'comum.dart';

/// Cria ou edita uma celebração (festa, especial, novena de comunidade…).
class CelebracaoPage extends ConsumerStatefulWidget {
  const CelebracaoPage({super.key, required this.celebracao});
  final Celebracao celebracao;

  @override
  ConsumerState<CelebracaoPage> createState() => _CelebracaoPageState();
}

class _CelebracaoPageState extends ConsumerState<CelebracaoPage> {
  late Celebracao _c = widget.celebracao;
  late final _nome = TextEditingController(text: _c.nomeLiturgico ?? '');
  late final _texto = TextEditingController(
    text: _c.atribuicao == Atribuicao.comunidade ? (_c.atribuicaoTexto ?? '') : '',
  );
  late final _url = TextEditingController(text: _c.pdfUrl ?? '');
  var _ocupado = false;

  bool get _nova => _c.id <= 0;

  @override
  void dispose() {
    _nome.dispose();
    _texto.dispose();
    _url.dispose();
    super.dispose();
  }

  Celebracao _montar() => _c.copyWith(
        nomeLiturgico: () => _nome.text.trim().isEmpty ? null : _nome.text.trim(),
        atribuicaoTexto: () => switch (_c.atribuicao) {
          Atribuicao.leitores => null,
          Atribuicao.pastoral => _c.atribuicaoTexto ?? pastoralTercoHomens,
          Atribuicao.comunidade => _texto.text.trim(),
        },
      );

  Future<void> _salvar() async {
    final c = _montar();
    if (c.funcoes.isEmpty && c.atribuicao != Atribuicao.comunidade) {
      avisar(context, 'Escolha pelo menos uma função.');
      return;
    }
    if (c.atribuicao == Atribuicao.comunidade && (c.atribuicaoTexto ?? '').isEmpty) {
      avisar(context, 'Informe o nome da comunidade.');
      return;
    }
    await ref.read(repoProvider).salvarCelebracao(c);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    if (!await confirmar(context, 'Excluir celebração?', 'As vagas desta celebração também saem. Dá para desfazer.',
        ok: 'Excluir')) {
      return;
    }
    await ref.read(repoProvider).excluirCelebracao(_c.id);
    if (!mounted) return;
    avisarComDesfazer(context, ref, 'Celebração excluída');
    Navigator.pop(context);
  }

  Future<void> _baixarPdf(String url) async {
    setState(() => _ocupado = true);
    try {
      await ref.read(abcProvider).definirPdfManual(_c, url);
      if (mounted) avisar(context, 'PDF baixado.');
      setState(() => _c = _c.copyWith(pdfUrl: () => url, pdfStatus: StatusPdf.ok));
    } catch (e) {
      if (mounted) avisar(context, 'Não consegui baixar: $e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _planoB() async {
    final termo = await showDialog<String>(
      context: context,
      builder: (c) {
        final t = TextEditingController(text: _c.nomeLiturgico ?? 'domingo');
        return AlertDialog(
          title: const Text('Buscar PDF no site'),
          content: TextField(controller: t, decoration: const InputDecoration(labelText: 'Termo (ex.: advento)')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(c, t.text), child: const Text('Buscar')),
          ],
        );
      },
    );
    if (termo == null || termo.trim().isEmpty) return;
    setState(() => _ocupado = true);
    try {
      final achados = await ref.read(abcProvider).buscarPdfsNaMidia(termo.trim());
      if (!mounted) return;
      setState(() => _ocupado = false);
      final url = await showModalBottomSheet<String>(useSafeArea: true,
        context: context,
        showDragHandle: true,
        builder: (_) => achados.isEmpty
            ? const ListTile(title: Text('Nada encontrado.'))
            : ListView(children: [
                for (final (titulo, link) in achados)
                  ListTile(title: Text(titulo), subtitle: Text(link), onTap: () => Navigator.pop(context, link)),
              ]),
      );
      if (url != null) {
        _url.text = url;
        await _baixarPdf(url);
      }
    } catch (e) {
      if (mounted) avisar(context, 'A busca falhou: $e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(configProvider).value ?? const Configuracao();
    final pastorais = {pastoralTercoHomens, pastoralTercoMulheres, ...cfg.pastorais.map((p) => p.nome)}.toList();
    final temPdf = !_nova && (_c.tipo == TipoCelebracao.domingo || _c.tipo == TipoCelebracao.festa);
    return TelaSegura(
      appBar: AppBar(
        title: Text(_nova ? 'Nova celebração' : 'Celebração'),
        actions: [
          if (!_nova) IconButton(tooltip: 'Excluir', icon: const Icon(Icons.delete_outline), onPressed: _excluir),
          IconButton(tooltip: 'Salvar', icon: const Icon(Icons.check), onPressed: _salvar),
        ],
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        if (_ocupado) const LinearProgressIndicator(),
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(dataLongaBr(_c.data)),
          subtitle: const Text('Data'),
          onTap: () async {
            final d = await escolherData(context, _c.data);
            if (d != null) setState(() => _c = _c.copyWith(data: d));
          },
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(_c.hora),
          subtitle: const Text('Horário'),
          onTap: () async {
            final h = await escolherHora(context, _c.hora);
            if (h != null) setState(() => _c = _c.copyWith(hora: h));
          },
        ),
        ListTile(
          title: const Text('Tipo'),
          subtitle: DropdownButton<TipoCelebracao>(
            isExpanded: true,
            value: _c.tipo,
            items: [for (final t in TipoCelebracao.values) DropdownMenuItem(value: t, child: Text(t.rotulo))],
            onChanged: (t) => setState(() => _c = _c.copyWith(tipo: t)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _nome,
            decoration: const InputDecoration(labelText: 'Nome litúrgico (opcional)', border: OutlineInputBorder()),
          ),
        ),
        const Secao('Funções'),
        Wrap(spacing: 8, children: [
          const SizedBox(width: 8),
          for (final f in Funcao.values)
            FilterChip(
              label: Text(f.rotulo),
              selected: _c.funcoes.contains(f),
              onSelected: (s) => setState(() => _c = _c.copyWith(
                    funcoes: Funcao.values.where((g) => g == f ? s : _c.funcoes.contains(g)).toList(),
                  )),
            ),
        ]),
        const Secao('Quem proclama as leituras'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<Atribuicao>(
            segments: [for (final a in Atribuicao.values) ButtonSegment(value: a, label: Text(a.rotulo))],
            selected: {_c.atribuicao},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _c = _c.copyWith(
                  atribuicao: s.first,
                  atribuicaoTexto: () => s.first == Atribuicao.pastoral ? pastorais.first : null,
                )),
          ),
        ),
        if (_c.atribuicao == Atribuicao.pastoral)
          ListTile(
            title: const Text('Pastoral'),
            subtitle: DropdownButton<String>(
              isExpanded: true,
              value: pastorais.contains(_c.atribuicaoTexto) ? _c.atribuicaoTexto : pastorais.first,
              items: [for (final p in pastorais) DropdownMenuItem(value: p, child: Text(p))],
              onChanged: (v) => setState(() => _c = _c.copyWith(atribuicaoTexto: () => v)),
            ),
          ),
        if (_c.atribuicao == Atribuicao.comunidade)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _texto,
              decoration: const InputDecoration(
                labelText: 'Texto (ex.: Comunidades Divino Espírito Santo e São Judas Tadeu)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        if (temPdf) ...[
          const Secao('PDF da liturgia'),
          ListTile(
            leading: Icon(_c.pdfStatus == StatusPdf.ok ? Icons.picture_as_pdf : Icons.picture_as_pdf_outlined,
                color: _c.pdfStatus == StatusPdf.ok ? Colors.green : null),
            title: Text(_c.pdfStatus.rotulo),
            subtitle: _c.pdfUrl == null ? null : Text(_c.pdfUrl!, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: _c.pdfArquivo != null && File(_c.pdfArquivo!).existsSync()
                ? IconButton(
                    tooltip: 'Abrir/compartilhar',
                    icon: const Icon(Icons.share),
                    onPressed: () async {
                      final f = await ref.read(abcProvider).pdfParaCompartilhar(_c);
                      await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'application/pdf')]));
                    },
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _url,
                  decoration: const InputDecoration(labelText: 'URL do PDF (colar)', isDense: true),
                ),
              ),
              IconButton(
                tooltip: 'Baixar',
                icon: const Icon(Icons.download),
                onPressed: _ocupado || _url.text.trim().isEmpty ? null : () => _baixarPdf(_url.text.trim()),
              ),
            ]),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _ocupado ? null : _planoB,
              icon: const Icon(Icons.manage_search),
              label: const Text('Procurar na biblioteca do site'),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(onPressed: _salvar, icon: const Icon(Icons.check), label: const Text('Salvar')),
        ),
      ]),
    );
  }
}

/// Sugestão de festa do ABC: pergunta os horários e cria as celebrações.
Future<void> adicionarFesta(BuildContext context, WidgetRef ref, EdicaoAbc festa) async {
  final horas = <String>{'19:30'};
  var segunda = false;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, set) => AlertDialog(
        title: Text('${festa.nome}, ${dataCurtaBr(festa.data)}'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Horários:'),
          Wrap(spacing: 8, children: [
            for (final h in (horas.toList()..sort()))
              InputChip(label: Text(h), onDeleted: () => set(() => horas.remove(h))),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Horário'),
              onPressed: () async {
                final h = await escolherHora(c, '09:00');
                if (h != null) set(() => horas.add(h));
              },
            ),
          ]),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: segunda,
            onChanged: (v) => set(() => segunda = v ?? false),
            title: const Text('Tem 2ª leitura'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          FilledButton(onPressed: horas.isEmpty ? null : () => Navigator.pop(c, true), child: const Text('Adicionar')),
        ],
      ),
    ),
  );
  if (ok != true) return;
  final repo = ref.read(repoProvider);
  for (final h in horas) {
    await repo.salvarCelebracao(Celebracao(
      id: 0,
      data: festa.data,
      hora: h,
      tipo: TipoCelebracao.festa,
      nomeLiturgico: festa.nome,
      funcoes: [Funcao.animador, Funcao.leitura1, if (segunda) Funcao.leitura2, Funcao.preces],
      pdfUrl: festa.pdfUrl,
    ));
  }
  try {
    await ref.read(abcProvider).sincronizarPeriodo(festa.data, festa.data);
  } catch (_) {}
}
