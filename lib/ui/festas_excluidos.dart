import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/calendario_liturgico.dart';
import '../core/modelos.dart';
import '../core/regras_epoca.dart';
import '../state/providers.dart';
import 'comum.dart';

/// Festas do calendário litúrgico criadas automaticamente nos meses.
class FestasPage extends ConsumerWidget {
  const FestasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoje = soDia(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('Festas e Semana Santa')),
      body: Carregando(ref.watch(configProvider), builder: (cfg) {
        final festas = cfg.festas;
        Future<void> salvar(int i, ConfigFesta f) =>
            ref.read(repoProvider).salvarConfiguracao(cfg.copyWith(festas: [...festas]..[i] = f));
        return ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Estas celebrações entram sozinhas nos meses novos, sem depender do ABC Litúrgico. '
              'Festas que no Brasil vão para o domingo (Epifania, Ascensão, São Pedro e São Paulo, '
              'Assunção, Todos os Santos) já estão nas missas de domingo. '
              'Festa na quinta substitui a missa de quinta. Para um mês já aberto, use '
              '"Incluir festas do calendário" no menu da Escala.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          for (final (i, c) in festas.indexed)
            Builder(builder: (context) {
              final f = festaPorChave(c.chave)!;
              var proxima = f.data(hoje.year);
              if (proxima.isBefore(hoje)) proxima = f.data(hoje.year + 1);
              final funcoes = f.funcoes.map((x) => x.rotulo).join(', ');
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SwitchListTile(
                    title: Text(f.nome),
                    subtitle: Text([
                      'Próxima: ${diasSemanaCurtos[proxima.weekday - 1]} ${dataLongaBr(proxima)}',
                      funcoes,
                      ?f.observacao,
                    ].join('\n')),
                    value: c.ativa,
                    onChanged: (v) => salvar(i, c.copyWith(ativa: v)),
                  ),
                  if (c.ativa)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Wrap(spacing: 8, children: [
                        for (final h in c.horas)
                          InputChip(
                            label: Text(horaExibicao(h)),
                            onPressed: () async {
                              final n = await escolherHora(context, h);
                              if (n != null) salvar(i, c.copyWith(horas: {...c.horas.where((x) => x != h), n}.toList()..sort()));
                            },
                            onDeleted: c.horas.length <= 1
                                ? null
                                : () => salvar(i, c.copyWith(horas: c.horas.where((x) => x != h).toList())),
                          ),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: const Text('Horário'),
                          onPressed: () async {
                            final n = await escolherHora(context, '19:30');
                            if (n != null) salvar(i, c.copyWith(horas: {...c.horas, n}.toList()..sort()));
                          },
                        ),
                      ]),
                    ),
                ]),
              );
            }),
        ]);
      }),
    );
  }
}

/// Configurações > Backup > Restaurar leitores excluídos.
class RestaurarExcluidosPage extends ConsumerStatefulWidget {
  const RestaurarExcluidosPage({super.key});

  @override
  ConsumerState<RestaurarExcluidosPage> createState() => _RestaurarExcluidosPageState();
}

class _RestaurarExcluidosPageState extends ConsumerState<RestaurarExcluidosPage> {
  final _marcados = <int>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leitores excluídos')),
      floatingActionButton: _marcados.isEmpty
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.restore),
              label: Text('Restaurar ${_marcados.length}'),
              onPressed: () async {
                final n = _marcados.length;
                await ref.read(repoProvider).restaurarLeitores(_marcados.toList());
                setState(_marcados.clear);
                if (context.mounted) avisarComDesfazer(context, ref, '$n leitor(es) restaurado(s)');
              },
            ),
      body: Carregando(ref.watch(excluidosProvider), builder: (lista) {
        if (lista.isEmpty) return const Center(child: Text('Nenhum leitor excluído.'));
        return ListView(padding: const EdgeInsets.only(bottom: 88), children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Marque os leitores e toque em Restaurar. Eles voltam com as configurações que tinham.'),
          ),
          for (final l in lista)
            CheckboxListTile(
              value: _marcados.contains(l.id),
              onChanged: (v) => setState(() => v == true ? _marcados.add(l.id) : _marcados.remove(l.id)),
              title: Text(l.nome),
              subtitle: Text('Excluído em ${dataLongaBr(l.excluidoEm!)}'
                  '${l.regras.isEmpty ? '' : ' · ${l.regras.length} regra(s): ${descreverRegra(l.regras.first)}'}'),
            ),
        ]);
      }),
    );
  }
}
