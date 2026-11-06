import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/abc_parser.dart';
import '../core/mensagens.dart';
import '../core/modelos.dart';
import '../data/repositorio.dart';

const urlListaAbc = 'https://diocesesa.org.br/abc-liturgico/';
const userAgentApp = 'ManejadorLeitoresABC/1.0 (+https://github.com/BigMiranda/Manejador_de_Leitores_ABC)';

class ResultadoSincronizacao {
  const ResultadoSincronizacao({required this.edicoes, required this.ok, required this.naoPublicado, this.erro});
  final int edicoes;
  final int ok;
  final int naoPublicado;
  final String? erro;

  String get resumo {
    final base = '$ok PDF(s) ok, $naoPublicado ainda não publicado(s)';
    return erro == null ? '$base ($edicoes edições na lista).' : '$base. Aviso: $erro';
  }
}

/// Coleta da liturgia no ABC Litúrgico (Diocese de Santo André).
///
/// Faz no máximo uma busca da página de listagem por execução do app (ou
/// da tarefa em segundo plano); depois usa a lista guardada no banco.
class AbcServico {
  AbcServico(this.repo, {http.Client? client, Future<Directory> Function()? pastaCache})
      : _client = client ?? http.Client(),
        _pastaCache = pastaCache ?? (() async => Directory(p.join((await getApplicationSupportDirectory()).path, 'abc')));

  final Repositorio repo;
  final http.Client _client;
  final Future<Directory> Function() _pastaCache;

  static bool _buscouNestaExecucao = false;
  static const _headers = {'User-Agent': userAgentApp};

  /// Lista guardada da última busca.
  Future<List<EdicaoAbc>> listaEmCache() async {
    final s = await repo.valor('abcEdicoes');
    if (s == null) return const [];
    return [
      for (final e in jsonDecode(s) as List)
        EdicaoAbc(
          nome: e['nome'] as String,
          data: parseDataIso(e['data'] as String),
          pdfUrl: e['pdfUrl'] as String,
          folhetoUrl: e['folhetoUrl'] as String?,
        ),
    ];
  }

  Future<DateTime?> ultimaBusca() async {
    final s = await repo.valor('abcSincronizadoEm');
    return s == null ? null : DateTime.tryParse(s);
  }

