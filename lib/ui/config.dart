import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/configuracao.dart';
import '../core/modelos.dart';
import '../services/backup_servico.dart';
import '../services/notificacoes.dart';
import '../state/providers.dart';
import 'comum.dart';
import 'festas_excluidos.dart';

class ConfigPage extends ConsumerWidget {
  const ConfigPage({super.key});

  Future<void> _salvar(WidgetRef ref, Configuracao c) => ref.read(repoProvider).salvarConfiguracao(c);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Carregando(ref.watch(configProvider), builder: (cfg) {
        return ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          const Secao('Missas de domingo'),
          _ModelosMissa(
            modelos: cfg.missasDomingo,
            aoMudar: (m) => _salvar(ref, cfg.copyWith(missasDomingo: m)),
          ),
          const Secao('Missa de quinta'),
          _ModelosMissa(
            modelos: cfg.missasQuinta,
            aoMudar: (m) => _salvar(ref, cfg.copyWith(missasQuinta: m)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Os modelos valem para os meses abertos daqui em diante.', style: TextStyle(fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.celebration_outlined),
            title: const Text('Festas e Semana Santa'),
            subtitle: Text('${cfg.festas.where((f) => f.ativa).length} de ${cfg.festas.length} ativas · horários'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FestasPage())),
          ),
          Secao('Domingos das pastorais',
              trailing: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Pastoral'),
                onPressed: () async {
                  final nome = await _pedirTexto(context, 'Nome da pastoral');
                  if (nome == null || nome.isEmpty) return;
                  await _salvar(ref, cfg.copyWith(pastorais: [
                    ...cfg.pastorais,
                    ConfigPastoral(nome: nome, posicaoDomingo: 0, hora: cfg.missasDomingo.last.hora),
                  ]));
                },
              )),
          for (final (i, p) in cfg.pastorais.indexed)
            ListTile(
              title: Text(p.nome),
              subtitle: Row(children: [
                DropdownButton<int>(
                  value: p.posicaoDomingo,
                  items: [
                    const DropdownMenuItem(value: 0, child: Text('Desativada')),
                    for (final (v, r) in [(1, '1º'), (2, '2º'), (3, '3º'), (4, '4º'), (5, 'Último')])
                      DropdownMenuItem(value: v, child: Text('$r domingo')),
                  ],
                  onChanged: (v) => _salvar(ref, cfg.copyWith(pastorais: [...cfg.pastorais]..[i] = p.copyWith(posicaoDomingo: v))),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: cfg.missasDomingo.any((m) => m.hora == p.hora) ? p.hora : null,
                  hint: Text(p.hora),
                  items: [
                    for (final m in cfg.missasDomingo) DropdownMenuItem(value: m.hora, child: Text(horaExibicao(m.hora))),
                  ],
                  onChanged: (v) => _salvar(ref, cfg.copyWith(pastorais: [...cfg.pastorais]..[i] = p.copyWith(hora: v))),
                ),
              ]),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _salvar(ref, cfg.copyWith(pastorais: [...cfg.pastorais]..removeAt(i))),
              ),
            ),
          const Secao('Escala'),
          ListTile(
            title: const Text('Intervalo mínimo desejável'),
            subtitle: Text('${cfg.intervaloMinimoSemanas} semanas entre participações (penalidade forte, não proíbe)'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: cfg.intervaloMinimoSemanas <= 0
                    ? null
                    : () => _salvar(ref, cfg.copyWith(intervaloMinimoSemanas: cfg.intervaloMinimoSemanas - 1)),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _salvar(ref, cfg.copyWith(intervaloMinimoSemanas: cfg.intervaloMinimoSemanas + 1)),
              ),
            ]),
          ),
          const Secao('Lembrete da véspera'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Horário da notificação'),
            subtitle: Text('${cfg.horaNotificacao} do dia anterior a cada celebração'),
            onTap: () async {
              final h = await escolherHora(context, cfg.horaNotificacao);
              if (h == null) return;
              await _salvar(ref, cfg.copyWith(horaNotificacao: h));
              await Notificacoes.reagendar(ref.read(repoProvider));
            },
          ),
          ListTile(
            leading: const Icon(Icons.message_outlined),
            title: const Text('Textos das mensagens'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TextosPage())),
          ),
          const Secao('ABC Litúrgico'),
          const _AbcTile(),
          const Secao('Backup'),
          const _BackupTiles(),
        ]);
      }),
    );
  }
}

Future<String?> _pedirTexto(BuildContext context, String titulo) {
  final t = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(titulo),
      content: TextField(controller: t, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(c, t.text.trim()), child: const Text('OK')),
      ],
    ),
  );
}

