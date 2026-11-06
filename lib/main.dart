import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/modelos.dart';
import 'data/banco.dart';
import 'data/repositorio.dart';
import 'services/notificacoes.dart';
import 'services/tarefas.dart';
import 'state/providers.dart';
import 'ui/inicio.dart';
import 'ui/enviar.dart';

final navegador = GlobalKey<NavigatorState>();

void abrirEnvio(String diaIso) {
  navegador.currentState?.push(MaterialPageRoute(builder: (_) => EnviarPage(dia: parseDataIso(diaIso))));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR');
  final repo = Repositorio(Banco());

  await Notificacoes.inicializar(aoTocar: abrirEnvio);
  final diaInicial = await Notificacoes.diaQueAbriuOApp();

  runApp(ProviderScope(
    overrides: [repoProvider.overrideWithValue(repo)],
    child: const LeitoresApp(),
  ));

  if (diaInicial != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => abrirEnvio(diaInicial));
  }
  // Tarefas de fundo não podem impedir o app de abrir.
  Future(() async {
    try {
      await registrarTarefas();
    } catch (e) {
      debugPrint('WorkManager: $e');
    }
    await executarRotina(repo);
  });
}

class LeitoresApp extends StatelessWidget {
  const LeitoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leitores ABC',
      navigatorKey: navegador,
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B5A2E)),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}
