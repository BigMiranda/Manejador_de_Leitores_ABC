import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/configuracao.dart';
import '../core/modelos.dart';
import '../core/regras_epoca.dart';
import '../core/utilitarios.dart';
import '../state/providers.dart';
import 'comum.dart';
import 'leitor_form.dart';

enum _Filtro {
  vaoLer('Vão ler'),
  naoVaoLer('Não vão ler'),
  animadores('Animadores'),
  pastoral('Só pastoral'),
  comPar('Com par'),
  comRegras('Com épocas');

  const _Filtro(this.rotulo);
  final String rotulo;
}

String resumoLeitor(Leitor l, Map<int, String> nomes) {
  final partes = <String>[
    if (!l.vaiLer) 'Não vai ler',
    if (l.soPastoral != null) 'Só pela pastoral: ${l.soPastoral}',
    if (l.fazAnimacao == FazAnimacao.simPrefere) 'Anima (prefere)',
    if (l.fazAnimacao == FazAnimacao.simPrefereLer) 'Anima (prefere ler)',
    if (!l.leDomingo)
      'Não lê domingo'
    else if (l.horariosDomingo.length < horariosDomingoPadrao.length)
      'Domingo: ${l.horariosDomingo.map(horaExibicao).join(', ')}',
    if (l.leQuinta == LeQuinta.sim) 'Lê quinta',
    if (l.leQuinta == LeQuinta.asVezes) 'Quinta às vezes',
    if (l.leFesta) 'Lê em festa',
    if (l.regras.isNotEmpty) '${l.regras.length} regra(s) de época',
    if (l.parId != null && nomes[l.parId] != null) 'Lê com ${nomes[l.parId]}',
  ];
  return partes.isEmpty ? 'Só domingos' : partes.join(' · ');
}

class LeitoresPage extends ConsumerStatefulWidget {
  const LeitoresPage({super.key});

  @override
  ConsumerState<LeitoresPage> createState() => _LeitoresPageState();
}

class _LeitoresPageState extends ConsumerState<LeitoresPage> {
  var _busca = '';
  _Filtro? _filtro;
  final _selecionados = <int>{};

  bool get _selecionando => _selecionados.isNotEmpty;

  bool _passa(Leitor l) {
    if (_busca.isNotEmpty && !normalizarNome(l.nome).contains(normalizarNome(_busca))) return false;
    return switch (_filtro) {
      null => true,
      _Filtro.vaoLer => l.vaiLer,
      _Filtro.naoVaoLer => !l.vaiLer,
      _Filtro.animadores => l.fazAnimacao != FazAnimacao.nao,
      _Filtro.pastoral => l.soPastoral != null,
      _Filtro.comPar => l.parId != null,
      _Filtro.comRegras => l.regras.isNotEmpty,
    };
  }

  void _abrir(Leitor? l) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => LeitorFormPage(leitor: l)));

  void _alternar(int id) => setState(() => _selecionados.contains(id) ? _selecionados.remove(id) : _selecionados.add(id));

  Future<void> _editarSelecionados(List<Leitor> todos) async {
    final sel = todos.where((l) => _selecionados.contains(l.id)).toList();
    if (sel.isEmpty) return;
    if (sel.length == 1) {
      _abrir(sel.single);
    } else {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => EdicaoEmLotePage(leitores: sel)),
      );
      if (ok != true) return;
    }
    setState(_selecionados.clear);
  }

  Future<void> _excluirSelecionados(List<Leitor> todos) async {
    final sel = todos.where((l) => _selecionados.contains(l.id)).toList();
    if (sel.isEmpty) return;
    if (!await confirmarExclusaoLeitores(context, sel.map((l) => l.nome).toList())) return;
    await ref.read(repoProvider).excluirLeitores(sel.map((l) => l.id).toList());
    if (!mounted) return;
    setState(_selecionados.clear);
    avisarComDesfazer(context, ref, sel.length == 1 ? '${sel.single.nome} excluído' : '${sel.length} leitores excluídos');
  }

  @override
  Widget build(BuildContext context) {
    final leitores = ref.watch(leitoresProvider);
    final todos = leitores.value ?? const <Leitor>[];
    final visiveis = todos.where(_passa).toList();
    // Seleções de leitores que sumiram (excluídos, desfeitos) não contam.
    _selecionados.removeWhere((id) => !todos.any((l) => l.id == id));

    final barra = _selecionando
        ? AppBar(
            leading: IconButton(
              tooltip: 'Cancelar seleção',
              icon: const Icon(Icons.close),
              onPressed: () => setState(_selecionados.clear),
            ),
            title: Text('${_selecionados.length} selecionado(s)'),
            actions: [
              IconButton(
                tooltip: 'Selecionar todos da lista',
                icon: const Icon(Icons.select_all),
                onPressed: () => setState(() => _selecionados.addAll(visiveis.map((l) => l.id))),
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit),
                onPressed: () => _editarSelecionados(todos),
              ),
              IconButton(
                tooltip: 'Excluir',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _excluirSelecionados(todos),
              ),
            ],
          )
        : AppBar(
            title: Text('Leitores${leitores.hasValue ? ' (${todos.length})' : ''}'),
            actions: [
              const BotoesDesfazer(),
              IconButton(
                tooltip: 'Importar lista',
                icon: const Icon(Icons.playlist_add),
                onPressed: () => showDialog(context: context, builder: (_) => const ImportarDialog()),
              ),
            ],
          );

    return PopScope(
      canPop: !_selecionando,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) setState(_selecionados.clear);
      },
      child: Scaffold(
        appBar: barra,
        floatingActionButton: _selecionando
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _abrir(null),
                icon: const Icon(Icons.person_add),
                label: const Text('Novo leitor'),
              ),
        body: Carregando(leitores, builder: (todos) {
          final nomes = {for (final l in todos) l.id: l.nome};
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar leitor',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _busca = v),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                children: [
                  for (final f in _Filtro.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(f.rotulo),
                        selected: _filtro == f,
                        // Tocar de novo no filtro ativo desmarca.
                        onSelected: (s) => setState(() => _filtro = s ? f : null),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: visiveis.isEmpty
                  ? Center(
                      child: Text(
                        todos.isEmpty
                            ? 'Nenhum leitor ainda.\nUse "Novo leitor" ou "Importar lista".'
                            : 'Nenhum leitor neste filtro.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: visiveis.length,
                      itemBuilder: (_, i) {
                        final l = visiveis[i];
                        final sel = _selecionados.contains(l.id);
                        return ListTile(
                          selected: sel,
                          leading: sel
                              ? CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary),
                                )
                              : CircleAvatar(
                                  backgroundColor: l.vaiLer ? null : Colors.grey.shade300,
                                  child: Text(l.nome.isEmpty ? '?' : l.nome.characters.first.toUpperCase()),
                                ),
                          title: Text(l.nome),
                          subtitle: Text(resumoLeitor(l, nomes), maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () => _selecionando ? _alternar(l.id) : _abrir(l),
                          onLongPress: () => _alternar(l.id),
                        );
                      },
                    ),
            ),
          ]);
        }),
      ),
    );
  }
}

