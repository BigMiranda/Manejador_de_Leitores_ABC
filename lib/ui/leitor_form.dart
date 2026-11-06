import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/configuracao.dart';
import '../core/escala.dart';
import '../core/modelos.dart';
import '../core/regras_epoca.dart';
import '../state/providers.dart';
import 'comum.dart';
import 'tabela_exportacao.dart';

const _outraPastoral = '__outra__';

class LeitorFormPage extends ConsumerStatefulWidget {
  const LeitorFormPage({super.key, this.leitor});
  final Leitor? leitor;

  @override
  ConsumerState<LeitorFormPage> createState() => _LeitorFormPageState();
}

class _LeitorFormPageState extends ConsumerState<LeitorFormPage> {
  late Leitor _l = widget.leitor ?? const Leitor(id: 0, nome: '');
  late final _nome = TextEditingController(text: _l.nome);
  late final _obs = TextEditingController(text: _l.observacoes);
  late final _outra = TextEditingController(
    text: _l.soPastoral != null && !_pastoraisConhecidas.contains(_l.soPastoral) ? _l.soPastoral : '',
  );
  String? _erroNome;
  late final String _assinaturaInicial;

  static const _pastoraisConhecidas = [pastoralTercoHomens, pastoralTercoMulheres];

  @override
  void initState() {
    super.initState();
    _assinaturaInicial = _assinatura();
  }

  /// Retrato do formulário, para saber se houve alteração.
  String _assinatura() => jsonEncode({
        'nome': _nome.text.trim(),
        'obs': _obs.text.trim(),
        'outra': _outra.text.trim(),
        'vaiLer': _l.vaiLer,
        'anima': _l.fazAnimacao.name,
        'domingo': _l.leDomingo,
        'horarios': _l.horariosDomingo.toList()..sort(),
        'quinta': _l.leQuinta.name,
        'festa': _l.leFesta,
        'pastoral': _l.soPastoral,
        'par': _l.parId,
        'ultima': _l.ultimaParticipacao?.toIso8601String(),
        'regras': [for (final r in _l.regras) r.toJson()],
      });

  bool get _modificado => _assinatura() != _assinaturaInicial;

