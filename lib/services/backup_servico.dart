import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/utilitarios.dart';
import '../data/repositorio.dart';

class ArquivoBackup {
  const ArquivoBackup(this.arquivo, this.criadoEm, {required this.mensal});
  final File arquivo;
  final DateTime criadoEm;
  final bool mensal;
}

/// Backups JSON na pasta interna do app (semanais + mensais permanentes).
class BackupServico {
  BackupServico(this.repo, {Future<Directory> Function()? pasta})
      : _pasta = pasta ?? (() async => Directory(p.join((await getApplicationDocumentsDirectory()).path, 'backups')));

  final Repositorio repo;
  final Future<Directory> Function() _pasta;

  static final _reNome = RegExp(r'^backup_(\d{8})_(\d{6})');

  String _carimbo(DateTime d) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${d.year}${dois(d.month)}${dois(d.day)}_${dois(d.hour)}${dois(d.minute)}${dois(d.second)}';
  }

  DateTime? _dataDoNome(String nome) {
    final m = _reNome.firstMatch(nome);
    if (m == null) return null;
    final d = m.group(1)!;
    final h = m.group(2)!;
    return DateTime(int.parse(d.substring(0, 4)), int.parse(d.substring(4, 6)), int.parse(d.substring(6, 8)),
        int.parse(h.substring(0, 2)), int.parse(h.substring(2, 4)), int.parse(h.substring(4, 6)));
  }

  Future<File> criar({String sufixo = ''}) async {
    final pasta = await _pasta();
    await pasta.create(recursive: true);
    final dados = await repo.exportarBackup();
    final nome = 'backup_${_carimbo(DateTime.now())}${sufixo.isEmpty ? '' : '_$sufixo'}.json';
    final f = File(p.join(pasta.path, nome));
    await f.writeAsString(const JsonEncoder.withIndent(' ').convert(dados), flush: true);
    await repo.definirValor('ultimoBackupEm', DateTime.now().toIso8601String());
    return f;
  }

  Future<List<ArquivoBackup>> listar() async {
    final pasta = await _pasta();
    if (!await pasta.exists()) return const [];
    final achados = <(File, DateTime)>[];
    await for (final e in pasta.list()) {
      if (e is! File || !e.path.endsWith('.json')) continue;
      final d = _dataDoNome(p.basename(e.path));
      if (d != null) achados.add((e, d));
    }
    final plano = planejarRetencao([for (final (f, d) in achados) InfoBackup(f.path, d)], DateTime.now());
    return [
      for (final (f, d) in achados) ArquivoBackup(f, d, mensal: plano.mensais.contains(f.path)),
    ]..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
  }

  /// Apaga semanais com mais de 3 meses (mensais ficam para sempre).
  Future<int> aplicarRetencao() async {
    final todos = await listar();
    final plano = planejarRetencao([for (final b in todos) InfoBackup(b.arquivo.path, b.criadoEm)], DateTime.now());
    for (final caminho in plano.apagar) {
      await File(caminho).delete();
    }
    return plano.apagar.length;
  }

  /// Backup semanal: cria se o mais recente tiver 7 dias ou mais.
  Future<bool> semanalSeNecessario() async {
    final todos = await listar();
    if (todos.isNotEmpty && DateTime.now().difference(todos.first.criadoEm).inDays < 7) return false;
    await criar();
    await aplicarRetencao();
    return true;
  }

  /// Compartilha um backup novo (para salvar no Google Drive).
  Future<void> exportar() async {
    final f = await criar();
    await SharePlus.instance.share(ShareParams(
      files: [XFile(f.path, mimeType: 'application/json')],
      subject: 'Backup Leitores ABC',
    ));
    await repo.definirValor('ultimoExportEm', DateTime.now().toIso8601String());
  }

  Future<DateTime?> ultimoExport() async {
    final s = await repo.valor('ultimoExportEm');
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<Map<String, dynamic>> ler(File f) async =>
      (jsonDecode(await f.readAsString()) as Map).cast<String, dynamic>();

  /// Contagens para a prévia antes de restaurar.
  static Map<String, int> contagens(Map<String, dynamic> backup) {
    final dados = (backup['dados'] as Map?)?.cast<String, dynamic>() ?? const {};
    return {for (final e in dados.entries) e.key: (e.value as List).length};
  }

  /// Faz um backup do estado atual e então restaura.
  Future<void> restaurar(Map<String, dynamic> backup) async {
    await criar(sufixo: 'antes_de_restaurar');
    await repo.restaurarBackup(backup);
  }
}