class _ModelosMissa extends StatelessWidget {
  const _ModelosMissa({required this.modelos, required this.aoMudar});
  final List<ModeloMissa> modelos;
  final void Function(List<ModeloMissa>) aoMudar;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final (i, m) in modelos.indexed)
        ListTile(
          leading: ActionChip(
            label: Text(horaExibicao(m.hora)),
            onPressed: () async {
              final h = await escolherHora(context, m.hora);
              if (h != null) aoMudar([...modelos]..[i] = ModeloMissa(h, m.funcoes));
            },
          ),
          title: Wrap(spacing: 4, children: [
            for (final f in Funcao.values)
              FilterChip(
                visualDensity: VisualDensity.compact,
                label: Text(f.rotulo, style: const TextStyle(fontSize: 11)),
                selected: m.funcoes.contains(f),
                onSelected: (s) => aoMudar([...modelos]
                  ..[i] = ModeloMissa(m.hora, Funcao.values.where((g) => g == f ? s : m.funcoes.contains(g)).toList())),
              ),
          ]),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: modelos.length <= 1 ? null : () => aoMudar([...modelos]..removeAt(i)),
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Horário'),
          onPressed: () async {
            final h = await escolherHora(context, '10:00');
            if (h == null) return;
            aoMudar([...modelos, ModeloMissa(h, modelos.first.funcoes)]..sort((a, b) => a.hora.compareTo(b.hora)));
          },
        ),
      ),
    ]);
  }
}

class _AbcTile extends ConsumerStatefulWidget {
  const _AbcTile();

  @override
  ConsumerState<_AbcTile> createState() => _AbcTileState();
}

class _AbcTileState extends ConsumerState<_AbcTile> {
  var _ocupado = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(revisaoProvider);
    final abc = ref.watch(abcProvider);
    return FutureBuilder<DateTime?>(
      future: abc.ultimaBusca(),
      builder: (context, snap) => ListTile(
        leading: _ocupado
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.sync),
        title: const Text('Sincronizar ABC agora'),
        subtitle: Text(snap.data == null
            ? 'Nunca sincronizado'
            : 'Última busca: ${dataLongaBr(snap.data!)} ${snap.data!.hour.toString().padLeft(2, '0')}:${snap.data!.minute.toString().padLeft(2, '0')}'),
        onTap: _ocupado
            ? null
            : () async {
                setState(() => _ocupado = true);
                try {
                  final hoje = soDia(DateTime.now());
                  final r = await abc.sincronizarPeriodo(hoje, hoje.add(const Duration(days: 60)), forcarBusca: true);
                  if (context.mounted) avisar(context, r.resumo);
                } catch (e) {
                  if (context.mounted) avisar(context, 'Falhou: $e');
                } finally {
                  if (mounted) setState(() => _ocupado = false);
                }
              },
      ),
    );
  }
}

class _BackupTiles extends ConsumerWidget {
  const _BackupTiles();

  Future<void> _restaurar(BuildContext context, WidgetRef ref, Map<String, dynamic> backup) async {
    final cont = BackupServico.contagens(backup);
    final criado = DateTime.tryParse(backup['criadoEm'] as String? ?? '');
    final ok = await confirmar(
      context,
      'Restaurar backup?',
      'Backup de ${criado == null ? '?' : dataLongaBr(criado)}: '
          '${cont['leitores'] ?? 0} leitores, ${cont['regras'] ?? 0} regras, '
          '${cont['celebracoes'] ?? 0} celebrações, ${cont['vagas'] ?? 0} vagas, ${cont['meses'] ?? 0} meses.\n\n'
          'Os dados atuais serão substituídos. Antes, um backup do estado atual é salvo.',
      ok: 'Restaurar',
    );
    if (!ok) return;
    await ref.read(backupProvider).restaurar(backup);
    await Notificacoes.reagendar(ref.read(repoProvider));
    if (context.mounted) avisar(context, 'Backup restaurado.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servico = ref.watch(backupProvider);
    return Column(children: [
      ListTile(
        leading: const Icon(Icons.ios_share),
        title: const Text('Exportar backup'),
        subtitle: const Text('Compartilha o arquivo JSON (salve no Google Drive)'),
        onTap: () => servico.exportar(),
      ),
      ListTile(
        leading: const Icon(Icons.save_outlined),
        title: const Text('Fazer backup interno agora'),
        onTap: () async {
          await servico.criar();
          await servico.aplicarRetencao();
          if (context.mounted) avisar(context, 'Backup salvo.');
        },
      ),
      ListTile(
        leading: const Icon(Icons.file_open_outlined),
        title: const Text('Restaurar de um arquivo'),
        onTap: () async {
          final arquivos = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
          final caminho = arquivos.isEmpty ? null : arquivos.first.path;
          if (caminho == null) return;
          try {
            final dados = await servico.ler(File(caminho));
            if (context.mounted) await _restaurar(context, ref, dados);
          } catch (e) {
            if (context.mounted) avisar(context, 'Arquivo inválido: $e');
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.restore_from_trash_outlined),
        title: const Text('Restaurar leitores excluídos'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurarExcluidosPage())),
      ),
      ListTile(
        leading: const Icon(Icons.history),
        title: const Text('Backups internos'),
        subtitle: const Text('Semanais (3 meses) e mensais (para sempre)'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _BackupsInternosPage(aoRestaurar: (b) => _restaurar(context, ref, b))),
        ),
      ),
    ]);
  }
}

