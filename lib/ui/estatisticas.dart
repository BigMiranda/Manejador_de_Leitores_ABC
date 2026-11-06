import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utilitarios.dart';
import '../state/providers.dart';
import 'comum.dart';
import 'tabela_exportacao.dart';

String _num(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

final _estatisticasProvider = FutureProvider.family<Estatisticas, (int, int)>((ref, m) async {
  final mes = await ref.watch(mesProvider(m).future);
  return calcularEstatisticas(
    leitores: await ref.watch(leitoresProvider.future),
    celebracoesDoMes: mes.celebracoes,
    historico: await ref.watch(historicoCompletoProvider.future),
    referencia: DateTime.now(),
  );
});

/// Simulação dos próximos 12 meses a partir do mês (não salva nada).
final _anualProvider = FutureProvider.family<Map<int, int>, (int, int)>((ref, m) async {
  return simularMeses(
    leitores: await ref.watch(leitoresProvider.future),
    config: await ref.watch(configProvider.future),
    historico: await ref.watch(historicoAntesProvider(m).future),
    ano: m.$1,
    mes: m.$2,
  );
});

class EstatisticasPage extends ConsumerWidget {
  const EstatisticasPage({super.key, required this.ano, required this.mes});
  final int ano;
  final int mes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: TelaSegura(
        appBar: AppBar(
          title: Text('Estatísticas · ${mesesExtenso[mes - 1]} $ano'),
          bottom: const TabBar(tabs: [Tab(text: 'Mês e leitores'), Tab(text: 'Visão anual')]),
        ),
        body: TabBarView(children: [
          Carregando(ref.watch(_estatisticasProvider((ano, mes))), builder: (e) => _Mes(e)),
          _Anual(ano: ano, mes: mes),
        ]),
      ),
    );
  }
}

class _Mes extends StatelessWidget {
  const _Mes(this.e);
  final Estatisticas e;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(children: [
      Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${e.vagas} vagas no rodízio · ${e.elegiveis} leitores elegíveis'),
            const SizedBox(height: 4),
            Text(
              e.vagas == 0 ? 'Sem vagas neste mês.' : 'Cada leitor lê a cada ~${_num(e.intervaloMedioMeses)} meses.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Média de ${_num(e.media12m)} participações por leitor nos últimos 12 meses.'),
          ]),
        ),
      ),
      for (final x in e.porLeitor)
        ListTile(
          dense: true,
          title: Text(x.leitor.nome),
          subtitle: Text([
            'Última: ${x.ultima == null ? '—' : dataLongaBr(x.ultima!)}',
            'Próxima: ${x.proxima == null ? '—' : dataLongaBr(x.proxima!)}',
            if (x.leitor.soPastoral != null) x.leitor.soPastoral!,
          ].join(' · ')),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: e.muitoAcima(x)
                  ? cs.errorContainer
                  : e.muitoAbaixo(x)
                      ? Colors.amber.shade100
                      : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${x.qtd12m} em 12m'),
          ),
        ),
    ]);
  }
}

class _Anual extends ConsumerWidget {
  const _Anual({required this.ano, required this.mes});
  final int ano;
  final int mes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leitores = ref.watch(leitoresProvider).value ?? const [];
    return Carregando(ref.watch(_anualProvider((ano, mes))), builder: (contagem) {
      final lista = leitores.where((l) => l.doRodizioGeral).toList()
        ..sort((a, b) => (contagem[b.id] ?? 0).compareTo(contagem[a.id] ?? 0));
      if (lista.isEmpty) return const Center(child: Text('Cadastre leitores para simular.'));
      final maximo = lista.map((l) => contagem[l.id] ?? 0).fold(1, (a, b) => a > b ? a : b);
      final total = lista.fold(0, (s, l) => s + (contagem[l.id] ?? 0));
      return ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Simulação dos próximos 12 meses a partir de ${mesesExtenso[mes - 1]}/$ano (nada é salvo). '
            'Média: ${_num(total / lista.length)} participações por leitor no ano.',
          ),
        ),
        for (final l in lista)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: Row(children: [
              SizedBox(width: 130, child: Text(l.nome, overflow: TextOverflow.ellipsis)),
              Expanded(
                child: LinearProgressIndicator(
                  value: (contagem[l.id] ?? 0) / maximo,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 32, child: Text('${contagem[l.id] ?? 0}', textAlign: TextAlign.end)),
            ]),
          ),
      ]);
    });
  }
}
