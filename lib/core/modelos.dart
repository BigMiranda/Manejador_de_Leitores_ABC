/// Modelos de domínio puros (sem Flutter e sem banco).
///
/// Datas "só dia" são sempre `DateTime.utc(ano, mes, dia)` para evitar
/// problemas de fuso/horário de verão nas contas de dias.
library;

DateTime soDia(DateTime d) => DateTime.utc(d.year, d.month, d.day);

String dataIso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDataIso(String s) {
  final p = s.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

enum FazAnimacao {
  nao('Não'),
  simPrefere('Sim e prefere'),
  simPrefereLer('Sim, mas prefere ler');

  const FazAnimacao(this.rotulo);
  final String rotulo;
}

enum LeQuinta {
  sim('Sim'),
  nao('Não'),
  asVezes('Às vezes');

  const LeQuinta(this.rotulo);
  final String rotulo;
}

enum TipoRegra {
  impedimento('Impedimento'),
  preferencia('Preferência'),
  prefereNao('Prefere não');

  const TipoRegra(this.rotulo);
  final String rotulo;
}

enum Abrangencia {
  todas('Todas as missas'),
  domingos('Só domingos'),
  quintas('Só quintas'),
  festas('Só festas'),
  horario('Horário específico');

  const Abrangencia(this.rotulo);
  final String rotulo;
}

enum PadraoData {
  periodoFixo('Período fixo'),
  anualRecorrente('Período anual recorrente'),
  faixaDiasMes('Faixa de dias do mês'),
  posicaoNoMes('Posição no mês');

  const PadraoData(this.rotulo);
  final String rotulo;
}

enum TipoCelebracao {
  domingo('Domingo'),
  quinta('Quinta'),
  festa('Festa'),
  especial('Especial');

  const TipoCelebracao(this.rotulo);
  final String rotulo;
}

enum Atribuicao {
  leitores('Leitores'),
  pastoral('Pastoral'),
  comunidade('Comunidade');

  const Atribuicao(this.rotulo);
  final String rotulo;
}

/// Funções na ordem em que são preenchidas (animador primeiro).
enum Funcao {
  animador('Animador', 'ANIMADOR'),
  leitura1('1ª Leitura', '1ª LEITURA'),
  leitura2('2ª Leitura', '2ª LEITURA'),
  preces('Preces', 'PRECES');

  const Funcao(this.rotulo, this.cabecalho);
  final String rotulo;
  final String cabecalho;
}

enum Avaliacao { bloqueado, bonus, penalidade, neutro }

const horariosDomingoPadrao = ['07:00', '09:00', '18:00'];
const pastoralTercoHomens = 'Terço dos Homens';
const pastoralTercoMulheres = 'Terço das Mulheres';

/// Uma regra de época (impedimento, preferência ou "prefere não").
class RegraEpoca {
  const RegraEpoca({
    this.tipo = TipoRegra.impedimento,
    this.abrangencia = Abrangencia.todas,
    this.horario,
    this.padrao = PadraoData.periodoFixo,
    this.inicio,
    this.fim,
    this.diaMesInicio,
    this.diaMesFim,
    this.diaDe,
    this.diaAte,
    this.posicoes = const {},
    this.vigenciaDe,
    this.vigenciaAte,
    this.descricao = '',
  });

  final TipoRegra tipo;
  final Abrangencia abrangencia;

  /// Usado quando [abrangencia] é [Abrangencia.horario], ex.: "18:00".
  final String? horario;
  final PadraoData padrao;

  /// [PadraoData.periodoFixo]: datas inclusivas.
  final DateTime? inicio;
  final DateTime? fim;

  /// [PadraoData.anualRecorrente]: "dd/mm", podendo atravessar o ano.
  final String? diaMesInicio;
  final String? diaMesFim;

  /// [PadraoData.faixaDiasMes]: dias inclusivos.
  final int? diaDe;
  final int? diaAte;

  /// [PadraoData.posicaoNoMes]: 1–4 e 5 = último.
  final Set<int> posicoes;

  final DateTime? vigenciaDe;
  final DateTime? vigenciaAte;
  final String descricao;

  Map<String, dynamic> toJson() => {
        'tipo': tipo.name,
        'abrangencia': abrangencia.name,
        'horario': horario,
        'padrao': padrao.name,
        'inicio': inicio == null ? null : dataIso(inicio!),
        'fim': fim == null ? null : dataIso(fim!),
        'diaMesInicio': diaMesInicio,
        'diaMesFim': diaMesFim,
        'diaDe': diaDe,
        'diaAte': diaAte,
        'posicoes': (posicoes.toList()..sort()),
        'vigenciaDe': vigenciaDe == null ? null : dataIso(vigenciaDe!),
        'vigenciaAte': vigenciaAte == null ? null : dataIso(vigenciaAte!),
        'descricao': descricao,
      };

  factory RegraEpoca.fromJson(Map<String, dynamic> j) {
    DateTime? d(String k) => j[k] == null ? null : parseDataIso(j[k] as String);
    return RegraEpoca(
      tipo: TipoRegra.values.byName(j['tipo'] as String),
      abrangencia: Abrangencia.values.byName(j['abrangencia'] as String),
      horario: j['horario'] as String?,
      padrao: PadraoData.values.byName(j['padrao'] as String),
      inicio: d('inicio'),
      fim: d('fim'),
      diaMesInicio: j['diaMesInicio'] as String?,
      diaMesFim: j['diaMesFim'] as String?,
      diaDe: j['diaDe'] as int?,
      diaAte: j['diaAte'] as int?,
      posicoes: {...((j['posicoes'] as List?) ?? const []).cast<int>()},
      vigenciaDe: d('vigenciaDe'),
      vigenciaAte: d('vigenciaAte'),
      descricao: (j['descricao'] as String?) ?? '',
    );
  }
}

class Leitor {
  const Leitor({
    required this.id,
    required this.nome,
    this.vaiLer = true,
    this.fazAnimacao = FazAnimacao.nao,
    this.leDomingo = true,
    this.horariosDomingo = const {'07:00', '09:00', '18:00'},
    this.leQuinta = LeQuinta.sim,
    this.leFesta = true,
    this.soPastoral,
    this.regras = const [],
    this.parId,
    this.ultimaParticipacao,
    this.observacoes = '',
  });

  final int id;
  final String nome;
  final bool vaiLer;
  final FazAnimacao fazAnimacao;
  final bool leDomingo;
  final Set<String> horariosDomingo;
  final LeQuinta leQuinta;
  final bool leFesta;

  /// `null` = não; senão o nome da pastoral (ex.: "Terço dos Homens").
  final String? soPastoral;
  final List<RegraEpoca> regras;

  /// Leitor com quem prefere ler junto (relação bidirecional).
  final int? parId;

  /// Carga inicial manual da última participação.
  final DateTime? ultimaParticipacao;
  final String observacoes;

  bool get doRodizioGeral => vaiLer && soPastoral == null;

  Leitor copyWith({
    int? id,
    String? nome,
    bool? vaiLer,
    FazAnimacao? fazAnimacao,
    bool? leDomingo,
    Set<String>? horariosDomingo,
    LeQuinta? leQuinta,
    bool? leFesta,
    String? Function()? soPastoral,
    List<RegraEpoca>? regras,
    int? Function()? parId,
    DateTime? Function()? ultimaParticipacao,
    String? observacoes,
  }) =>
      Leitor(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        vaiLer: vaiLer ?? this.vaiLer,
        fazAnimacao: fazAnimacao ?? this.fazAnimacao,
        leDomingo: leDomingo ?? this.leDomingo,
        horariosDomingo: horariosDomingo ?? this.horariosDomingo,
        leQuinta: leQuinta ?? this.leQuinta,
        leFesta: leFesta ?? this.leFesta,
        soPastoral: soPastoral != null ? soPastoral() : this.soPastoral,
        regras: regras ?? this.regras,
        parId: parId != null ? parId() : this.parId,
        ultimaParticipacao: ultimaParticipacao != null ? ultimaParticipacao() : this.ultimaParticipacao,
        observacoes: observacoes ?? this.observacoes,
      );
}

enum StatusPdf {
  pendente('PDF pendente'),
  ok('PDF ok'),
  naoPublicado('PDF ainda não publicado');

  const StatusPdf(this.rotulo);
  final String rotulo;
}

class Celebracao {
  const Celebracao({
    required this.id,
    required this.data,
    required this.hora,
    required this.tipo,
    required this.funcoes,
    this.nomeLiturgico,
    this.atribuicao = Atribuicao.leitores,
    this.atribuicaoTexto,
    this.pdfUrl,
    this.pdfArquivo,
    this.pdfStatus = StatusPdf.pendente,
  });

  final String? pdfUrl;

  /// Caminho do PDF baixado no cache do app.
  final String? pdfArquivo;
  final StatusPdf pdfStatus;

  Celebracao copyWith({
    int? id,
    DateTime? data,
    String? hora,
    TipoCelebracao? tipo,
    List<Funcao>? funcoes,
    String? Function()? nomeLiturgico,
    Atribuicao? atribuicao,
    String? Function()? atribuicaoTexto,
    String? Function()? pdfUrl,
    String? Function()? pdfArquivo,
    StatusPdf? pdfStatus,
  }) =>
      Celebracao(
        id: id ?? this.id,
        data: data ?? this.data,
        hora: hora ?? this.hora,
        tipo: tipo ?? this.tipo,
        funcoes: funcoes ?? this.funcoes,
        nomeLiturgico: nomeLiturgico != null ? nomeLiturgico() : this.nomeLiturgico,
        atribuicao: atribuicao ?? this.atribuicao,
        atribuicaoTexto: atribuicaoTexto != null ? atribuicaoTexto() : this.atribuicaoTexto,
        pdfUrl: pdfUrl != null ? pdfUrl() : this.pdfUrl,
        pdfArquivo: pdfArquivo != null ? pdfArquivo() : this.pdfArquivo,
        pdfStatus: pdfStatus ?? this.pdfStatus,
      );

  final int id;
  final DateTime data;

  /// "HH:mm".
  final String hora;
  final TipoCelebracao tipo;
  final List<Funcao> funcoes;
  final String? nomeLiturgico;
  final Atribuicao atribuicao;

  /// Nome da pastoral ou texto da comunidade.
  final String? atribuicaoTexto;

  /// Para ordenar cronologicamente.
  DateTime get instante {
    final p = hora.split(':');
    return DateTime.utc(data.year, data.month, data.day, int.parse(p[0]), int.parse(p[1]));
  }
}

/// Uma célula da escala.
class Vaga {
  const Vaga({
    required this.celebracaoId,
    required this.funcao,
    this.leitorId,
    this.nomeLivre,
    this.travada = false,
  });

  final int celebracaoId;
  final Funcao funcao;
  final int? leitorId;

  /// Nome digitado à mão (ex.: indicado pela pastoral) ou nome de leitor excluído.
  final String? nomeLivre;
  final bool travada;

  bool get vazia => leitorId == null && (nomeLivre == null || nomeLivre!.isEmpty);

  Vaga copyWith({int? Function()? leitorId, String? Function()? nomeLivre, bool? travada}) => Vaga(
        celebracaoId: celebracaoId,
        funcao: funcao,
        leitorId: leitorId != null ? leitorId() : this.leitorId,
        nomeLivre: nomeLivre != null ? nomeLivre() : this.nomeLivre,
        travada: travada ?? this.travada,
      );
}

String horaExibicao(String hora) {
  final p = hora.split(':');
  return '${int.parse(p[0])}:${p[1]}';
}

String normalizarNome(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
  const para = 'aaaaaeeeeiiiiooooouuuucnaaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final ch in s.trim().toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i >= 0 ? para[i] : ch);
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ');
}
