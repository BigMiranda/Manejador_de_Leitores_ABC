import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/envios.dart';
import '../core/modelos.dart';
import '../services/notificacoes.dart';
import '../state/providers.dart';
import 'comum.dart';
import 'config.dart';
import 'enviar.dart';
import 'escala.dart';
import 'leitores.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  var _aba = 0;

  @override
  void initState() {
    super.initState();
    Notificacoes.pedirPermissao();
  }

  @override
  Widget build(BuildContext context) {
    const paginas = [InicioPage(), LeitoresPage(), EscalaPage(), ConfigPage()];
    return Scaffold(
      body: IndexedStack(index: _aba, children: paginas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Leitores'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Escala'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Configurações'),
        ],
      ),
    );
  }
}

class _ResumoInicio {
  const _ResumoInicio(this.dias, this.ultimoExport);
  final List<DiaDeEnvio> dias;
  final DateTime? ultimoExport;
}

final _inicioProvider = FutureProvider<_ResumoInicio>((ref) async {
  ref.watch(revisaoProvider);
  final repo = ref.watch(repoProvider);
  final hoje = soDia(DateTime.now());
  final cels = await repo.celebracoesEntre(hoje, hoje.add(const Duration(days: 15)));
  return _ResumoInicio(
    diasDeEnvio(cels, await repo.diasEnviados()),
    await ref.watch(backupProvider).ultimoExport(),
  );
});

class InicioPage extends ConsumerWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoje = soDia(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('Leitores ABC'), actions: const [BotoesDesfazer()]),
      body: Carregando(ref.watch(_inicioProvider), builder: (r) {
        final pendentes = r.dias.where((d) => d.pendente(hoje)).toList();
        final proximos = r.dias.where((d) => d.diaDoEnvio.isAfter(hoje)).take(8).toList();
        final semExport = r.ultimoExport == null || DateTime.now().difference(r.ultimoExport!).inDays > 30;
        return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
          if (semExport)
            Card(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('Exporte um backup'),
                subtitle: Text(r.ultimoExport == null
                    ? 'Nenhum backup foi exportado ainda. Salve no Google Drive.'
                    : 'Último export em ${dataLongaBr(r.ultimoExport!)} (mais de 30 dias).'),
                trailing: FilledButton(
                  onPressed: () => ref.read(backupProvider).exportar(),
                  child: const Text('Exportar'),
                ),
              ),
            ),
          const Secao('Envios pendentes'),
          if (pendentes.isEmpty)
            const ListTile(leading: Icon(Icons.check_circle_outline), title: Text('Nada para enviar agora.')),
          for (final d in pendentes) _TileEnvio(d, hoje: hoje, destaque: true),
          const Secao('Próximos envios'),
          if (proximos.isEmpty) const ListTile(title: Text('Nenhuma celebração nos próximos dias.')),
          for (final d in proximos) _TileEnvio(d, hoje: hoje),
        ]);
      }),
    );
  }
}

class _TileEnvio extends StatelessWidget {
  const _TileEnvio(this.d, {required this.hoje, this.destaque = false});
  final DiaDeEnvio d;
  final DateTime hoje;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final atrasado = d.atrasado(hoje);
    final horas = d.celebracoes.map((c) => horaExibicao(c.hora)).join(', ');
    final nome = d.celebracoes.map((c) => c.nomeLiturgico).whereType<String>().firstOrNull;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: destaque ? (atrasado ? cs.errorContainer : cs.primaryContainer) : null,
      child: ListTile(
        leading: Icon(d.enviado ? Icons.done_all : (d.comPdf ? Icons.picture_as_pdf_outlined : Icons.message_outlined)),
        title: Text(
          '${diasSemanaCurtos[d.dia.weekday - 1]} ${dataCurtaBr(d.dia)} · $horas',
        ),
        subtitle: Text([
          ?nome,
          if (d.enviado)
            'Enviado'
          else if (atrasado)
            'Atrasado: a celebração é hoje'
          else
            'Enviar em ${dataCurtaBr(d.diaDoEnvio)}',
        ].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EnviarPage(dia: d.dia))),
      ),
    );
  }
}
