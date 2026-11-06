import 'modelos.dart';

/// Quantas vezes o dia da semana de [d] já ocorreu no mês até [d] (1–5).
int posicaoNoMes(DateTime d) => (d.day - 1) ~/ 7 + 1;

int diasNoMes(int ano, int mes) => DateTime.utc(ano, mes + 1, 0).day;

/// Se [d] é a última ocorrência do seu dia da semana no mês.
bool ehUltimaDoMes(DateTime d) => d.day + 7 > diasNoMes(d.year, d.month);

int? _diaMesParaNumero(String? ddmm) {
  if (ddmm == null) return null;
  final p = ddmm.split('/');
  if (p.length < 2) return null;
  final dia = int.tryParse(p[0].trim());
  final mes = int.tryParse(p[1].trim());
  if (dia == null || mes == null) return null;
  return mes * 100 + dia;
}

bool _abrange(RegraEpoca r, Celebracao c) {
  switch (r.abrangencia) {
    case Abrangencia.todas:
      return true;
    case Abrangencia.domingos:
      return c.data.weekday == DateTime.sunday;
    case Abrangencia.quintas:
      return c.data.weekday == DateTime.thursday;
    case Abrangencia.festas:
      return c.tipo == TipoCelebracao.festa || c.tipo == TipoCelebracao.especial;
    case Abrangencia.horario:
      return r.horario != null && r.horario == c.hora;
  }
}

bool _casaData(RegraEpoca r, DateTime d) {
  switch (r.padrao) {
    case PadraoData.periodoFixo:
      if (r.inicio == null || r.fim == null) return false;
      return !d.isBefore(soDia(r.inicio!)) && !d.isAfter(soDia(r.fim!));
    case PadraoData.anualRecorrente:
      final ini = _diaMesParaNumero(r.diaMesInicio);
      final fim = _diaMesParaNumero(r.diaMesFim);
      if (ini == null || fim == null) return false;
      final md = d.month * 100 + d.day;
      return ini <= fim ? (md >= ini && md <= fim) : (md >= ini || md <= fim);
    case PadraoData.faixaDiasMes:
      if (r.diaDe == null || r.diaAte == null) return false;
      return d.day >= r.diaDe! && d.day <= r.diaAte!;
    case PadraoData.posicaoNoMes:
      return r.posicoes.contains(posicaoNoMes(d)) || (r.posicoes.contains(5) && ehUltimaDoMes(d));
  }
}

/// Se a regra vale para a celebração (vigência, abrangência e data).
bool regraAplica(RegraEpoca r, Celebracao c) {
  final d = soDia(c.data);
  if (r.vigenciaDe != null && d.isBefore(soDia(r.vigenciaDe!))) return false;
  if (r.vigenciaAte != null && d.isAfter(soDia(r.vigenciaAte!))) return false;
  return _abrange(r, c) && _casaData(r, d);
}

/// Avalia as regras de época de um leitor para uma celebração.
///
/// Impedimento vence tudo. Preferências e "prefere não" se compensam.
Avaliacao avaliar(Leitor leitor, Celebracao celebracao) {
  var saldo = 0;
  for (final r in leitor.regras) {
    if (!regraAplica(r, celebracao)) continue;
    switch (r.tipo) {
      case TipoRegra.impedimento:
        return Avaliacao.bloqueado;
      case TipoRegra.preferencia:
        saldo++;
      case TipoRegra.prefereNao:
        saldo--;
    }
  }
  if (saldo > 0) return Avaliacao.bonus;
  if (saldo < 0) return Avaliacao.penalidade;
  return Avaliacao.neutro;
}

/// Avaliação de um dia inteiro (para o mini calendário da ficha),
/// considerando uma celebração genérica do tipo informado.
Avaliacao avaliarDia(Leitor leitor, DateTime dia, {String hora = '00:00'}) {
  final tipo = switch (dia.weekday) {
    DateTime.sunday => TipoCelebracao.domingo,
    DateTime.thursday => TipoCelebracao.quinta,
    _ => TipoCelebracao.especial,
  };
  return avaliar(
    leitor,
    Celebracao(id: -1, data: soDia(dia), hora: hora, tipo: tipo, funcoes: const []),
  );
}

String descreverRegra(RegraEpoca r) {
  String dt(DateTime? d) => d == null
      ? '?'
      : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  final quando = switch (r.padrao) {
    PadraoData.periodoFixo => 'de ${dt(r.inicio)} a ${dt(r.fim)}',
    PadraoData.anualRecorrente => 'todo ano de ${r.diaMesInicio ?? '?'} a ${r.diaMesFim ?? '?'}',
    PadraoData.faixaDiasMes => 'dias ${r.diaDe ?? '?'} a ${r.diaAte ?? '?'} de todo mês',
    PadraoData.posicaoNoMes => '${(r.posicoes.toList()..sort()).map((p) => p == 5 ? 'último' : '$pº').join(', ')} do mês',
  };
  final onde = r.abrangencia == Abrangencia.horario
      ? 'missa das ${r.horario ?? '?'}'
      : r.abrangencia.rotulo.toLowerCase();
  final base = '${r.tipo.rotulo}: $onde, $quando';
  return r.descricao.isEmpty ? base : '$base — ${r.descricao}';
}
