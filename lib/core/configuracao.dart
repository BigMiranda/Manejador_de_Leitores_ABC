import 'modelos.dart';
import 'regras_epoca.dart';

class ModeloMissa {
  const ModeloMissa(this.hora, this.funcoes);
  final String hora;
  final List<Funcao> funcoes;

  Map<String, dynamic> toJson() => {'hora': hora, 'funcoes': funcoes.map((f) => f.name).toList()};
  factory ModeloMissa.fromJson(Map<String, dynamic> j) => ModeloMissa(
        j['hora'] as String,
        [for (final f in (j['funcoes'] as List)) Funcao.values.byName(f as String)],
      );
}

/// Em que domingo e horário a pastoral proclama as leituras.
class ConfigPastoral {
  const ConfigPastoral({required this.nome, required this.posicaoDomingo, required this.hora});
  final String nome;

  /// 1–4, 5 = último domingo, 0 = desativada.
  final int posicaoDomingo;
  final String hora;

  ConfigPastoral copyWith({String? nome, int? posicaoDomingo, String? hora}) => ConfigPastoral(
        nome: nome ?? this.nome,
        posicaoDomingo: posicaoDomingo ?? this.posicaoDomingo,
        hora: hora ?? this.hora,
      );

  Map<String, dynamic> toJson() => {'nome': nome, 'posicaoDomingo': posicaoDomingo, 'hora': hora};
  factory ConfigPastoral.fromJson(Map<String, dynamic> j) => ConfigPastoral(
        nome: j['nome'] as String,
        posicaoDomingo: j['posicaoDomingo'] as int,
        hora: j['hora'] as String,
      );
}

class ModelosMensagem {
  const ModelosMensagem({
    this.domingoCabecalho = padraoDomingoCabecalho,
    this.domingoBloco = padraoDomingoBloco,
    this.domingoRodape = padraoDomingoRodape,
    this.quinta = padraoQuinta,
  });

  final String domingoCabecalho;
  final String domingoBloco;
  final String domingoRodape;
  final String quinta;

  static const padraoDomingoCabecalho = '{saudacao}! A paz a todos vocês.\n'
      'Passando para lembrar a escala das missas de\n'
      'amanhã {diaSemana} {data}{nomeFesta}.\n'
      '\n'
      '{escalaAtualizada}';

  static const padraoDomingoBloco = 'Missa das {hora}\n'
      '\n'
      'Animador\n'
      '{animador}\n'
      'Primeira leitura\n'
      '{leitura1}\n'
      'Segunda leitura\n'
      '{leitura2}\n'
      'Preces\n'
      '{preces}';

  static const padraoDomingoRodape = 'Boa missa a todos.\n'
      '\n'
      'Peço encarecidamente que todos cheguem com 30 minutos de antecedência.\n'
      'Desde já agradeço a atenção e a vida de cada um!';

  static const padraoQuinta = '{saudacao}, a paz de Cristo e o amor de Maria a todos!\n'
      '\n'
      '{escalaAtualizada}'
      'Passando para confirmar a presença dos leitores na missa de amanhã, {data} às {hora}.\n'
      '\n'
      'Animação: {animador}\n'
      'Leitura: {leitura1}\n'
      'Preces: {preces}\n'
      '\n'
      'Peço encarecidamente que todos cheguem com 30 minutos de antecedência.\n'
      'Desde já agradeço a atenção e compreensão de todos, que Deus abençoe infinitamente a vida de cada um!\n'
      '\n'
      'Boa missa a todos!';

  ModelosMensagem copyWith({String? domingoCabecalho, String? domingoBloco, String? domingoRodape, String? quinta}) =>
      ModelosMensagem(
        domingoCabecalho: domingoCabecalho ?? this.domingoCabecalho,
        domingoBloco: domingoBloco ?? this.domingoBloco,
        domingoRodape: domingoRodape ?? this.domingoRodape,
        quinta: quinta ?? this.quinta,
      );

  Map<String, dynamic> toJson() => {
        'domingoCabecalho': domingoCabecalho,
        'domingoBloco': domingoBloco,
        'domingoRodape': domingoRodape,
        'quinta': quinta,
      };
  factory ModelosMensagem.fromJson(Map<String, dynamic> j) => ModelosMensagem(
        domingoCabecalho: (j['domingoCabecalho'] as String?) ?? padraoDomingoCabecalho,
        domingoBloco: (j['domingoBloco'] as String?) ?? padraoDomingoBloco,
        domingoRodape: (j['domingoRodape'] as String?) ?? padraoDomingoRodape,
        quinta: (j['quinta'] as String?) ?? padraoQuinta,
      );
}