/// Edição de vários leitores de uma vez: cada campo pode ficar "como está".
class EdicaoEmLotePage extends ConsumerStatefulWidget {
  const EdicaoEmLotePage({super.key, required this.leitores});
  final List<Leitor> leitores;

  @override
  ConsumerState<EdicaoEmLotePage> createState() => _EdicaoEmLotePageState();
}

const _manter = '__manter__';
const _nenhuma = '__nenhuma__';

class _EdicaoEmLotePageState extends ConsumerState<EdicaoEmLotePage> {
  bool? _vaiLer;
  FazAnimacao? _anima;
  bool? _domingo;
  Set<String>? _horarios;
  LeQuinta? _quinta;
  bool? _festa;
  String _pastoral = _manter;
  final _novasRegras = <RegraEpoca>[];

  Widget _escolha<T>(String titulo, T? valor, Map<T, String> opcoes, void Function(T?) mudar) => ListTile(
        title: Text(titulo),
        subtitle: DropdownButton<T?>(
          isExpanded: true,
          value: valor,
          items: [
            const DropdownMenuItem(value: null, child: Text('Manter como está')),
            for (final e in opcoes.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (v) => setState(() => mudar(v)),
        ),
      );

  Future<void> _aplicar() async {
    final novos = [
      for (final l in widget.leitores)
        l.copyWith(
          vaiLer: _vaiLer,
          fazAnimacao: _anima,
          leDomingo: _domingo,
          horariosDomingo: _horarios,
          leQuinta: _quinta,
          leFesta: _festa,
          soPastoral: _pastoral == _manter ? null : () => _pastoral == _nenhuma ? null : _pastoral,
          regras: _novasRegras.isEmpty ? null : [...l.regras, ..._novasRegras],
        ),
    ];
    if (novos.any((l) => l.leDomingo && l.horariosDomingo.isEmpty)) {
      avisar(context, 'Quem lê de domingo precisa de pelo menos um horário.');
      return;
    }
    await ref.read(repoProvider).atualizarLeitores(novos);
    if (!mounted) return;
    avisarComDesfazer(context, ref, '${novos.length} leitores atualizados');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(configProvider).value ?? const Configuracao();
    final horas = cfg.missasDomingo.map((m) => m.hora).toList()..sort();
    final pastorais = {pastoralTercoHomens, pastoralTercoMulheres, ...cfg.pastorais.map((p) => p.nome)};
    final n = widget.leitores.length;
    return Scaffold(
      appBar: AppBar(title: Text('Editar $n leitores')),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            widget.leitores.map((l) => l.nome).join(', '),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        _escolha<bool>('Vai ler?', _vaiLer, {true: 'Sim', false: 'Não'}, (v) => _vaiLer = v),
        _escolha<FazAnimacao>(
          'Faz animação?',
          _anima,
          {for (final f in FazAnimacao.values) f: f.rotulo},
          (v) => _anima = v,
        ),
        _escolha<bool>('Consegue ler de domingo?', _domingo, {true: 'Sim', false: 'Não'}, (v) => _domingo = v),
        SwitchListTile(
          title: const Text('Definir horários de domingo'),
          subtitle: Text(_horarios == null ? 'Manter como está' : 'Lê nas missas marcadas abaixo'),
          value: _horarios != null,
          onChanged: (v) => setState(() => _horarios = v ? {...horas} : null),
        ),
        if (_horarios != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, children: [
              for (final h in horas)
                FilterChip(
                  label: Text(horaExibicao(h)),
                  selected: _horarios!.contains(h),
                  onSelected: (s) => setState(() => s ? _horarios!.add(h) : _horarios!.remove(h)),
                ),
            ]),
          ),
        _escolha<LeQuinta>(
          'Consegue ler de quinta 19h30?',
          _quinta,
          {for (final q in LeQuinta.values) q: q.rotulo},
          (v) => _quinta = v,
        ),
        _escolha<bool>('Consegue ler em missa de feriado/festa?', _festa, {true: 'Sim', false: 'Não'}, (v) => _festa = v),
        ListTile(
          title: const Text('Só lê pela pastoral?'),
          subtitle: DropdownButton<String>(
            isExpanded: true,
            value: _pastoral,
            items: [
              const DropdownMenuItem(value: _manter, child: Text('Manter como está')),
              const DropdownMenuItem(value: _nenhuma, child: Text('Não')),
              for (final p in pastorais) DropdownMenuItem(value: p, child: Text(p)),
            ],
            onChanged: (v) => setState(() => _pastoral = v ?? _manter),
          ),
        ),
        Secao('Acrescentar regra de época a todos',
            trailing: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Regra'),
              onPressed: () async {
                final r = await Navigator.push<RegraEpoca>(
                  context,
                  MaterialPageRoute(fullscreenDialog: true, builder: (_) => const RegraPage()),
                );
                if (r != null) setState(() => _novasRegras.add(r));
              },
            )),
        for (final (i, r) in _novasRegras.indexed)
          ListTile(
            dense: true,
            title: Text(descreverRegra(r)),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _novasRegras.removeAt(i)),
            ),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text('Nome, par, última participação e observações são editados um a um.', style: TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _aplicar,
            icon: const Icon(Icons.done_all),
            label: Text('Aplicar a $n leitores'),
          ),
        ),
      ]),
    );
  }
}

