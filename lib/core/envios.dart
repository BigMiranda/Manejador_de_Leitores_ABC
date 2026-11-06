import 'mensagens.dart';
import 'modelos.dart';

/// Um dia com celebrações que pede mensagem na véspera.
class DiaDeEnvio {
  const DiaDeEnvio(this.dia, this.celebracoes, {required this.enviado});
  final DateTime dia;
  final List<Celebracao> celebracoes;
  final bool enviado;

  /// A mensagem é sempre enviada um dia antes.
  DateTime get diaDoEnvio => dia.subtract(const Duration(days: 1));
  bool get comPdf => levaPdf(celebracoes);

  /// Pendente a partir da véspera; atrasado se já é o próprio dia.
  bool pendente(DateTime hoje) => !enviado && !soDia(hoje).isBefore(diaDoEnvio) && !soDia(hoje).isAfter(dia);
  bool atrasado(DateTime hoje) => pendente(hoje) && soDia(hoje) == dia;
}

/// Agrupa as celebrações por dia. Dias só de comunidade não têm mensagem.
List<DiaDeEnvio> diasDeEnvio(List<Celebracao> celebracoes, Set<DateTime> enviados) {
  final porDia = <DateTime, List<Celebracao>>{};
  for (final c in celebracoes) {
    porDia.putIfAbsent(soDia(c.data), () => []).add(c);
  }
  final out = <DiaDeEnvio>[];
  for (final e in porDia.entries) {
    final comMensagem = e.value.where((c) => c.atribuicao != Atribuicao.comunidade).toList()
      ..sort((a, b) => a.instante.compareTo(b.instante));
    if (comMensagem.isEmpty) continue;
    out.add(DiaDeEnvio(e.key, comMensagem, enviado: enviados.contains(e.key)));
  }
  return out..sort((a, b) => a.dia.compareTo(b.dia));
}
