import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/modelos.dart';
import '../core/utilitarios.dart';
import '../state/providers.dart';
import 'comum.dart';
import 'leitor_form.dart';

enum _Filtro {
  todos('Todos'),
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
    if (l.leQuinta == LeQuinta.nao) 'Não lê quinta',
    if (l.leQuinta == LeQuinta.asVezes) 'Quinta às vezes',
    if (!l.leFesta) 'Não lê em festa',
    if (l.regras.isNotEmpty) '${l.regras.length} regra(s) de época',
    if (l.parId != null && nomes[l.parId] != null) 'Lê com ${nomes[l.parId]}',
  ];
  return partes.isEmpty ? 'Disponível em todas as missas' : partes.join(' · ');
}

class LeitoresPage extends ConsumerStatefulWidget {
  const LeitoresPage({super.key});

  @override
  ConsumerState<LeitoresPage> createState() => _LeitoresPageState();
}

class _LeitoresPageState extends ConsumerState<LeitoresPage> {
  var _busca = '';
  var _filtro = _Filtro.todos;

  bool _passa(Leitor l) {
    if (_busca.isNotEmpty && !normalizarNome(l.nome).contains(normalizarNome(_busca))) return false;
    return switch (_filtro) {
      _Filtro.todos => true,
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

  @override
  Widget build(BuildContext context) {
    final leitores = ref.watch(leitoresProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Leitores${leitores.hasValue ? ' (${leitores.requireValue.length})' : ''}'),
        actions: [
          const BotoesDesfazer(),
          IconButton(
            tooltip: 'Importar lista',
            icon: const Icon(Icons.playlist_add),
            onPressed: () => showDialog(context: context, builder: (_) => const ImportarDialog()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrir(null),
        icon: const Icon(Icons.person_add),
        label: const Text('Novo leitor'),
      ),
      body: Carregando(leitores, builder: (todos) {
        final nomes = {for (final l in todos) l.id: l.nome};
        final lista = todos.where(_passa).toList();
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
                    child: ChoiceChip(
                      label: Text(f.rotulo),
                      selected: _filtro == f,
                      onSelected: (_) => setState(() => _filtro = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? Center(
                    child: Text(todos.isEmpty
                        ? 'Nenhum leitor ainda.\nUse "Novo leitor" ou "Importar lista".'
                        : 'Nenhum leitor neste filtro.', textAlign: TextAlign.center),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: lista.length,
                    itemBuilder: (_, i) {
                      final l = lista[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: l.vaiLer ? null : Colors.grey.shade300,
                          child: Text(l.nome.isEmpty ? '?' : l.nome.characters.first.toUpperCase()),
                        ),
                        title: Text(l.nome),
                        subtitle: Text(resumoLeitor(l, nomes), maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => _abrir(l),
                      );
                    },
                  ),
          ),
        ]);
      }),
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

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _analisar() async {
    final existentes = (await ref.read(leitoresProvider.future)).map((l) => l.nome);
    setState(() => _previa = analisarImportacao(_texto.text, existentes));
  }

  @override
  Widget build(BuildContext context) {
    final p = _previa;
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
                  if (p.repetidosNaLista.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Repetidos na lista (ignorados): ${p.repetidosNaLista.join(', ')}'),
                  ],
                  const SizedBox(height: 8),
                  const Text('Os novos entram com os valores padrão.'),
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