/// "Importar lista": cola nomes, um por linha, com prévia antes de gravar.
class ImportarDialog extends ConsumerStatefulWidget {
  const ImportarDialog({super.key});

  @override
  ConsumerState<ImportarDialog> createState() => _ImportarDialogState();
}

class _ImportarDialogState extends ConsumerState<ImportarDialog> {
  final _texto = TextEditingController();
  PreviaImportacao? _previa;
  var _excluidos = <String>{};

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _analisar() async {
    // Inclui os excluídos: o nome é único no banco, e eles podem ser restaurados.
    final todos = await ref.read(repoProvider).leitores(incluirExcluidos: true);
    setState(() {
      _excluidos = {for (final l in todos.where((l) => l.excluidoEm != null)) normalizarNome(l.nome)};
      _previa = analisarImportacao(_texto.text, todos.map((l) => l.nome));
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _previa;
    final jaExcluidos = p?.jaExistem.where((n) => _excluidos.contains(normalizarNome(n))).toList() ?? const [];
    return AlertDialog(
      title: const Text('Importar lista'),
      content: SizedBox(
        width: 400,
        child: p == null
            ? TextField(
                controller: _texto,
                autofocus: true,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText: 'Cole os nomes, um por linha.\nMarcadores como "1.", "-" e "•" são removidos.',
                  border: OutlineInputBorder(),
                ),
              )
            : SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.resumo, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (p.novos.isNotEmpty) Text('Novos: ${p.novos.join(', ')}'),
                  if (p.jaExistem.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Já cadastrados (ignorados): ${p.jaExistem.join(', ')}'),
                  ],
                  if (jaExcluidos.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Destes, estão excluídos: ${jaExcluidos.join(', ')}. '
                      'Recupere em Configurações > Backup > Restaurar leitores excluídos.',
                    ),
                  ],
                  if (p.repetidosNaLista.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Repetidos na lista (ignorados): ${p.repetidosNaLista.join(', ')}'),
                  ],
                  const SizedBox(height: 8),
                  const Text('Os novos entram com os valores padrão (lê só aos domingos).'),
                ]),
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        if (p == null)
          FilledButton(onPressed: _analisar, child: const Text('Analisar'))
        else ...[
          TextButton(onPressed: () => setState(() => _previa = null), child: const Text('Voltar')),
          FilledButton(
            onPressed: p.novos.isEmpty
                ? null
                : () async {
                    await ref.read(repoProvider).importarNomes(p.novos);
                    if (!context.mounted) return;
                    avisarComDesfazer(context, ref, '${p.novos.length} leitores importados');
                    Navigator.pop(context);
                  },
            child: Text('Importar ${p.novos.length}'),
          ),
        ],
      ],
    );
  }
}
