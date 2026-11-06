import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';

/// Mostra os dados assim que existem (mantendo os anteriores durante recargas).
class Carregando<T> extends StatelessWidget {
  const Carregando(this.valor, {super.key, required this.builder});
  final AsyncValue<T> valor;
  final Widget Function(T dados) builder;

  @override
  Widget build(BuildContext context) {
    if (valor.hasValue) return builder(valor.requireValue);
    if (valor.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Erro: ${valor.error}', textAlign: TextAlign.center),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}

void avisar(BuildContext context, String texto, {SnackBarAction? acao}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto), action: acao));
}

/// Snackbar "Desfeito" com opção de refazer, após ações destrutivas.
void avisarComDesfazer(BuildContext context, WidgetRef ref, String texto) {
  final repo = ref.read(repoProvider);
  avisar(
    context,
    texto,
    acao: SnackBarAction(
      label: 'Desfazer',
      onPressed: () async {
        final d = await repo.desfazer();
        if (d != null && context.mounted) avisar(context, 'Desfeito: $d');
      },
    ),
  );
}

Future<bool> confirmar(BuildContext context, String titulo, String texto, {String ok = 'Confirmar'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(titulo),
      content: Text(texto),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ok)),
      ],
    ),
  );
  return r ?? false;
}

/// Botões de desfazer/refazer para a barra superior.
class BotoesDesfazer extends ConsumerWidget {
  const BotoesDesfazer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(revisaoProvider);
    final repo = ref.watch(repoProvider);
    final pilha = repo.pilha;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        tooltip: pilha.podeDesfazer ? 'Desfazer: ${pilha.proximoDesfazer}' : 'Desfazer',
        icon: const Icon(Icons.undo),
        onPressed: pilha.podeDesfazer
            ? () async {
                final d = await repo.desfazer();
                if (d != null && context.mounted) avisar(context, 'Desfeito: $d');
              }
            : null,
      ),
      IconButton(
        tooltip: pilha.podeRefazer ? 'Refazer: ${pilha.proximoRefazer}' : 'Refazer',
        icon: const Icon(Icons.redo),
        onPressed: pilha.podeRefazer
            ? () async {
                final d = await repo.refazer();
                if (d != null && context.mounted) avisar(context, 'Refeito: $d');
              }
            : null,
      ),
    ]);
  }
}

String dataCurtaBr(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String dataLongaBr(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

const diasSemanaCurtos = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

Future<String?> escolherHora(BuildContext context, String atual) async {
  final p = atual.split(':');
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1])),
    builder: (c, child) => MediaQuery(
      data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (t == null) return null;
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

Future<DateTime?> escolherData(BuildContext context, DateTime? atual) async {
  final d = await showDatePicker(
    context: context,
    initialDate: atual ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  return d == null ? null : DateTime.utc(d.year, d.month, d.day);
}

class Secao extends StatelessWidget {
  const Secao(this.titulo, {super.key, this.trailing});
  final String titulo;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 8, 4),
        child: Row(children: [
          Expanded(
            child: Text(
              titulo,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ?trailing,
        ]),
      );
}