  /// Voltar com alterações: salvar, descartar ou continuar editando.
  Future<void> _aoVoltar() async {
    if (!_modificado) {
      Navigator.pop(context);
      return;
    }
    final escolha = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Salvar as alterações?'),
        content: const Text('Você modificou este leitor.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, 'descartar'), child: const Text('Descartar')),
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Continuar editando')),
          FilledButton(onPressed: () => Navigator.pop(c, 'salvar'), child: const Text('Salvar')),
        ],
      ),
    );
    if (!mounted) return;
    if (escolha == 'salvar') {
      await _salvar();
    } else if (escolha == 'descartar') {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _obs.dispose();
    _outra.dispose();
    super.dispose();
  }

  void _set(Leitor l) => setState(() => _l = l);

  Future<void> _salvar() async {
    final repo = ref.read(repoProvider);
    final nome = _nome.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    String? erro;
    if (nome.isEmpty) {
      erro = 'Informe o nome';
    } else {
      final outro = await repo.leitorComNome(nome, excetoId: _l.id == 0 ? null : _l.id);
      if (outro != null) {
        erro = outro.excluidoEm == null
            ? 'Já existe um leitor com esse nome'
            : 'Há um leitor excluído com esse nome: restaure em Configurações > Backup';
      }
    }
    if (erro != null) {
      setState(() => _erroNome = erro);
      return;
    }
    if (_l.leDomingo && _l.horariosDomingo.isEmpty) {
      if (mounted) avisar(context, 'Marque pelo menos um horário de domingo.');
      return;
    }
    var soPastoral = _l.soPastoral;
    final cfg = ref.read(configProvider).value ?? const Configuracao();
    final conhecidas = {..._pastoraisConhecidas, ...cfg.pastorais.map((p) => p.nome)};
    if (soPastoral != null && !conhecidas.contains(soPastoral)) {
      soPastoral = _outra.text.trim().isEmpty ? null : _outra.text.trim();
    }
    await repo.salvarLeitor(_l.copyWith(nome: nome, observacoes: _obs.text.trim(), soPastoral: () => soPastoral));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir() async {
    if (!await confirmarExclusaoLeitores(context, [_l.nome])) return;
    await ref.read(repoProvider).excluirLeitores([_l.id]);
    if (!mounted) return;
    avisarComDesfazer(context, ref, '${_l.nome} excluído');
    Navigator.pop(context);
  }

  Future<void> _editarRegra([int? indice]) async {
    final r = await Navigator.push<RegraEpoca>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RegraPage(regra: indice == null ? null : _l.regras[indice]),
      ),
    );
    if (r == null) return;
    final regras = [..._l.regras];
    indice == null ? regras.add(r) : regras[indice] = r;
    _set(_l.copyWith(regras: regras));
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(configProvider).value ?? const Configuracao();
    final todos = ref.watch(leitoresProvider).value ?? const <Leitor>[];
    final hist = ref.watch(historicoCompletoProvider).value ?? const {};
    final horasDomingo = {...cfg.missasDomingo.map((m) => m.hora), ..._l.horariosDomingo}.toList()..sort();
    final pastorais = {..._pastoraisConhecidas, ...cfg.pastorais.map((p) => p.nome)}.toList();
    final valorPastoral = _l.soPastoral == null
        ? null
        : pastorais.contains(_l.soPastoral)
            ? _l.soPastoral
            : _outraPastoral;
    final ultimaHist = _l.id == 0 ? null : Historico(hist).ultimaAntes(_l.copyWith(ultimaParticipacao: () => null),
        DateTime.now().toUtc().add(const Duration(days: 1)));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _aoVoltar();
      },
      child: _corpo(context, cfg, todos, horasDomingo, pastorais, valorPastoral, ultimaHist),
    );
  }

  Widget _corpo(
    BuildContext context,
    Configuracao cfg,
    List<Leitor> todos,
    List<String> horasDomingo,
    List<String> pastorais,
    String? valorPastoral,
    DateTime? ultimaHist,
  ) {
    return TelaSegura(
      appBar: AppBar(
        title: Text(_l.id == 0 ? 'Novo leitor' : 'Editar leitor'),
        actions: [
          if (_l.id != 0)
            IconButton(tooltip: 'Excluir', icon: const Icon(Icons.delete_outline), onPressed: _excluir),
          IconButton(tooltip: 'Salvar', icon: const Icon(Icons.check), onPressed: _salvar),
        ],
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _nome,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nome (como aparece na escala)',
              border: const OutlineInputBorder(),
              errorText: _erroNome,
            ),
            onChanged: (_) => setState(() => _erroNome = null),
          ),
        ),
        SwitchListTile(
          title: const Text('Vai ler?'),
          subtitle: const Text('"Não" tira o leitor de toda geração automática'),
          value: _l.vaiLer,
          onChanged: (v) => _set(_l.copyWith(vaiLer: v)),
        ),
        const Secao('Animação'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<FazAnimacao>(
            segments: [for (final f in FazAnimacao.values) ButtonSegment(value: f, label: Text(f.rotulo))],
            selected: {_l.fazAnimacao},
            showSelectedIcon: false,
            onSelectionChanged: (s) => _set(_l.copyWith(fazAnimacao: s.first)),
          ),
        ),
        const Secao('Disponibilidade'),
        SwitchListTile(
          title: const Text('Consegue ler de domingo?'),
          value: _l.leDomingo,
          onChanged: (v) => _set(_l.copyWith(leDomingo: v)),
        ),
        if (_l.leDomingo)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, children: [
              const Padding(padding: EdgeInsets.only(top: 8), child: Text('Lê nas missas das')),
              for (final h in horasDomingo)
                FilterChip(
                  label: Text(horaExibicao(h)),
                  selected: _l.horariosDomingo.contains(h),
                  onSelected: (s) => _set(_l.copyWith(
                    horariosDomingo: s ? {..._l.horariosDomingo, h} : ({..._l.horariosDomingo}..remove(h)),
                  )),
                ),
            ]),
          ),
        ListTile(
          title: const Text('Consegue ler de quinta 19h30?'),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<LeQuinta>(
              segments: [for (final q in LeQuinta.values) ButtonSegment(value: q, label: Text(q.rotulo))],
              selected: {_l.leQuinta},
              showSelectedIcon: false,
              onSelectionChanged: (s) => _set(_l.copyWith(leQuinta: s.first)),
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Consegue ler em missa de feriado/festa?'),
          value: _l.leFesta,
          onChanged: (v) => _set(_l.copyWith(leFesta: v)),
        ),
        ListTile(
          title: const Text('Só lê pela pastoral?'),
          subtitle: DropdownButton<String?>(
            isExpanded: true,
            value: valorPastoral,
            items: [
              const DropdownMenuItem(value: null, child: Text('Não')),
              for (final p in pastorais) DropdownMenuItem(value: p, child: Text(p)),
              const DropdownMenuItem(value: _outraPastoral, child: Text('Outra')),
            ],
            onChanged: (v) => _set(_l.copyWith(soPastoral: () => v)),
          ),
        ),
        if (valorPastoral == _outraPastoral)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _outra,
              decoration: const InputDecoration(labelText: 'Nome da pastoral', border: OutlineInputBorder()),
            ),
          ),
        Secao('Épocas (preferência e impedimento)',
            trailing: TextButton.icon(
              onPressed: _editarRegra,
              icon: const Icon(Icons.add),
              label: const Text('Regra'),
            )),
        if (_l.regras.isEmpty) const ListTile(dense: true, title: Text('Nenhuma regra.')),
        for (final (i, r) in _l.regras.indexed)
          ListTile(
            dense: true,
            leading: Icon(
              r.tipo == TipoRegra.impedimento
                  ? Icons.block
                  : r.tipo == TipoRegra.preferencia
                      ? Icons.thumb_up_outlined
                      : Icons.thumb_down_outlined,
              color: r.tipo == TipoRegra.impedimento ? Colors.red : null,
            ),
            title: Text(descreverRegra(r)),
            onTap: () => _editarRegra(i),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _set(_l.copyWith(regras: [..._l.regras]..removeAt(i))),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: MiniCalendario(leitor: _l, config: cfg),
        ),
        const Secao('Prefere ler junto com'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<int?>(
            isExpanded: true,
            value: todos.any((o) => o.id == _l.parId) ? _l.parId : null,
            items: [
              const DropdownMenuItem(value: null, child: Text('Ninguém')),
              for (final o in todos.where((o) => o.id != _l.id))
                DropdownMenuItem(value: o.id, child: Text(o.nome)),
            ],
            onChanged: (v) => _set(_l.copyWith(parId: () => v)),
          ),
        ),
        const Secao('Última participação'),
        ListTile(
          title: Text(_l.ultimaParticipacao == null ? 'Não informada' : dataLongaBr(_l.ultimaParticipacao!)),
          subtitle: Text(ultimaHist == null
              ? 'Sem participação no histórico. Informe para dar a carga inicial.'
              : 'Pelo histórico: ${dataLongaBr(ultimaHist)}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (_l.ultimaParticipacao != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _set(_l.copyWith(ultimaParticipacao: () => null)),
              ),
            IconButton(
              icon: const Icon(Icons.edit_calendar),
              onPressed: () async {
                final d = await escolherData(context, _l.ultimaParticipacao);
                if (d != null) _set(_l.copyWith(ultimaParticipacao: () => d));
              },
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _obs,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Observações', border: OutlineInputBorder()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(onPressed: _salvar, icon: const Icon(Icons.check), label: const Text('Salvar')),
        ),
      ]),
    );
  }
}

