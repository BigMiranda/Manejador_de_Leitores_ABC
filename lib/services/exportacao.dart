import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../data/repositorio.dart';
import '../ui/tabela_exportacao.dart';

/// Exporta a escala do mês como PNG (≥ 1240 px de largura) e PDF A4.
class Exportacao {
  /// 2 × 800 = 1600 px de largura.
  static const pixelRatio = 2.0;

  static Future<Uint8List> png(MesEscala mes, Map<int, String> nomes) {
    final tamanho = TabelaExportacao.tamanho(mes);
    return ScreenshotController().captureFromWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: TabelaExportacao(mes: mes, nomes: nomes),
      ),
      pixelRatio: pixelRatio,
      targetSize: tamanho,
      delay: const Duration(milliseconds: 200),
    );
  }

  static Future<Uint8List> pdf(Uint8List png) async {
    final doc = pw.Document(title: 'Escala dos leitores');
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Align(
        alignment: pw.Alignment.topCenter,
        child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain),
      ),
    ));
    return doc.save();
  }

  static String nomeArquivo(MesEscala mes) =>
      'escala_leitores_${mes.ano}_${mes.mes.toString().padLeft(2, '0')}_${mesesExtenso[mes.mes - 1]}';

  static Future<File> _salvar(String nome, Uint8List bytes) async {
    final pasta = Directory(p.join((await getTemporaryDirectory()).path, 'exportacao'));
    await pasta.create(recursive: true);
    final f = File(p.join(pasta.path, nome));
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  static Future<void> compartilhar(MesEscala mes, Map<int, String> nomes, {required bool comoPdf}) async {
    final imagem = await png(mes, nomes);
    final base = nomeArquivo(mes);
    final arquivo = comoPdf
        ? await _salvar('$base.pdf', await pdf(imagem))
        : await _salvar('$base.png', imagem);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(arquivo.path, mimeType: comoPdf ? 'application/pdf' : 'image/png')],
      subject: 'Escala dos leitores — ${mesesExtenso[mes.mes - 1]} de ${mes.ano}',
    ));
  }
}