class _BackupsInternosPage extends ConsumerWidget {
  const _BackupsInternosPage({required this.aoRestaurar});
  final Future<void> Function(Map<String, dynamic>) aoRestaurar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servico = ref.watch(backupProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Backups internos')),
      body: FutureBuilder<List<ArquivoBackup>>(
        future: servico.listar(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final lista = snap.data!;
          if (lista.isEmpty) return const Center(child: Text('Nenhum backup ainda.'));
          return ListView(children: [
            for (final b in lista)
              ListTile(
                leading: Icon(b.mensal ? Icons.inventory_2_outlined : Icons.description_outlined),
                title: Text(
                  '${dataLongaBr(b.criadoEm)} ${b.criadoEm.hour.toString().padLeft(2, '0')}:${b.criadoEm.minute.toString().padLeft(2, '0')}',
                ),
                subtitle: Text(b.mensal ? 'Mensal (mantido para sempre)' : 'Semanal'),
                onTap: () async {
                  final dados = await servico.ler(b.arquivo);
                  await aoRestaurar(dados);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
          ]);
        },
      ),
    );
  }
}

/// Modelos de mensagem com placeholders.
class TextosPage extends ConsumerStatefulWidget {
  const TextosPage({super.key});

  @override
  ConsumerState<TextosPage> createState() => _TextosPageState();
}

class _TextosPageState extends ConsumerState<TextosPage> {
  Map<String, TextEditingController>? _c;

  @override
  void dispose() {
    for (final c in _c?.values ?? const <TextEditingController>[]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Carregando(ref.watch(configProvider), builder: (cfg) {
      final m = cfg.mensagens;
      final c = _c ??= {
        'domingoCabecalho': TextEditingController(text: m.domingoCabecalho),
        'domingoBloco': TextEditingController(text: m.domingoBloco),
        'domingoRodape': TextEditingController(text: m.domingoRodape),
        'quinta': TextEditingController(text: m.quinta),
      };
      Widget campo(String chave, String rotulo) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: c[chave],
              maxLines: null,
              minLines: 4,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(labelText: rotulo, border: const OutlineInputBorder()),
            ),
          );
      return Scaffold(
        appBar: AppBar(
          title: const Text('Textos das mensagens'),
          actions: [
            TextButton(
              onPressed: () {
                c['domingoCabecalho']!.text = ModelosMensagem.padraoDomingoCabecalho;
                c['domingoBloco']!.text = ModelosMensagem.padraoDomingoBloco;
                c['domingoRodape']!.text = ModelosMensagem.padraoDomingoRodape;
                c['quinta']!.text = ModelosMensagem.padraoQuinta;
              },
              child: const Text('Padrão'),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                await ref.read(repoProvider).salvarConfiguracao(cfg.copyWith(
                      mensagens: ModelosMensagem(
                        domingoCabecalho: c['domingoCabecalho']!.text,
                        domingoBloco: c['domingoBloco']!.text,
                        domingoRodape: c['domingoRodape']!.text,
                        quinta: c['quinta']!.text,
                      ),
                    ));
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
        body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Placeholders: {saudacao} {diaSemana} {data} {nomeFesta} {escalaAtualizada} '
              '{hora} {animador} {leitura1} {leitura2} {leitura3} {epistola} {preces}.\n'
              'Uma linha com placeholder de função que a missa não tem é removida junto com o rótulo acima dela.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          campo('domingoCabecalho', 'Domingo/festa — cabeçalho'),
          campo('domingoBloco', 'Domingo/festa — bloco de cada missa'),
          campo('domingoRodape', 'Domingo/festa — rodapé'),
          campo('quinta', 'Quinta'),
        ]),
      );
    });
  }
}