/// Calendário dos próximos 3 meses com datas bloqueadas e preferidas.
class MiniCalendario extends StatelessWidget {
  const MiniCalendario({super.key, required this.leitor, required this.config});
  final Leitor leitor;
  final Configuracao config;

  Avaliacao? _dia(DateTime d) {
    final horas = switch (d.weekday) {
      DateTime.sunday => config.missasDomingo.map((m) => m.hora).toList(),
      DateTime.thursday => config.missasQuinta.map((m) => m.hora).toList(),
      _ => <String>[],
    };
    if (horas.isEmpty) return null;
    final tipo = d.weekday == DateTime.sunday ? TipoCelebracao.domingo : TipoCelebracao.quinta;
    final avs = [
      for (final h in horas) avaliar(leitor, Celebracao(id: -1, data: d, hora: h, tipo: tipo, funcoes: const [])),
    ];
    if (avs.every((a) => a == Avaliacao.bloqueado)) return Avaliacao.bloqueado;
    if (avs.contains(Avaliacao.bloqueado)) return Avaliacao.penalidade;
    if (avs.contains(Avaliacao.bonus)) return Avaliacao.bonus;
    if (avs.contains(Avaliacao.penalidade)) return Avaliacao.penalidade;
    return Avaliacao.neutro;
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final meses = [for (var i = 0; i < 3; i++) DateTime.utc(hoje.year, hoje.month + i, 1)];
    return Column(children: [
      Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
        for (final m in meses) _mes(context, m),
      ]),
      const SizedBox(height: 6),
      const Wrap(spacing: 12, children: [
        _Legenda(Colors.red, 'bloqueado'),
        _Legenda(Colors.orange, 'parcial / prefere não'),
        _Legenda(Colors.green, 'preferido'),
      ]),
    ]);
  }

  Widget _mes(BuildContext context, DateTime m) {
    final dias = diasNoMes(m.year, m.month);
    final vazios = DateTime.utc(m.year, m.month, 1).weekday % 7; // domingo primeiro
    return SizedBox(
      width: 7 * 22,
      child: Column(children: [
        Text('${mesesExtenso[m.month - 1]} ${m.year}', style: Theme.of(context).textTheme.labelMedium),
        Row(children: [
          for (final d in const ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'])
            SizedBox(width: 22, child: Center(child: Text(d, style: const TextStyle(fontSize: 10)))),
        ]),
        Wrap(children: [
          for (var i = 0; i < vazios; i++) const SizedBox(width: 22, height: 20),
          for (var d = 1; d <= dias; d++) _celula(DateTime.utc(m.year, m.month, d)),
        ]),
      ]),
    );
  }

  Widget _celula(DateTime d) {
    final a = _dia(d);
    final cor = switch (a) {
      Avaliacao.bloqueado => Colors.red,
      Avaliacao.penalidade => Colors.orange,
      Avaliacao.bonus => Colors.green,
      _ => null,
    };
    return Container(
      width: 22,
      height: 20,
      alignment: Alignment.center,
      decoration: cor == null ? null : BoxDecoration(color: cor.withValues(alpha: 0.75), shape: BoxShape.circle),
      child: Text(
        '${d.day}',
        style: TextStyle(
          fontSize: 10,
          color: cor != null ? Colors.white : (a == null ? Colors.grey : null),
          fontWeight: a != null ? FontWeight.bold : null,
        ),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda(this.cor, this.texto);
  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 11)),
      ]);
}

