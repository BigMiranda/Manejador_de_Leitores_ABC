import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../core/envios.dart';
import '../core/modelos.dart';
import '../data/banco.dart';
import '../data/repositorio.dart';
import 'abc_servico.dart';
import 'backup_servico.dart';
import 'notificacoes.dart';

const _tarefaDiaria = 'rotina_diaria';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((tarefa, dados) async {
    final repo = Repositorio(Banco());
    try {
      await executarRotina(repo, emSegundoPlano: true);
      return true;
    } catch (e) {
      debugPrint('Rotina em segundo plano falhou: $e');
      return false;
    } finally {
      await repo.fechar();
    }
  });
}

/// Registra a rotina periódica (sobrevive a reinicializações do celular).
Future<void> registrarTarefas() async {
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    _tarefaDiaria,
    _tarefaDiaria,
    frequency: const Duration(hours: 12),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
}

/// Backup semanal, PDFs da semana, reagendamento dos lembretes e aviso de
/// envio atrasado. Roda ao abrir o app e pela WorkManager.
Future<void> executarRotina(Repositorio repo, {bool emSegundoPlano = false}) async {
  Future<void> passo(String nome, Future<void> Function() f) async {
    try {
      await f();
    } catch (e) {
      debugPrint('Rotina: $nome falhou: $e');
    }
  }

  final hoje = soDia(DateTime.now());
  await passo('backup', () => BackupServico(repo).semanalSeNecessario());
  await passo('abc', () async {
    final proximos = await repo.celebracoesEntre(hoje, hoje.add(const Duration(days: 8)));
    final faltaPdf = proximos.any((c) =>
        (c.tipo == TipoCelebracao.domingo || c.tipo == TipoCelebracao.festa) && c.pdfStatus != StatusPdf.ok);
    if (faltaPdf) await AbcServico(repo).sincronizarPeriodo(hoje, hoje.add(const Duration(days: 8)));
  });
  await passo('notificacoes', () => Notificacoes.reagendar(repo));
  if (emSegundoPlano) {
    await passo('atrasados', () async {
      final dias = diasDeEnvio(await repo.celebracoesEntre(hoje, hoje), await repo.diasEnviados());
      for (final d in dias.where((d) => d.atrasado(hoje))) {
        await Notificacoes.mostrarPendente(d);
      }
    });
  }
}
