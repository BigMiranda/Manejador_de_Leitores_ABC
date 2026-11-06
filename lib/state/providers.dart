import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/configuracao.dart';
import '../core/escala.dart';
import '../core/modelos.dart';
import '../data/repositorio.dart';
import '../services/abc_servico.dart';
import '../services/backup_servico.dart';

/// Sobrescrito em main.dart (e nos testes) com o repositório real.
final repoProvider = Provider<Repositorio>((ref) => throw UnimplementedError('repoProvider'));

final abcProvider = Provider((ref) => AbcServico(ref.watch(repoProvider)));
final backupProvider = Provider((ref) => BackupServico(ref.watch(repoProvider)));

/// Contador que muda a cada gravação no banco: os dados dependem dele.
class Revisao extends Notifier<int> {
  @override
  int build() {
    final sub = ref.watch(repoProvider).mudancas.listen((_) => state++);
    ref.onDispose(sub.cancel);
    return 0;
  }
}

final revisaoProvider = NotifierProvider<Revisao, int>(Revisao.new);

final configProvider = FutureProvider<Configuracao>((ref) {
  ref.watch(revisaoProvider);
  return ref.watch(repoProvider).configuracao();
});

final leitoresProvider = FutureProvider<List<Leitor>>((ref) {
  ref.watch(revisaoProvider);
  return ref.watch(repoProvider).leitores();
});

/// Nome de cada leitor por id, inclusive os excluídos (que seguem nas escalas já feitas).
final nomesProvider = FutureProvider<Map<int, String>>((ref) async {
  ref.watch(revisaoProvider);
  final ls = await ref.watch(repoProvider).leitores(incluirExcluidos: true);
  return {for (final l in ls) l.id: l.nome};
});

final excluidosProvider = FutureProvider<List<Leitor>>((ref) {
  ref.watch(revisaoProvider);
  return ref.watch(repoProvider).leitoresExcluidos();
});

/// Mês exibido na aba Escala.
class MesSelecionado extends Notifier<(int, int)> {
  @override
  (int, int) build() {
    final h = DateTime.now();
    return (h.year, h.month);
  }

  void ir((int, int) m) => state = m;

  void somar(int n) {
    final d = DateTime(state.$1, state.$2 + n);
    state = (d.year, d.month);
  }
}

final mesSelecionadoProvider = NotifierProvider<MesSelecionado, (int, int)>(MesSelecionado.new);

/// Abre (e cria, se preciso) o mês.
final mesProvider = FutureProvider.family<MesEscala, (int, int)>((ref, m) async {
  ref.watch(revisaoProvider);
  final cfg = await ref.watch(configProvider.future);
  return ref.watch(repoProvider).abrirMes(m.$1, m.$2, cfg);
});

/// Participações antes do 1º dia do mês (meses publicados e rascunhos anteriores).
final historicoAntesProvider = FutureProvider.family<Map<int, List<DateTime>>, (int, int)>((ref, m) {
  ref.watch(revisaoProvider);
  return ref.watch(repoProvider).historico(antesDe: DateTime.utc(m.$1, m.$2, 1));
});

final historicoCompletoProvider = FutureProvider<Map<int, List<DateTime>>>((ref) {
  ref.watch(revisaoProvider);
  return ref.watch(repoProvider).historico();
});

/// Avisos da última geração, por mês (só em memória).
class AvisosDoMes extends Notifier<Map<(int, int), List<Aviso>>> {
  @override
  Map<(int, int), List<Aviso>> build() => {};

  void definir((int, int) mes, List<Aviso> avisos) => state = {...state, mes: avisos};
}

final avisosProvider = NotifierProvider<AvisosDoMes, Map<(int, int), List<Aviso>>>(AvisosDoMes.new);