class Configuracao {
  const Configuracao({
    this.missasDomingo = const [
      ModeloMissa('07:00', [Funcao.animador, Funcao.leitura1, Funcao.leitura2, Funcao.preces]),
      ModeloMissa('09:00', [Funcao.animador, Funcao.leitura1, Funcao.leitura2, Funcao.preces]),
      ModeloMissa('18:00', [Funcao.animador, Funcao.leitura1, Funcao.leitura2, Funcao.preces]),
    ],
    this.missasQuinta = const [
      ModeloMissa('19:30', [Funcao.animador, Funcao.leitura1, Funcao.preces]),
    ],
    this.pastorais = const [
      ConfigPastoral(nome: pastoralTercoMulheres, posicaoDomingo: 1, hora: '18:00'),
      ConfigPastoral(nome: pastoralTercoHomens, posicaoDomingo: 2, hora: '18:00'),
    ],
    this.intervaloMinimoSemanas = 4,
    this.horaNotificacao = '14:00',
    this.mensagens = const ModelosMensagem(),
  });

  final List<ModeloMissa> missasDomingo;
  final List<ModeloMissa> missasQuinta;
  final List<ConfigPastoral> pastorais;
  final int intervaloMinimoSemanas;
  final String horaNotificacao;
  final ModelosMensagem mensagens;

  Configuracao copyWith({
    List<ModeloMissa>? missasDomingo,
    List<ModeloMissa>? missasQuinta,
    List<ConfigPastoral>? pastorais,
    int? intervaloMinimoSemanas,
    String? horaNotificacao,
    ModelosMensagem? mensagens,
  }) =>
      Configuracao(
        missasDomingo: missasDomingo ?? this.missasDomingo,
        missasQuinta: missasQuinta ?? this.missasQuinta,
        pastorais: pastorais ?? this.pastorais,
        intervaloMinimoSemanas: intervaloMinimoSemanas ?? this.intervaloMinimoSemanas,
        horaNotificacao: horaNotificacao ?? this.horaNotificacao,
        mensagens: mensagens ?? this.mensagens,
      );

  Map<String, dynamic> toJson() => {
        'missasDomingo': missasDomingo.map((m) => m.toJson()).toList(),
        'missasQuinta': missasQuinta.map((m) => m.toJson()).toList(),
        'pastorais': pastorais.map((p) => p.toJson()).toList(),
        'intervaloMinimoSemanas': intervaloMinimoSemanas,
        'horaNotificacao': horaNotificacao,
        'mensagens': mensagens.toJson(),
      };

  factory Configuracao.fromJson(Map<String, dynamic> j) {
    const p = Configuracao();
    List<ModeloMissa>? missas(String k) => j[k] == null
        ? null
        : [for (final m in j[k] as List) ModeloMissa.fromJson((m as Map).cast<String, dynamic>())];
    return Configuracao(
      missasDomingo: missas('missasDomingo') ?? p.missasDomingo,
      missasQuinta: missas('missasQuinta') ?? p.missasQuinta,
      pastorais: j['pastorais'] == null
          ? p.pastorais
          : [for (final x in j['pastorais'] as List) ConfigPastoral.fromJson((x as Map).cast<String, dynamic>())],
      intervaloMinimoSemanas: (j['intervaloMinimoSemanas'] as int?) ?? p.intervaloMinimoSemanas,
      horaNotificacao: (j['horaNotificacao'] as String?) ?? p.horaNotificacao,
      mensagens: j['mensagens'] == null
          ? p.mensagens
          : ModelosMensagem.fromJson((j['mensagens'] as Map).cast<String, dynamic>()),
    );
  }
}

/// Domingos de [ano]/[mes] que correspondem à posição (1–4, 5 = último).
DateTime? domingoNaPosicao(int ano, int mes, int posicao) {
  if (posicao <= 0) return null;
  final domingos = [
    for (var d = 1; d <= diasNoMes(ano, mes); d++)
      if (DateTime.utc(ano, mes, d).weekday == DateTime.sunday) DateTime.utc(ano, mes, d),
  ];
  if (posicao == 5) return domingos.last;
  return posicao <= domingos.length ? domingos[posicao - 1] : null;
}

/// Cria as celebrações padrão (domingos e quintas) de um mês, já marcando
/// as missas das pastorais. Os ids são negativos e provisórios.
List<Celebracao> gerarCelebracoesDoMes(int ano, int mes, Configuracao cfg, {List<ConfigPastoral>? pastorais}) {
  final ps = pastorais ?? cfg.pastorais;
  final out = <Celebracao>[];
  var id = -1;
  for (var d = 1; d <= diasNoMes(ano, mes); d++) {
    final dia = DateTime.utc(ano, mes, d);
    if (dia.weekday == DateTime.sunday) {
      for (final m in cfg.missasDomingo) {
        ConfigPastoral? pastoral;
        for (final p in ps) {
          if (p.hora == m.hora && domingoNaPosicao(ano, mes, p.posicaoDomingo) == dia) pastoral = p;
        }
        out.add(Celebracao(
          id: id--,
          data: dia,
          hora: m.hora,
          tipo: TipoCelebracao.domingo,
          funcoes: m.funcoes,
          atribuicao: pastoral == null ? Atribuicao.leitores : Atribuicao.pastoral,
          atribuicaoTexto: pastoral?.nome,
        ));
      }
    } else if (dia.weekday == DateTime.thursday) {
      for (final m in cfg.missasQuinta) {
        out.add(Celebracao(id: id--, data: dia, hora: m.hora, tipo: TipoCelebracao.quinta, funcoes: m.funcoes));
      }
    }
  }
  return out;
}
