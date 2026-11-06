import 'modelos.dart';

/// Domingo de Páscoa (calendário gregoriano, algoritmo de Meeus/Jones/Butcher).
DateTime pascoa(int ano) {
  final a = ano % 19;
  final b = ano ~/ 100;
  final c = ano % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final mes = (h + l - 7 * m + 114) ~/ 31;
  final dia = (h + l - 7 * m + 114) % 31 + 1;
  return DateTime.utc(ano, mes, dia);
}

DateTime _mais(DateTime d, int dias) => DateTime.utc(d.year, d.month, d.day + dias);
bool _domingo(DateTime d) => d.weekday == DateTime.sunday;

const _quatroFuncoes = [Funcao.animador, Funcao.leitura1, Funcao.leitura2, Funcao.preces];

/// Celebrações de dia de semana que a paróquia celebra fora do domingo.
///
/// Só entram as que NÃO são transferidas para o domingo no Brasil
/// (Epifania, Ascensão, São Pedro e São Paulo, Assunção e Todos os Santos
/// vão para o domingo e já estão nas missas de domingo).
class FestaLiturgica {
  const FestaLiturgica({
    required this.chave,
    required this.nome,
    required this.horasPadrao,
    required this.data,
    this.funcoes = _quatroFuncoes,
    this.valeNoDomingo = false,
    this.observacao,
  });

  final String chave;
  final String nome;
  final List<String> horasPadrao;
  final List<Funcao> funcoes;

  /// Data da celebração no ano (já com as transferências litúrgicas).
  final DateTime Function(int ano) data;

  /// Se cair no domingo, cria a celebração à parte mesmo assim.
  final bool valeNoDomingo;
  final String? observacao;
}

DateTime _maeDeDeus(int a) => DateTime.utc(a, 1, 1);
DateTime _cinzas(int a) => _mais(pascoa(a), -46);

DateTime _saoJose(int a) {
  final d = DateTime.utc(a, 3, 19);
  final ramos = _mais(pascoa(a), -7);
  if (!d.isBefore(ramos) && !d.isAfter(pascoa(a))) return _mais(ramos, -1);
  return _domingo(d) ? _mais(d, 1) : d;
}

DateTime _anunciacao(int a) {
  final d = DateTime.utc(a, 3, 25);
  final p = pascoa(a);
  if (!d.isBefore(_mais(p, -7)) && !d.isAfter(_mais(p, 7))) return _mais(p, 8);
  return _domingo(d) ? _mais(d, 1) : d;
}

DateTime _quintaSanta(int a) => _mais(pascoa(a), -3);
DateTime _vigiliaPascal(int a) => _mais(pascoa(a), -1);
DateTime _corpusChristi(int a) => _mais(pascoa(a), 60);
DateTime _sagradoCoracao(int a) => _mais(pascoa(a), 68);

DateTime _saoJoao(int a) {
  final d = DateTime.utc(a, 6, 24);
  return d == _sagradoCoracao(a) ? DateTime.utc(a, 6, 23) : d;
}

DateTime _aparecida(int a) => DateTime.utc(a, 10, 12);
DateTime _finados(int a) => DateTime.utc(a, 11, 2);

DateTime _imaculada(int a) {
  final d = DateTime.utc(a, 12, 8);
  return _domingo(d) ? _mais(d, 1) : d;
}

DateTime _noiteDeNatal(int a) => DateTime.utc(a, 12, 24);
DateTime _natal(int a) => DateTime.utc(a, 12, 25);

