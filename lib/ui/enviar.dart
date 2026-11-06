import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../core/configuracao.dart';
import '../core/envios.dart';
import '../core/mensagens.dart';
import '../core/modelos.dart';
import '../services/notificacoes.dart';
import '../state/providers.dart';
import 'comum.dart';

class _DadosEnvio {
  const _DadosEnvio(this.envio, this.missas, this.modelos);
  final DiaDeEnvio? envio;
  final List<MissaDoDia> missas;
  final ModelosMensagem modelos;

  File? get pdf {
    for (final c in envio?.celebracoes ?? const <Celebracao>[]) {
      if (c.pdfStatus == StatusPdf.ok && c.pdfArquivo != null && File(c.pdfArquivo!).existsSync()) {
        return File(c.pdfArquivo!);
      }
    }
    return null;
  }
}

final _envioProvider = FutureProvider.family<_DadosEnvio, DateTime>((ref, dia) async {
  ref.watch(revisaoProvider);
  final repo = ref.watch(repoProvider);
  final cfg = await ref.watch(configProvider.future);
  final nomes = await ref.watch(nomesProvider.future);
  final cels = await repo.celebracoesEntre(dia, dia);
  final dias = diasDeEnvio(cels, await repo.diasEnviados());
  final envio = dias.isEmpty ? null : dias.first;
  final vagas = await repo.vagasDe(envio?.celebracoes.map((c) => c.id) ?? const []);
  final missas = [
    for (final c in envio?.celebracoes ?? const <Celebracao>[])
      MissaDoDia(c, {
        for (final v in vagas.where((v) => v.celebracaoId == c.id))
          v.funcao: v.leitorId != null ? (nomes[v.leitorId] ?? v.nomeLivre) : v.nomeLivre,
      }),
  ];
  return _DadosEnvio(envio, missas, cfg.mensagens);
});

/// Tela "Enviar": prévia editável, mensagem e PDF para o WhatsApp.
class EnviarPage extends ConsumerStatefulWidget {
  const EnviarPage({super.key, required this.dia});
  final DateTime dia;

  @override
  ConsumerState<EnviarPage> createState() => _EnviarPageState();
}

class _EnviarPageState extends ConsumerState<EnviarPage> {
  final _texto = TextEditingController();
  var _escalaAtualizada = false;
  var _preenchido = false;
  var _baixando = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _gerarTexto(_DadosEnvio d) {
    if (d.missas.isEmpty) return;
    _texto.text = montarMensagem(
      missas: d.missas,
      modelos: d.modelos,
      agora: DateTime.now(),
      escalaAtualizada: _escalaAtualizada,
    );
  }

  Future<void> _enviarMensagem() async {
    await Clipboard.setData(ClipboardData(text: _texto.text));
    await SharePlus.instance.share(ShareParams(text: _texto.text));
  }

  Future<void> _baixarPdf() async {
    setState(() => _baixando = true);
    try {
      final r = await ref.read(abcProvider).sincronizarPeriodo(widget.dia, widget.dia, forcarBusca: true);
      if (mounted) avisar(context, r.resumo);
    } catch (e) {
      if (mounted) avisar(context, 'Falhou: $e');
    } finally {
      if (mounted) setState(() => _baixando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dados = ref.watch(_envioProvider(soDia(widget.dia)));
    final d = widget.dia;
    return Scaffold(
      appBar: AppBar(title: Text('Enviar · ${diaSemanaExtenso(d)} ${dataCurtaBr(d)}')),
      body: Carregando(dados, builder: (dd) {
        if (!_preenchido && dd.missas.isNotEmpty) {
          _preenchido = true;
          _gerarTexto(dd);
        }
        final envio = dd.envio;
        if (envio == null) return const Center(child: Text('Não há celebração com mensagem neste dia.'));
        final pdf = dd.pdf;
        return ListView(padding: const EdgeInsets.all(16), children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Marcar como escala atualizada'),
            subtitle: const Text('Insere a linha "Escala atualizada" (refaz o texto)'),
            value: _escalaAtualizada,
            onChanged: (v) => setState(() {
              _escalaAtualizada = v;
              _gerarTexto(dd);
            }),
          ),
          TextField(
            controller: _texto,
            maxLines: null,
            minLines: 10,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Mensagem (editável só para este envio)',
              suffixIcon: IconButton(
                tooltip: 'Refazer a partir do modelo',
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() => _gerarTexto(dd)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _enviarMensagem,
            icon: const Icon(Icons.send),
            label: const Text('1. Enviar mensagem'),
          ),
          const Text(
            'Também copia o texto. No WhatsApp, escolha o grupo.',
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (envio.comPdf) ...[
            const SizedBox(height: 12),
            if (pdf != null)
              FilledButton.tonalIcon(
                onPressed: () => SharePlus.instance.share(ShareParams(
                  files: [XFile(pdf.path, mimeType: 'application/pdf')],
                )),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('2. Enviar PDF da liturgia'),
              )
            else
              OutlinedButton.icon(
                onPressed: _baixando ? null : _baixarPdf,
                icon: _baixando
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_download_outlined),
                label: const Text('PDF ainda não publicado — tentar baixar'),
              ),
          ],
          const SizedBox(height: 24),
          envio.enviado
              ? OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(repoProvider).marcarEnviado(envio.dia, false);
                    await Notificacoes.reagendar(ref.read(repoProvider));
                  },
                  icon: const Icon(Icons.undo),
                  label: const Text('Enviado — desmarcar'),
                )
              : FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
                  onPressed: () async {
                    await ref.read(repoProvider).marcarEnviado(envio.dia, true);
                    await Notificacoes.reagendar(ref.read(repoProvider));
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Marcar como enviado'),
                ),
        ]);
      }),
    );
  }
}