/// Edição de uma regra de época.
class RegraPage extends StatefulWidget {
  const RegraPage({super.key, this.regra});
  final RegraEpoca? regra;

  @override
  State<RegraPage> createState() => _RegraPageState();
}

class _RegraPageState extends State<RegraPage> {
  late RegraEpoca _r = widget.regra ?? const RegraEpoca();
  late final _desc = TextEditingController(text: _r.descricao);
  late final _diaMesIni = TextEditingController(text: _r.diaMesInicio ?? '');
  late final _diaMesFim = TextEditingController(text: _r.diaMesFim ?? '');
  late final _diaDe = TextEditingController(text: _r.diaDe?.toString() ?? '');
  late final _diaAte = TextEditingController(text: _r.diaAte?.toString() ?? '');
  String? _erro;

  @override
  void dispose() {
    for (final c in [_desc, _diaMesIni, _diaMesFim, _diaDe, _diaAte]) {
      c.dispose();
    }
    super.dispose();
  }

  RegraEpoca _montar() => RegraEpoca(
        tipo: _r.tipo,
        abrangencia: _r.abrangencia,
        horario: _r.abrangencia == Abrangencia.horario ? (_r.horario ?? '18:00') : null,
        padrao: _r.padrao,
        inicio: _r.padrao == PadraoData.periodoFixo ? _r.inicio : null,
        fim: _r.padrao == PadraoData.periodoFixo ? _r.fim : null,
        diaMesInicio: _r.padrao == PadraoData.anualRecorrente ? _diaMesIni.text.trim() : null,
        diaMesFim: _r.padrao == PadraoData.anualRecorrente ? _diaMesFim.text.trim() : null,
        diaDe: _r.padrao == PadraoData.faixaDiasMes ? int.tryParse(_diaDe.text) : null,
        diaAte: _r.padrao == PadraoData.faixaDiasMes ? int.tryParse(_diaAte.text) : null,
        posicoes: _r.padrao == PadraoData.posicaoNoMes ? _r.posicoes : const {},
        vigenciaDe: _r.vigenciaDe,
        vigenciaAte: _r.vigenciaAte,
        descricao: _desc.text.trim(),
      );