const festasLiturgicas = [
  FestaLiturgica(chave: 'maeDeDeus', nome: 'Santa Maria, Mãe de Deus', horasPadrao: ['09:00'], data: _maeDeDeus),
  FestaLiturgica(chave: 'cinzas', nome: 'Quarta-feira de Cinzas', horasPadrao: ['19:30'], data: _cinzas),
  FestaLiturgica(chave: 'saoJose', nome: 'São José, Esposo de Maria', horasPadrao: ['19:30'], data: _saoJose),
  FestaLiturgica(chave: 'anunciacao', nome: 'Anunciação do Senhor', horasPadrao: ['19:30'], data: _anunciacao),
  FestaLiturgica(
    chave: 'quintaSanta',
    nome: 'Quinta-feira Santa – Ceia do Senhor (Lava-pés)',
    horasPadrao: ['19:30'],
    data: _quintaSanta,
    observacao: 'Substitui a missa de quinta. Sexta-feira Santa não tem leitura (procissão).',
  ),
  FestaLiturgica(
    chave: 'vigiliaPascal',
    nome: 'Vigília Pascal',
    horasPadrao: ['19:00'],
    data: _vigiliaPascal,
    funcoes: [Funcao.animador, Funcao.leitura1, Funcao.leitura2, Funcao.leitura3, Funcao.epistola, Funcao.preces],
    observacao: '3 leituras, epístola e preces.',
  ),
  FestaLiturgica(chave: 'corpusChristi', nome: 'Corpus Christi', horasPadrao: ['19:00'], data: _corpusChristi),
  FestaLiturgica(chave: 'sagradoCoracao', nome: 'Sagrado Coração de Jesus', horasPadrao: ['19:30'], data: _sagradoCoracao),
  FestaLiturgica(chave: 'saoJoao', nome: 'Natividade de São João Batista', horasPadrao: ['19:30'], data: _saoJoao),
  FestaLiturgica(chave: 'aparecida', nome: 'Nossa Senhora Aparecida', horasPadrao: ['09:00'], data: _aparecida),
  FestaLiturgica(chave: 'finados', nome: 'Finados', horasPadrao: ['09:00'], data: _finados),
  FestaLiturgica(chave: 'imaculada', nome: 'Imaculada Conceição', horasPadrao: ['19:30'], data: _imaculada),
  FestaLiturgica(
    chave: 'noiteDeNatal',
    nome: 'Natal do Senhor – Missa da Noite',
    horasPadrao: ['20:00'],
    data: _noiteDeNatal,
    valeNoDomingo: true,
  ),
  FestaLiturgica(chave: 'natal', nome: 'Natal do Senhor', horasPadrao: ['09:00'], data: _natal),
];

FestaLiturgica? festaPorChave(String chave) {
  for (final f in festasLiturgicas) {
    if (f.chave == chave) return f;
  }
  return null;
}

/// Ativação e horários de cada festa (editáveis nas configurações).
class ConfigFesta {
  const ConfigFesta({required this.chave, required this.ativa, required this.horas});
  final String chave;
  final bool ativa;
  final List<String> horas;

  ConfigFesta copyWith({bool? ativa, List<String>? horas}) =>
      ConfigFesta(chave: chave, ativa: ativa ?? this.ativa, horas: horas ?? this.horas);

  Map<String, dynamic> toJson() => {'chave': chave, 'ativa': ativa, 'horas': horas};
  factory ConfigFesta.fromJson(Map<String, dynamic> j) => ConfigFesta(
        chave: j['chave'] as String,
        ativa: (j['ativa'] as bool?) ?? true,
        horas: [...((j['horas'] as List?) ?? const []).cast<String>()],
      );
}

List<ConfigFesta> configFestasPadrao() => [
      for (final f in festasLiturgicas) ConfigFesta(chave: f.chave, ativa: true, horas: f.horasPadrao),
    ];

/// Completa a lista salva com festas novas (versões futuras do app).
List<ConfigFesta> mesclarConfigFestas(List<ConfigFesta> salvas) {
  final porChave = {for (final s in salvas) s.chave: s};
  return [
    for (final f in festasLiturgicas)
      porChave[f.chave] ?? ConfigFesta(chave: f.chave, ativa: true, horas: f.horasPadrao),
  ];
}

class FestaNoMes {
  const FestaNoMes(this.festa, this.data, this.horas);
  final FestaLiturgica festa;
  final DateTime data;
  final List<String> horas;
}

/// Festas ativas que caem no mês.
List<FestaNoMes> festasDoMes(int ano, int mes, List<ConfigFesta> config) {
  final out = <FestaNoMes>[];
  for (final c in mesclarConfigFestas(config)) {
    final f = festaPorChave(c.chave);
    if (f == null || !c.ativa || c.horas.isEmpty) continue;
    final d = f.data(ano);
    if (d.month == mes) out.add(FestaNoMes(f, d, [...c.horas]..sort()));
  }
  return out..sort((a, b) => a.data.compareTo(b.data));
}
