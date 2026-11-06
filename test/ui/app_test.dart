import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/core/modelos.dart';
import 'package:manejador_leitores/data/banco.dart';
import 'package:manejador_leitores/data/repositorio.dart';
import 'package:manejador_leitores/main.dart';
import 'package:manejador_leitores/state/providers.dart';

/// Deixa o banco (I/O real) responder e redesenha algumas vezes.
Future<void> esperar(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('navega pelas abas e importa leitores', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final repo = Repositorio(Banco(NativeDatabase.memory()));
    await tester.runAsync(() => repo.salvarLeitor(const Leitor(id: 0, nome: 'Rosa')));

    await tester.pumpWidget(ProviderScope(
      overrides: [repoProvider.overrideWithValue(repo)],
      child: const LeitoresApp(),
    ));
    await esperar(tester);
    expect(find.text('Envios pendentes'), findsOneWidget);

    await tester.tap(find.text('Leitores').last);
    await esperar(tester);
    expect(find.text('Rosa'), findsOneWidget);

    await tester.tap(find.byTooltip('Importar lista'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '1. Tita\n- rosa\n• Bia');
    await tester.tap(find.text('Analisar'));
    await esperar(tester);
    expect(find.text('2 novos, 1 já existe'), findsOneWidget);
    await tester.tap(find.text('Importar 2'));
    await esperar(tester);
    expect(find.text('Tita'), findsOneWidget);
    expect(find.text('Bia'), findsOneWidget);

    // Filtro: tocar de novo desmarca.
    final chip = find.widgetWithText(FilterChip, 'Animadores');
    await tester.ensureVisible(chip);
    await tester.pump();
    await tester.tap(chip);
    await esperar(tester);
    expect(find.text('Nenhum leitor neste filtro.'), findsOneWidget);
    await tester.tap(chip);
    await esperar(tester);
    expect(find.text('Tita'), findsOneWidget);

    // Segurar seleciona; excluir 2 tem contagem de 10 s.
    await tester.longPress(find.text('Tita'));
    await tester.pump();
    await tester.tap(find.text('Bia'));
    await tester.pump();
    expect(find.text('2 selecionado(s)'), findsOneWidget);
    await tester.tap(find.byTooltip('Excluir'));
    await tester.pump();
    expect(find.text('Excluir 2 leitores?'), findsOneWidget);
    expect(find.textContaining('Restaurar leitores excluídos'), findsOneWidget);
    expect(find.text('Excluir (10)'), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.tap(find.text('Excluir'));
    await esperar(tester);
    expect(find.text('Tita'), findsNothing);
    expect(find.text('Bia'), findsNothing);
    expect(find.text('Rosa'), findsOneWidget);

    await tester.tap(find.text('Configurações').last);
    await esperar(tester);
    expect(find.text('Missas de domingo'), findsOneWidget);

    await tester.runAsync(repo.fechar);
  });
}