  /// Busca a página (uma vez por execução) e guarda a lista.
  /// Com [forcar], ignora o limite (botão "Sincronizar ABC agora").
  Future<List<EdicaoAbc>> buscarLista({bool forcar = false}) async {
    if (_buscouNestaExecucao && !forcar) return listaEmCache();
    _buscouNestaExecucao = true;
    final resp = await _client.get(Uri.parse(urlListaAbc), headers: _headers).timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) throw HttpException('ABC Litúrgico respondeu ${resp.statusCode}');
    final edicoes = parseAbcLiturgico(utf8.decode(resp.bodyBytes, allowMalformed: true));
    if (edicoes.isEmpty) throw const FormatException('Não encontrei edições na página (layout mudou?)');
    // Mescla com a lista anterior para não perder edições que saíram da 1ª página.
    final porData = {for (final e in await listaEmCache()) dataIso(e.data): e};
    for (final e in edicoes) {
      porData[dataIso(e.data)] = e;
    }
    final lista = porData.values.toList()..sort((a, b) => b.data.compareTo(a.data));
    await repo.definirValor(
      'abcEdicoes',
      jsonEncode([
        for (final e in lista.take(200))
          {'nome': e.nome, 'data': dataIso(e.data), 'pdfUrl': e.pdfUrl, 'folhetoUrl': e.folhetoUrl},
      ]),
    );
    await repo.definirValor('abcSincronizadoEm', DateTime.now().toIso8601String());
    return lista;
  }

  /// Plano B: lista de PDFs da biblioteca de mídia do WordPress (sem data da
  /// missa), para o usuário escolher à mão.
  Future<List<(String, String)>> buscarPdfsNaMidia(String termo) async {
    final uri = Uri.parse('https://diocesesa.org.br/wp-json/wp/v2/media').replace(queryParameters: {
      'mime_type': 'application/pdf',
      'search': termo,
      'per_page': '50',
    });
    final resp = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) throw HttpException('API de mídia respondeu ${resp.statusCode}');
    return [
      for (final m in jsonDecode(utf8.decode(resp.bodyBytes)) as List)
        (
          _semEntidades(((m['title'] as Map?)?['rendered'] as String?) ?? ''),
          ((m['guid'] as Map?)?['rendered'] as String?) ?? (m['source_url'] as String? ?? ''),
        ),
    ].where((x) => x.$2.toLowerCase().endsWith('.pdf')).toList();
  }

  String _semEntidades(String s) => s
      .replaceAll('&#8211;', '–')
      .replaceAll('&#8212;', '—')
      .replaceAll('&amp;', '&')
      .replaceAll('&#8217;', '’');

  Future<File> _baixarPdf(String url) async {
    final pasta = await _pastaCache();
    await pasta.create(recursive: true);
    final arquivo = File(p.join(pasta.path, p.basename(Uri.parse(url).path)));
    if (await arquivo.exists() && await arquivo.length() > 0) return arquivo;
    final resp = await _client.get(Uri.parse(url), headers: _headers).timeout(const Duration(minutes: 2));
    if (resp.statusCode != 200) throw HttpException('PDF respondeu ${resp.statusCode}');
    await arquivo.writeAsBytes(resp.bodyBytes, flush: true);
    return arquivo;
  }

  /// Para domingos e festas entre [de] e [ate]: associa o PDF pela DATA,
  /// baixa para o cache e marca "PDF ok" ou "ainda não publicado".
  Future<ResultadoSincronizacao> sincronizarPeriodo(DateTime de, DateTime ate, {bool forcarBusca = false}) async {
    String? erro;
    List<EdicaoAbc> edicoes;
    try {
      edicoes = await buscarLista(forcar: forcarBusca);
    } catch (e) {
      erro = 'sem acesso ao site ($e); usando a lista guardada';
      edicoes = await listaEmCache();
    }
    final porData = indexarPorData(edicoes);
    var ok = 0;
    var nao = 0;
    for (final c in await repo.celebracoesEntre(de, ate)) {
      if (c.tipo != TipoCelebracao.domingo && c.tipo != TipoCelebracao.festa) continue;
      if (c.pdfStatus == StatusPdf.ok && c.pdfArquivo != null && await File(c.pdfArquivo!).exists()) {
        ok++;
        continue;
      }
      final url = porData[soDia(c.data)]?.pdfUrl ?? c.pdfUrl;
      if (url == null) {
        await repo.atualizarPdf(c.id, status: StatusPdf.naoPublicado);
        nao++;
        continue;
      }
      try {
        final f = await _baixarPdf(url);
        await repo.atualizarPdf(c.id, url: url, arquivo: f.path, status: StatusPdf.ok);
        ok++;
      } catch (e) {
        erro ??= 'falha ao baixar PDF ($e)';
        await repo.atualizarPdf(c.id, url: url, status: StatusPdf.pendente);
        nao++;
      }
    }
    return ResultadoSincronizacao(edicoes: edicoes.length, ok: ok, naoPublicado: nao, erro: erro);
  }

  /// Nome da edição do ABC para o dia (da lista guardada), se houver.
  Future<String?> nomeDaEdicao(DateTime dia) async => indexarPorData(await listaEmCache())[soDia(dia)]?.nome;

  /// Cópia do PDF em cache com nome legível, para compartilhar:
  /// "Liturgia Missa 08-11-2026 32º domingo do tempo comum.pdf".
  Future<File> pdfParaCompartilhar(Celebracao c) async {
    final nome = await nomeDaEdicao(c.data) ?? c.nomeLiturgico;
    final pasta = Directory(p.join((await getTemporaryDirectory()).path, 'liturgia'));
    await pasta.create(recursive: true);
    return File(c.pdfArquivo!).copy(p.join(pasta.path, nomeArquivoLiturgia(c.data, nome)));
  }

  /// Baixa o PDF de uma URL colada à mão para uma celebração.
  Future<void> definirPdfManual(Celebracao c, String url) async {
    final f = await _baixarPdf(url);
    await repo.atualizarPdf(c.id, url: url, arquivo: f.path, status: StatusPdf.ok);
  }

  /// Festas fora do domingo listadas no ABC para o mês, que ainda não
  /// têm celebração cadastrada naquele dia.
  Future<List<EdicaoAbc>> sugestoesDeFestas(int ano, int mes, List<Celebracao> doMes) async {
    final dias = doMes.map((c) => soDia(c.data)).toSet();
    return [
      for (final e in await listaEmCache())
        if (e.data.year == ano &&
            e.data.month == mes &&
            e.data.weekday != DateTime.sunday &&
            !dias.contains(soDia(e.data)))
          e,
    ]..sort((a, b) => a.data.compareTo(b.data));
  }
}