  String? _validar(RegraEpoca r) {
    bool diaMes(String? s) {
      final m = RegExp(r'^(\d{1,2})/(\d{1,2})$').firstMatch(s ?? '');
      if (m == null) return false;
      final d = int.parse(m.group(1)!), mes = int.parse(m.group(2)!);
      return mes >= 1 && mes <= 12 && d >= 1 && d <= 31;
    }

    switch (r.padrao) {
      case PadraoData.periodoFixo:
        if (r.inicio == null || r.fim == null) return 'Escolha as duas datas';
        if (r.fim!.isBefore(r.inicio!)) return 'A data final é antes da inicial';
      case PadraoData.anualRecorrente:
        if (!diaMes(r.diaMesInicio) || !diaMes(r.diaMesFim)) return 'Use o formato dd/mm (ex.: 15/12)';
      case PadraoData.faixaDiasMes:
        if (r.diaDe == null || r.diaAte == null || r.diaDe! < 1 || r.diaAte! > 31 || r.diaDe! > r.diaAte!) {
          return 'Informe dias entre 1 e 31 (de ≤ até)';
        }
      case PadraoData.posicaoNoMes:
        if (r.posicoes.isEmpty) return 'Escolha pelo menos uma posição';
    }
    return null;
  }

  Widget _data(String rotulo, DateTime? valor, void Function(DateTime?) mudar) => ListTile(
        dense: true,
        title: Text(rotulo),
        subtitle: Text(valor == null ? '—' : dataLongaBr(valor)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (valor != null) IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => mudar(null))),
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () async {
              final d = await escolherData(context, valor);
              if (d != null) setState(() => mudar(d));
            },
          ),
        ]),
      );

  RegraEpoca _com({
    TipoRegra? tipo,
    Abrangencia? abrangencia,
    String? horario,
    PadraoData? padrao,
    DateTime? Function()? inicio,
    DateTime? Function()? fim,
    Set<int>? posicoes,
    DateTime? Function()? vigenciaDe,
    DateTime? Function()? vigenciaAte,
  }) =>
      RegraEpoca(
        tipo: tipo ?? _r.tipo,
        abrangencia: abrangencia ?? _r.abrangencia,
        horario: horario ?? _r.horario,
        padrao: padrao ?? _r.padrao,
        inicio: inicio != null ? inicio() : _r.inicio,
        fim: fim != null ? fim() : _r.fim,
        diaMesInicio: _r.diaMesInicio,
        diaMesFim: _r.diaMesFim,
        diaDe: _r.diaDe,
        diaAte: _r.diaAte,
        posicoes: posicoes ?? _r.posicoes,
        vigenciaDe: vigenciaDe != null ? vigenciaDe() : _r.vigenciaDe,
        vigenciaAte: vigenciaAte != null ? vigenciaAte() : _r.vigenciaAte,
        descricao: _r.descricao,
      );

  @override
  Widget build(BuildContext context) {
    return TelaSegura(
      appBar: AppBar(
        title: Text(widget.regra == null ? 'Nova regra' : 'Editar regra'),
        actions: [
          TextButton(
            onPressed: () {
              final r = _montar();
              final erro = _validar(r);
              if (erro != null) return setState(() => _erro = erro);
              Navigator.pop(context, r);
            },
            child: const Text('OK'),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<TipoRegra>(
            segments: [for (final t in TipoRegra.values) ButtonSegment(value: t, label: Text(t.rotulo))],
            selected: {_r.tipo},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _r = _com(tipo: s.first)),
          ),
        ),
        ListTile(
          title: const Text('Vale para'),
          subtitle: DropdownButton<Abrangencia>(
            isExpanded: true,
            value: _r.abrangencia,
            items: [for (final a in Abrangencia.values) DropdownMenuItem(value: a, child: Text(a.rotulo))],
            onChanged: (v) => setState(() => _r = _com(abrangencia: v)),
          ),
        ),
        if (_r.abrangencia == Abrangencia.horario)
          ListTile(
            title: const Text('Horário'),
            subtitle: Text(_r.horario ?? '18:00'),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final h = await escolherHora(context, _r.horario ?? '18:00');
              if (h != null) setState(() => _r = _com(horario: h));
            },
          ),
        ListTile(
          title: const Text('Quando'),
          subtitle: DropdownButton<PadraoData>(
            isExpanded: true,
            value: _r.padrao,
            items: [for (final p in PadraoData.values) DropdownMenuItem(value: p, child: Text(p.rotulo))],
            onChanged: (v) => setState(() => _r = _com(padrao: v)),
          ),
        ),
        ...switch (_r.padrao) {
          PadraoData.periodoFixo => [
              _data('De', _r.inicio, (d) => _r = _com(inicio: () => d)),
              _data('Até (inclusive)', _r.fim, (d) => _r = _com(fim: () => d)),
            ],
          PadraoData.anualRecorrente => [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _diaMesIni,
                      decoration: const InputDecoration(labelText: 'De (dd/mm)', hintText: '15/12'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _diaMesFim,
                      decoration: const InputDecoration(labelText: 'Até (dd/mm)', hintText: '15/01'),
                    ),
                  ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text('Todo ano. Pode atravessar a virada do ano.', style: TextStyle(fontSize: 12)),
              ),
            ],
          PadraoData.faixaDiasMes => [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _diaDe,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Do dia'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _diaAte,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Até o dia'),
                    ),
                  ),
                ]),
              ),
            ],
          PadraoData.posicaoNoMes => [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(spacing: 8, children: [
                  for (final (p, rot) in [(1, '1º'), (2, '2º'), (3, '3º'), (4, '4º'), (5, 'Último')])
                    FilterChip(
                      label: Text(rot),
                      selected: _r.posicoes.contains(p),
                      onSelected: (s) => setState(() => _r = _com(
                            posicoes: s ? {..._r.posicoes, p} : ({..._r.posicoes}..remove(p)),
                          )),
                    ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text('Do dia da semana da missa (ex.: 1º domingo, último quinta).', style: TextStyle(fontSize: 12)),
              ),
            ],
        },
        const Secao('Vigência (opcional)'),
        _data('Válida de', _r.vigenciaDe, (d) => _r = _com(vigenciaDe: () => d)),
        _data('Válida até', _r.vigenciaAte, (d) => _r = _com(vigenciaAte: () => d)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _desc,
            decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
          ),
        ),
        if (_erro != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ]),
    );
  }
}
