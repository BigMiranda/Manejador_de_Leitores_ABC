// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco.dart';

// ignore_for_file: type=lint
class $LeitoresTable extends Leitores
    with TableInfo<$LeitoresTable, LeitorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeitoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _vaiLerMeta = const VerificationMeta('vaiLer');
  @override
  late final GeneratedColumn<bool> vaiLer = GeneratedColumn<bool>(
    'vai_ler',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vai_ler" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _fazAnimacaoMeta = const VerificationMeta(
    'fazAnimacao',
  );
  @override
  late final GeneratedColumn<String> fazAnimacao = GeneratedColumn<String>(
    'faz_animacao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('nao'),
  );
  static const VerificationMeta _leDomingoMeta = const VerificationMeta(
    'leDomingo',
  );
  @override
  late final GeneratedColumn<bool> leDomingo = GeneratedColumn<bool>(
    'le_domingo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("le_domingo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _horariosDomingoMeta = const VerificationMeta(
    'horariosDomingo',
  );
  @override
  late final GeneratedColumn<String> horariosDomingo = GeneratedColumn<String>(
    'horarios_domingo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('07:00,09:00,18:00'),
  );
  static const VerificationMeta _leQuintaMeta = const VerificationMeta(
    'leQuinta',
  );
  @override
  late final GeneratedColumn<String> leQuinta = GeneratedColumn<String>(
    'le_quinta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sim'),
  );
  static const VerificationMeta _leFestaMeta = const VerificationMeta(
    'leFesta',
  );
  @override
  late final GeneratedColumn<bool> leFesta = GeneratedColumn<bool>(
    'le_festa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("le_festa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _soPastoralMeta = const VerificationMeta(
    'soPastoral',
  );
  @override
  late final GeneratedColumn<String> soPastoral = GeneratedColumn<String>(
    'so_pastoral',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parIdMeta = const VerificationMeta('parId');
  @override
  late final GeneratedColumn<int> parId = GeneratedColumn<int>(
    'par_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ultimaParticipacaoMeta =
      const VerificationMeta('ultimaParticipacao');
  @override
  late final GeneratedColumn<String> ultimaParticipacao =
      GeneratedColumn<String>(
        'ultima_participacao',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _observacoesMeta = const VerificationMeta(
    'observacoes',
  );
  @override
  late final GeneratedColumn<String> observacoes = GeneratedColumn<String>(
    'observacoes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    vaiLer,
    fazAnimacao,
    leDomingo,
    horariosDomingo,
    leQuinta,
    leFesta,
    soPastoral,
    parId,
    ultimaParticipacao,
    observacoes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leitores';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeitorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('vai_ler')) {
      context.handle(
        _vaiLerMeta,
        vaiLer.isAcceptableOrUnknown(data['vai_ler']!, _vaiLerMeta),
      );
    }
    if (data.containsKey('faz_animacao')) {
      context.handle(
        _fazAnimacaoMeta,
        fazAnimacao.isAcceptableOrUnknown(
          data['faz_animacao']!,
          _fazAnimacaoMeta,
        ),
      );
    }
    if (data.containsKey('le_domingo')) {
      context.handle(
        _leDomingoMeta,
        leDomingo.isAcceptableOrUnknown(data['le_domingo']!, _leDomingoMeta),
      );
    }
    if (data.containsKey('horarios_domingo')) {
      context.handle(
        _horariosDomingoMeta,
        horariosDomingo.isAcceptableOrUnknown(
          data['horarios_domingo']!,
          _horariosDomingoMeta,
        ),
      );
    }
    if (data.containsKey('le_quinta')) {
      context.handle(
        _leQuintaMeta,
        leQuinta.isAcceptableOrUnknown(data['le_quinta']!, _leQuintaMeta),
      );
    }
    if (data.containsKey('le_festa')) {
      context.handle(
        _leFestaMeta,
        leFesta.isAcceptableOrUnknown(data['le_festa']!, _leFestaMeta),
      );
    }
    if (data.containsKey('so_pastoral')) {
      context.handle(
        _soPastoralMeta,
        soPastoral.isAcceptableOrUnknown(data['so_pastoral']!, _soPastoralMeta),
      );
    }
    if (data.containsKey('par_id')) {
      context.handle(
        _parIdMeta,
        parId.isAcceptableOrUnknown(data['par_id']!, _parIdMeta),
      );
    }
    if (data.containsKey('ultima_participacao')) {
      context.handle(
        _ultimaParticipacaoMeta,
        ultimaParticipacao.isAcceptableOrUnknown(
          data['ultima_participacao']!,
          _ultimaParticipacaoMeta,
        ),
      );
    }
    if (data.containsKey('observacoes')) {
      context.handle(
        _observacoesMeta,
        observacoes.isAcceptableOrUnknown(
          data['observacoes']!,
          _observacoesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeitorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeitorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      vaiLer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vai_ler'],
      )!,
      fazAnimacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}faz_animacao'],
      )!,
      leDomingo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}le_domingo'],
      )!,
      horariosDomingo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}horarios_domingo'],
      )!,
      leQuinta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}le_quinta'],
      )!,
      leFesta: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}le_festa'],
      )!,
      soPastoral: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}so_pastoral'],
      ),
      parId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}par_id'],
      ),
      ultimaParticipacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ultima_participacao'],
      ),
      observacoes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacoes'],
      )!,
    );
  }

  @override
  $LeitoresTable createAlias(String alias) {
    return $LeitoresTable(attachedDatabase, alias);
  }
}

class LeitorRow extends DataClass implements Insertable<LeitorRow> {
  final int id;
  final String nome;
  final bool vaiLer;
  final String fazAnimacao;
  final bool leDomingo;
  final String horariosDomingo;
  final String leQuinta;
  final bool leFesta;
  final String? soPastoral;
  final int? parId;
  final String? ultimaParticipacao;
  final String observacoes;
  const LeitorRow({
    required this.id,
    required this.nome,
    required this.vaiLer,
    required this.fazAnimacao,
    required this.leDomingo,
    required this.horariosDomingo,
    required this.leQuinta,
    required this.leFesta,
    this.soPastoral,
    this.parId,
    this.ultimaParticipacao,
    required this.observacoes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['vai_ler'] = Variable<bool>(vaiLer);
    map['faz_animacao'] = Variable<String>(fazAnimacao);
    map['le_domingo'] = Variable<bool>(leDomingo);
    map['horarios_domingo'] = Variable<String>(horariosDomingo);
    map['le_quinta'] = Variable<String>(leQuinta);
    map['le_festa'] = Variable<bool>(leFesta);
    if (!nullToAbsent || soPastoral != null) {
      map['so_pastoral'] = Variable<String>(soPastoral);
    }
    if (!nullToAbsent || parId != null) {
      map['par_id'] = Variable<int>(parId);
    }
    if (!nullToAbsent || ultimaParticipacao != null) {
      map['ultima_participacao'] = Variable<String>(ultimaParticipacao);
    }
    map['observacoes'] = Variable<String>(observacoes);
    return map;
  }

  LeitoresCompanion toCompanion(bool nullToAbsent) {
    return LeitoresCompanion(
      id: Value(id),
      nome: Value(nome),
      vaiLer: Value(vaiLer),
      fazAnimacao: Value(fazAnimacao),
      leDomingo: Value(leDomingo),
      horariosDomingo: Value(horariosDomingo),
      leQuinta: Value(leQuinta),
      leFesta: Value(leFesta),
      soPastoral: soPastoral == null && nullToAbsent
          ? const Value.absent()
          : Value(soPastoral),
      parId: parId == null && nullToAbsent
          ? const Value.absent()
          : Value(parId),
      ultimaParticipacao: ultimaParticipacao == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaParticipacao),
      observacoes: Value(observacoes),
    );
  }

  factory LeitorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeitorRow(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      vaiLer: serializer.fromJson<bool>(json['vaiLer']),
      fazAnimacao: serializer.fromJson<String>(json['fazAnimacao']),
      leDomingo: serializer.fromJson<bool>(json['leDomingo']),
      horariosDomingo: serializer.fromJson<String>(json['horariosDomingo']),
      leQuinta: serializer.fromJson<String>(json['leQuinta']),
      leFesta: serializer.fromJson<bool>(json['leFesta']),
      soPastoral: serializer.fromJson<String?>(json['soPastoral']),
      parId: serializer.fromJson<int?>(json['parId']),
      ultimaParticipacao: serializer.fromJson<String?>(
        json['ultimaParticipacao'],
      ),
      observacoes: serializer.fromJson<String>(json['observacoes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'vaiLer': serializer.toJson<bool>(vaiLer),
      'fazAnimacao': serializer.toJson<String>(fazAnimacao),
      'leDomingo': serializer.toJson<bool>(leDomingo),
      'horariosDomingo': serializer.toJson<String>(horariosDomingo),
      'leQuinta': serializer.toJson<String>(leQuinta),
      'leFesta': serializer.toJson<bool>(leFesta),
      'soPastoral': serializer.toJson<String?>(soPastoral),
      'parId': serializer.toJson<int?>(parId),
      'ultimaParticipacao': serializer.toJson<String?>(ultimaParticipacao),
      'observacoes': serializer.toJson<String>(observacoes),
    };
  }

  LeitorRow copyWith({
    int? id,
    String? nome,
    bool? vaiLer,
    String? fazAnimacao,
    bool? leDomingo,
    String? horariosDomingo,
    String? leQuinta,
    bool? leFesta,
    Value<String?> soPastoral = const Value.absent(),
    Value<int?> parId = const Value.absent(),
    Value<String?> ultimaParticipacao = const Value.absent(),
    String? observacoes,
  }) => LeitorRow(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    vaiLer: vaiLer ?? this.vaiLer,
    fazAnimacao: fazAnimacao ?? this.fazAnimacao,
    leDomingo: leDomingo ?? this.leDomingo,
    horariosDomingo: horariosDomingo ?? this.horariosDomingo,
    leQuinta: leQuinta ?? this.leQuinta,
    leFesta: leFesta ?? this.leFesta,
    soPastoral: soPastoral.present ? soPastoral.value : this.soPastoral,
    parId: parId.present ? parId.value : this.parId,
    ultimaParticipacao: ultimaParticipacao.present
        ? ultimaParticipacao.value
        : this.ultimaParticipacao,
    observacoes: observacoes ?? this.observacoes,
  );
  LeitorRow copyWithCompanion(LeitoresCompanion data) {
    return LeitorRow(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      vaiLer: data.vaiLer.present ? data.vaiLer.value : this.vaiLer,
      fazAnimacao: data.fazAnimacao.present
          ? data.fazAnimacao.value
          : this.fazAnimacao,
      leDomingo: data.leDomingo.present ? data.leDomingo.value : this.leDomingo,
      horariosDomingo: data.horariosDomingo.present
          ? data.horariosDomingo.value
          : this.horariosDomingo,
      leQuinta: data.leQuinta.present ? data.leQuinta.value : this.leQuinta,
      leFesta: data.leFesta.present ? data.leFesta.value : this.leFesta,
      soPastoral: data.soPastoral.present
          ? data.soPastoral.value
          : this.soPastoral,
      parId: data.parId.present ? data.parId.value : this.parId,
      ultimaParticipacao: data.ultimaParticipacao.present
          ? data.ultimaParticipacao.value
          : this.ultimaParticipacao,
      observacoes: data.observacoes.present
          ? data.observacoes.value
          : this.observacoes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeitorRow(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('vaiLer: $vaiLer, ')
          ..write('fazAnimacao: $fazAnimacao, ')
          ..write('leDomingo: $leDomingo, ')
          ..write('horariosDomingo: $horariosDomingo, ')
          ..write('leQuinta: $leQuinta, ')
          ..write('leFesta: $leFesta, ')
          ..write('soPastoral: $soPastoral, ')
          ..write('parId: $parId, ')
          ..write('ultimaParticipacao: $ultimaParticipacao, ')
          ..write('observacoes: $observacoes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    vaiLer,
    fazAnimacao,
    leDomingo,
    horariosDomingo,
    leQuinta,
    leFesta,
    soPastoral,
    parId,
    ultimaParticipacao,
    observacoes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeitorRow &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.vaiLer == this.vaiLer &&
          other.fazAnimacao == this.fazAnimacao &&
          other.leDomingo == this.leDomingo &&
          other.horariosDomingo == this.horariosDomingo &&
          other.leQuinta == this.leQuinta &&
          other.leFesta == this.leFesta &&
          other.soPastoral == this.soPastoral &&
          other.parId == this.parId &&
          other.ultimaParticipacao == this.ultimaParticipacao &&
          other.observacoes == this.observacoes);
}

class LeitoresCompanion extends UpdateCompanion<LeitorRow> {
  final Value<int> id;
  final Value<String> nome;
  final Value<bool> vaiLer;
  final Value<String> fazAnimacao;
  final Value<bool> leDomingo;
  final Value<String> horariosDomingo;
  final Value<String> leQuinta;
  final Value<bool> leFesta;
  final Value<String?> soPastoral;
  final Value<int?> parId;
  final Value<String?> ultimaParticipacao;
  final Value<String> observacoes;
  const LeitoresCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.vaiLer = const Value.absent(),
    this.fazAnimacao = const Value.absent(),
    this.leDomingo = const Value.absent(),
    this.horariosDomingo = const Value.absent(),
    this.leQuinta = const Value.absent(),
    this.leFesta = const Value.absent(),
    this.soPastoral = const Value.absent(),
    this.parId = const Value.absent(),
    this.ultimaParticipacao = const Value.absent(),
    this.observacoes = const Value.absent(),
  });
  LeitoresCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.vaiLer = const Value.absent(),
    this.fazAnimacao = const Value.absent(),
    this.leDomingo = const Value.absent(),
    this.horariosDomingo = const Value.absent(),
    this.leQuinta = const Value.absent(),
    this.leFesta = const Value.absent(),
    this.soPastoral = const Value.absent(),
    this.parId = const Value.absent(),
    this.ultimaParticipacao = const Value.absent(),
    this.observacoes = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<LeitorRow> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<bool>? vaiLer,
    Expression<String>? fazAnimacao,
    Expression<bool>? leDomingo,
    Expression<String>? horariosDomingo,
    Expression<String>? leQuinta,
    Expression<bool>? leFesta,
    Expression<String>? soPastoral,
    Expression<int>? parId,
    Expression<String>? ultimaParticipacao,
    Expression<String>? observacoes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (vaiLer != null) 'vai_ler': vaiLer,
      if (fazAnimacao != null) 'faz_animacao': fazAnimacao,
      if (leDomingo != null) 'le_domingo': leDomingo,
      if (horariosDomingo != null) 'horarios_domingo': horariosDomingo,
      if (leQuinta != null) 'le_quinta': leQuinta,
      if (leFesta != null) 'le_festa': leFesta,
      if (soPastoral != null) 'so_pastoral': soPastoral,
      if (parId != null) 'par_id': parId,
      if (ultimaParticipacao != null) 'ultima_participacao': ultimaParticipacao,
      if (observacoes != null) 'observacoes': observacoes,
    });
  }

  LeitoresCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<bool>? vaiLer,
    Value<String>? fazAnimacao,
    Value<bool>? leDomingo,
    Value<String>? horariosDomingo,
    Value<String>? leQuinta,
    Value<bool>? leFesta,
    Value<String?>? soPastoral,
    Value<int?>? parId,
    Value<String?>? ultimaParticipacao,
    Value<String>? observacoes,
  }) {
    return LeitoresCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      vaiLer: vaiLer ?? this.vaiLer,
      fazAnimacao: fazAnimacao ?? this.fazAnimacao,
      leDomingo: leDomingo ?? this.leDomingo,
      horariosDomingo: horariosDomingo ?? this.horariosDomingo,
      leQuinta: leQuinta ?? this.leQuinta,
      leFesta: leFesta ?? this.leFesta,
      soPastoral: soPastoral ?? this.soPastoral,
      parId: parId ?? this.parId,
      ultimaParticipacao: ultimaParticipacao ?? this.ultimaParticipacao,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (vaiLer.present) {
      map['vai_ler'] = Variable<bool>(vaiLer.value);
    }
    if (fazAnimacao.present) {
      map['faz_animacao'] = Variable<String>(fazAnimacao.value);
    }
    if (leDomingo.present) {
      map['le_domingo'] = Variable<bool>(leDomingo.value);
    }
    if (horariosDomingo.present) {
      map['horarios_domingo'] = Variable<String>(horariosDomingo.value);
    }
    if (leQuinta.present) {
      map['le_quinta'] = Variable<String>(leQuinta.value);
    }
    if (leFesta.present) {
      map['le_festa'] = Variable<bool>(leFesta.value);
    }
    if (soPastoral.present) {
      map['so_pastoral'] = Variable<String>(soPastoral.value);
    }
    if (parId.present) {
      map['par_id'] = Variable<int>(parId.value);
    }
    if (ultimaParticipacao.present) {
      map['ultima_participacao'] = Variable<String>(ultimaParticipacao.value);
    }
    if (observacoes.present) {
      map['observacoes'] = Variable<String>(observacoes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeitoresCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('vaiLer: $vaiLer, ')
          ..write('fazAnimacao: $fazAnimacao, ')
          ..write('leDomingo: $leDomingo, ')
          ..write('horariosDomingo: $horariosDomingo, ')
          ..write('leQuinta: $leQuinta, ')
          ..write('leFesta: $leFesta, ')
          ..write('soPastoral: $soPastoral, ')
          ..write('parId: $parId, ')
          ..write('ultimaParticipacao: $ultimaParticipacao, ')
          ..write('observacoes: $observacoes')
          ..write(')'))
        .toString();
  }
}

class $RegrasTable extends Regras with TableInfo<$RegrasTable, RegraRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegrasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _leitorIdMeta = const VerificationMeta(
    'leitorId',
  );
  @override
  late final GeneratedColumn<int> leitorId = GeneratedColumn<int>(
    'leitor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES leitores (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dadosMeta = const VerificationMeta('dados');
  @override
  late final GeneratedColumn<String> dados = GeneratedColumn<String>(
    'dados',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, leitorId, dados];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'regras';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegraRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('leitor_id')) {
      context.handle(
        _leitorIdMeta,
        leitorId.isAcceptableOrUnknown(data['leitor_id']!, _leitorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_leitorIdMeta);
    }
    if (data.containsKey('dados')) {
      context.handle(
        _dadosMeta,
        dados.isAcceptableOrUnknown(data['dados']!, _dadosMeta),
      );
    } else if (isInserting) {
      context.missing(_dadosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegraRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegraRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      leitorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leitor_id'],
      )!,
      dados: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dados'],
      )!,
    );
  }

  @override
  $RegrasTable createAlias(String alias) {
    return $RegrasTable(attachedDatabase, alias);
  }
}

class RegraRow extends DataClass implements Insertable<RegraRow> {
  final int id;
  final int leitorId;

  /// [RegraEpoca] serializada em JSON.
  final String dados;
  const RegraRow({
    required this.id,
    required this.leitorId,
    required this.dados,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['leitor_id'] = Variable<int>(leitorId);
    map['dados'] = Variable<String>(dados);
    return map;
  }

  RegrasCompanion toCompanion(bool nullToAbsent) {
    return RegrasCompanion(
      id: Value(id),
      leitorId: Value(leitorId),
      dados: Value(dados),
    );
  }

  factory RegraRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegraRow(
      id: serializer.fromJson<int>(json['id']),
      leitorId: serializer.fromJson<int>(json['leitorId']),
      dados: serializer.fromJson<String>(json['dados']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'leitorId': serializer.toJson<int>(leitorId),
      'dados': serializer.toJson<String>(dados),
    };
  }

  RegraRow copyWith({int? id, int? leitorId, String? dados}) => RegraRow(
    id: id ?? this.id,
    leitorId: leitorId ?? this.leitorId,
    dados: dados ?? this.dados,
  );
  RegraRow copyWithCompanion(RegrasCompanion data) {
    return RegraRow(
      id: data.id.present ? data.id.value : this.id,
      leitorId: data.leitorId.present ? data.leitorId.value : this.leitorId,
      dados: data.dados.present ? data.dados.value : this.dados,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegraRow(')
          ..write('id: $id, ')
          ..write('leitorId: $leitorId, ')
          ..write('dados: $dados')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, leitorId, dados);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegraRow &&
          other.id == this.id &&
          other.leitorId == this.leitorId &&
          other.dados == this.dados);
}

class RegrasCompanion extends UpdateCompanion<RegraRow> {
  final Value<int> id;
  final Value<int> leitorId;
  final Value<String> dados;
  const RegrasCompanion({
    this.id = const Value.absent(),
    this.leitorId = const Value.absent(),
    this.dados = const Value.absent(),
  });
  RegrasCompanion.insert({
    this.id = const Value.absent(),
    required int leitorId,
    required String dados,
  }) : leitorId = Value(leitorId),
       dados = Value(dados);
  static Insertable<RegraRow> custom({
    Expression<int>? id,
    Expression<int>? leitorId,
    Expression<String>? dados,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (leitorId != null) 'leitor_id': leitorId,
      if (dados != null) 'dados': dados,
    });
  }

  RegrasCompanion copyWith({
    Value<int>? id,
    Value<int>? leitorId,
    Value<String>? dados,
  }) {
    return RegrasCompanion(
      id: id ?? this.id,
      leitorId: leitorId ?? this.leitorId,
      dados: dados ?? this.dados,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (leitorId.present) {
      map['leitor_id'] = Variable<int>(leitorId.value);
    }
    if (dados.present) {
      map['dados'] = Variable<String>(dados.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegrasCompanion(')
          ..write('id: $id, ')
          ..write('leitorId: $leitorId, ')
          ..write('dados: $dados')
          ..write(')'))
        .toString();
  }
}

class $CelebracoesTable extends Celebracoes
    with TableInfo<$CelebracoesTable, CelebracaoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CelebracoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horaMeta = const VerificationMeta('hora');
  @override
  late final GeneratedColumn<String> hora = GeneratedColumn<String>(
    'hora',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeLiturgicoMeta = const VerificationMeta(
    'nomeLiturgico',
  );
  @override
  late final GeneratedColumn<String> nomeLiturgico = GeneratedColumn<String>(
    'nome_liturgico',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _funcoesMeta = const VerificationMeta(
    'funcoes',
  );
  @override
  late final GeneratedColumn<String> funcoes = GeneratedColumn<String>(
    'funcoes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atribuicaoMeta = const VerificationMeta(
    'atribuicao',
  );
  @override
  late final GeneratedColumn<String> atribuicao = GeneratedColumn<String>(
    'atribuicao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('leitores'),
  );
  static const VerificationMeta _atribuicaoTextoMeta = const VerificationMeta(
    'atribuicaoTexto',
  );
  @override
  late final GeneratedColumn<String> atribuicaoTexto = GeneratedColumn<String>(
    'atribuicao_texto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pdfUrlMeta = const VerificationMeta('pdfUrl');
  @override
  late final GeneratedColumn<String> pdfUrl = GeneratedColumn<String>(
    'pdf_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pdfArquivoMeta = const VerificationMeta(
    'pdfArquivo',
  );
  @override
  late final GeneratedColumn<String> pdfArquivo = GeneratedColumn<String>(
    'pdf_arquivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pdfStatusMeta = const VerificationMeta(
    'pdfStatus',
  );
  @override
  late final GeneratedColumn<String> pdfStatus = GeneratedColumn<String>(
    'pdf_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pendente'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    data,
    hora,
    tipo,
    nomeLiturgico,
    funcoes,
    atribuicao,
    atribuicaoTexto,
    pdfUrl,
    pdfArquivo,
    pdfStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'celebracoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CelebracaoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('hora')) {
      context.handle(
        _horaMeta,
        hora.isAcceptableOrUnknown(data['hora']!, _horaMeta),
      );
    } else if (isInserting) {
      context.missing(_horaMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nome_liturgico')) {
      context.handle(
        _nomeLiturgicoMeta,
        nomeLiturgico.isAcceptableOrUnknown(
          data['nome_liturgico']!,
          _nomeLiturgicoMeta,
        ),
      );
    }
    if (data.containsKey('funcoes')) {
      context.handle(
        _funcoesMeta,
        funcoes.isAcceptableOrUnknown(data['funcoes']!, _funcoesMeta),
      );
    } else if (isInserting) {
      context.missing(_funcoesMeta);
    }
    if (data.containsKey('atribuicao')) {
      context.handle(
        _atribuicaoMeta,
        atribuicao.isAcceptableOrUnknown(data['atribuicao']!, _atribuicaoMeta),
      );
    }
    if (data.containsKey('atribuicao_texto')) {
      context.handle(
        _atribuicaoTextoMeta,
        atribuicaoTexto.isAcceptableOrUnknown(
          data['atribuicao_texto']!,
          _atribuicaoTextoMeta,
        ),
      );
    }
    if (data.containsKey('pdf_url')) {
      context.handle(
        _pdfUrlMeta,
        pdfUrl.isAcceptableOrUnknown(data['pdf_url']!, _pdfUrlMeta),
      );
    }
    if (data.containsKey('pdf_arquivo')) {
      context.handle(
        _pdfArquivoMeta,
        pdfArquivo.isAcceptableOrUnknown(data['pdf_arquivo']!, _pdfArquivoMeta),
      );
    }
    if (data.containsKey('pdf_status')) {
      context.handle(
        _pdfStatusMeta,
        pdfStatus.isAcceptableOrUnknown(data['pdf_status']!, _pdfStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CelebracaoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CelebracaoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      hora: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hora'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      nomeLiturgico: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_liturgico'],
      ),
      funcoes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}funcoes'],
      )!,
      atribuicao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}atribuicao'],
      )!,
      atribuicaoTexto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}atribuicao_texto'],
      ),
      pdfUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_url'],
      ),
      pdfArquivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_arquivo'],
      ),
      pdfStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_status'],
      )!,
    );
  }

  @override
  $CelebracoesTable createAlias(String alias) {
    return $CelebracoesTable(attachedDatabase, alias);
  }
}

class CelebracaoRow extends DataClass implements Insertable<CelebracaoRow> {
  final int id;
  final String data;
  final String hora;
  final String tipo;
  final String? nomeLiturgico;

  /// Nomes de [Funcao] separados por vírgula.
  final String funcoes;
  final String atribuicao;
  final String? atribuicaoTexto;
  final String? pdfUrl;
  final String? pdfArquivo;

  /// pendente | ok | naoPublicado
  final String pdfStatus;
  const CelebracaoRow({
    required this.id,
    required this.data,
    required this.hora,
    required this.tipo,
    this.nomeLiturgico,
    required this.funcoes,
    required this.atribuicao,
    this.atribuicaoTexto,
    this.pdfUrl,
    this.pdfArquivo,
    required this.pdfStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['data'] = Variable<String>(data);
    map['hora'] = Variable<String>(hora);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || nomeLiturgico != null) {
      map['nome_liturgico'] = Variable<String>(nomeLiturgico);
    }
    map['funcoes'] = Variable<String>(funcoes);
    map['atribuicao'] = Variable<String>(atribuicao);
    if (!nullToAbsent || atribuicaoTexto != null) {
      map['atribuicao_texto'] = Variable<String>(atribuicaoTexto);
    }
    if (!nullToAbsent || pdfUrl != null) {
      map['pdf_url'] = Variable<String>(pdfUrl);
    }
    if (!nullToAbsent || pdfArquivo != null) {
      map['pdf_arquivo'] = Variable<String>(pdfArquivo);
    }
    map['pdf_status'] = Variable<String>(pdfStatus);
    return map;
  }

  CelebracoesCompanion toCompanion(bool nullToAbsent) {
    return CelebracoesCompanion(
      id: Value(id),
      data: Value(data),
      hora: Value(hora),
      tipo: Value(tipo),
      nomeLiturgico: nomeLiturgico == null && nullToAbsent
          ? const Value.absent()
          : Value(nomeLiturgico),
      funcoes: Value(funcoes),
      atribuicao: Value(atribuicao),
      atribuicaoTexto: atribuicaoTexto == null && nullToAbsent
          ? const Value.absent()
          : Value(atribuicaoTexto),
      pdfUrl: pdfUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfUrl),
      pdfArquivo: pdfArquivo == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfArquivo),
      pdfStatus: Value(pdfStatus),
    );
  }

  factory CelebracaoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CelebracaoRow(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<String>(json['data']),
      hora: serializer.fromJson<String>(json['hora']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nomeLiturgico: serializer.fromJson<String?>(json['nomeLiturgico']),
      funcoes: serializer.fromJson<String>(json['funcoes']),
      atribuicao: serializer.fromJson<String>(json['atribuicao']),
      atribuicaoTexto: serializer.fromJson<String?>(json['atribuicaoTexto']),
      pdfUrl: serializer.fromJson<String?>(json['pdfUrl']),
      pdfArquivo: serializer.fromJson<String?>(json['pdfArquivo']),
      pdfStatus: serializer.fromJson<String>(json['pdfStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<String>(data),
      'hora': serializer.toJson<String>(hora),
      'tipo': serializer.toJson<String>(tipo),
      'nomeLiturgico': serializer.toJson<String?>(nomeLiturgico),
      'funcoes': serializer.toJson<String>(funcoes),
      'atribuicao': serializer.toJson<String>(atribuicao),
      'atribuicaoTexto': serializer.toJson<String?>(atribuicaoTexto),
      'pdfUrl': serializer.toJson<String?>(pdfUrl),
      'pdfArquivo': serializer.toJson<String?>(pdfArquivo),
      'pdfStatus': serializer.toJson<String>(pdfStatus),
    };
  }

  CelebracaoRow copyWith({
    int? id,
    String? data,
    String? hora,
    String? tipo,
    Value<String?> nomeLiturgico = const Value.absent(),
    String? funcoes,
    String? atribuicao,
    Value<String?> atribuicaoTexto = const Value.absent(),
    Value<String?> pdfUrl = const Value.absent(),
    Value<String?> pdfArquivo = const Value.absent(),
    String? pdfStatus,
  }) => CelebracaoRow(
    id: id ?? this.id,
    data: data ?? this.data,
    hora: hora ?? this.hora,
    tipo: tipo ?? this.tipo,
    nomeLiturgico: nomeLiturgico.present
        ? nomeLiturgico.value
        : this.nomeLiturgico,
    funcoes: funcoes ?? this.funcoes,
    atribuicao: atribuicao ?? this.atribuicao,
    atribuicaoTexto: atribuicaoTexto.present
        ? atribuicaoTexto.value
        : this.atribuicaoTexto,
    pdfUrl: pdfUrl.present ? pdfUrl.value : this.pdfUrl,
    pdfArquivo: pdfArquivo.present ? pdfArquivo.value : this.pdfArquivo,
    pdfStatus: pdfStatus ?? this.pdfStatus,
  );
  CelebracaoRow copyWithCompanion(CelebracoesCompanion data) {
    return CelebracaoRow(
      id: data.id.present ? data.id.value : this.id,
      data: data.data.present ? data.data.value : this.data,
      hora: data.hora.present ? data.hora.value : this.hora,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nomeLiturgico: data.nomeLiturgico.present
          ? data.nomeLiturgico.value
          : this.nomeLiturgico,
      funcoes: data.funcoes.present ? data.funcoes.value : this.funcoes,
      atribuicao: data.atribuicao.present
          ? data.atribuicao.value
          : this.atribuicao,
      atribuicaoTexto: data.atribuicaoTexto.present
          ? data.atribuicaoTexto.value
          : this.atribuicaoTexto,
      pdfUrl: data.pdfUrl.present ? data.pdfUrl.value : this.pdfUrl,
      pdfArquivo: data.pdfArquivo.present
          ? data.pdfArquivo.value
          : this.pdfArquivo,
      pdfStatus: data.pdfStatus.present ? data.pdfStatus.value : this.pdfStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CelebracaoRow(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('hora: $hora, ')
          ..write('tipo: $tipo, ')
          ..write('nomeLiturgico: $nomeLiturgico, ')
          ..write('funcoes: $funcoes, ')
          ..write('atribuicao: $atribuicao, ')
          ..write('atribuicaoTexto: $atribuicaoTexto, ')
          ..write('pdfUrl: $pdfUrl, ')
          ..write('pdfArquivo: $pdfArquivo, ')
          ..write('pdfStatus: $pdfStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    data,
    hora,
    tipo,
    nomeLiturgico,
    funcoes,
    atribuicao,
    atribuicaoTexto,
    pdfUrl,
    pdfArquivo,
    pdfStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CelebracaoRow &&
          other.id == this.id &&
          other.data == this.data &&
          other.hora == this.hora &&
          other.tipo == this.tipo &&
          other.nomeLiturgico == this.nomeLiturgico &&
          other.funcoes == this.funcoes &&
          other.atribuicao == this.atribuicao &&
          other.atribuicaoTexto == this.atribuicaoTexto &&
          other.pdfUrl == this.pdfUrl &&
          other.pdfArquivo == this.pdfArquivo &&
          other.pdfStatus == this.pdfStatus);
}

class CelebracoesCompanion extends UpdateCompanion<CelebracaoRow> {
  final Value<int> id;
  final Value<String> data;
  final Value<String> hora;
  final Value<String> tipo;
  final Value<String?> nomeLiturgico;
  final Value<String> funcoes;
  final Value<String> atribuicao;
  final Value<String?> atribuicaoTexto;
  final Value<String?> pdfUrl;
  final Value<String?> pdfArquivo;
  final Value<String> pdfStatus;
  const CelebracoesCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.hora = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nomeLiturgico = const Value.absent(),
    this.funcoes = const Value.absent(),
    this.atribuicao = const Value.absent(),
    this.atribuicaoTexto = const Value.absent(),
    this.pdfUrl = const Value.absent(),
    this.pdfArquivo = const Value.absent(),
    this.pdfStatus = const Value.absent(),
  });
  CelebracoesCompanion.insert({
    this.id = const Value.absent(),
    required String data,
    required String hora,
    required String tipo,
    this.nomeLiturgico = const Value.absent(),
    required String funcoes,
    this.atribuicao = const Value.absent(),
    this.atribuicaoTexto = const Value.absent(),
    this.pdfUrl = const Value.absent(),
    this.pdfArquivo = const Value.absent(),
    this.pdfStatus = const Value.absent(),
  }) : data = Value(data),
       hora = Value(hora),
       tipo = Value(tipo),
       funcoes = Value(funcoes);
  static Insertable<CelebracaoRow> custom({
    Expression<int>? id,
    Expression<String>? data,
    Expression<String>? hora,
    Expression<String>? tipo,
    Expression<String>? nomeLiturgico,
    Expression<String>? funcoes,
    Expression<String>? atribuicao,
    Expression<String>? atribuicaoTexto,
    Expression<String>? pdfUrl,
    Expression<String>? pdfArquivo,
    Expression<String>? pdfStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (hora != null) 'hora': hora,
      if (tipo != null) 'tipo': tipo,
      if (nomeLiturgico != null) 'nome_liturgico': nomeLiturgico,
      if (funcoes != null) 'funcoes': funcoes,
      if (atribuicao != null) 'atribuicao': atribuicao,
      if (atribuicaoTexto != null) 'atribuicao_texto': atribuicaoTexto,
      if (pdfUrl != null) 'pdf_url': pdfUrl,
      if (pdfArquivo != null) 'pdf_arquivo': pdfArquivo,
      if (pdfStatus != null) 'pdf_status': pdfStatus,
    });
  }

  CelebracoesCompanion copyWith({
    Value<int>? id,
    Value<String>? data,
    Value<String>? hora,
    Value<String>? tipo,
    Value<String?>? nomeLiturgico,
    Value<String>? funcoes,
    Value<String>? atribuicao,
    Value<String?>? atribuicaoTexto,
    Value<String?>? pdfUrl,
    Value<String?>? pdfArquivo,
    Value<String>? pdfStatus,
  }) {
    return CelebracoesCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      hora: hora ?? this.hora,
      tipo: tipo ?? this.tipo,
      nomeLiturgico: nomeLiturgico ?? this.nomeLiturgico,
      funcoes: funcoes ?? this.funcoes,
      atribuicao: atribuicao ?? this.atribuicao,
      atribuicaoTexto: atribuicaoTexto ?? this.atribuicaoTexto,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      pdfArquivo: pdfArquivo ?? this.pdfArquivo,
      pdfStatus: pdfStatus ?? this.pdfStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (hora.present) {
      map['hora'] = Variable<String>(hora.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nomeLiturgico.present) {
      map['nome_liturgico'] = Variable<String>(nomeLiturgico.value);
    }
    if (funcoes.present) {
      map['funcoes'] = Variable<String>(funcoes.value);
    }
    if (atribuicao.present) {
      map['atribuicao'] = Variable<String>(atribuicao.value);
    }
    if (atribuicaoTexto.present) {
      map['atribuicao_texto'] = Variable<String>(atribuicaoTexto.value);
    }
    if (pdfUrl.present) {
      map['pdf_url'] = Variable<String>(pdfUrl.value);
    }
    if (pdfArquivo.present) {
      map['pdf_arquivo'] = Variable<String>(pdfArquivo.value);
    }
    if (pdfStatus.present) {
      map['pdf_status'] = Variable<String>(pdfStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CelebracoesCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('hora: $hora, ')
          ..write('tipo: $tipo, ')
          ..write('nomeLiturgico: $nomeLiturgico, ')
          ..write('funcoes: $funcoes, ')
          ..write('atribuicao: $atribuicao, ')
          ..write('atribuicaoTexto: $atribuicaoTexto, ')
          ..write('pdfUrl: $pdfUrl, ')
          ..write('pdfArquivo: $pdfArquivo, ')
          ..write('pdfStatus: $pdfStatus')
          ..write(')'))
        .toString();
  }
}

class $VagasTable extends Vagas with TableInfo<$VagasTable, VagaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VagasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _celebracaoIdMeta = const VerificationMeta(
    'celebracaoId',
  );
  @override
  late final GeneratedColumn<int> celebracaoId = GeneratedColumn<int>(
    'celebracao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES celebracoes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _funcaoMeta = const VerificationMeta('funcao');
  @override
  late final GeneratedColumn<String> funcao = GeneratedColumn<String>(
    'funcao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leitorIdMeta = const VerificationMeta(
    'leitorId',
  );
  @override
  late final GeneratedColumn<int> leitorId = GeneratedColumn<int>(
    'leitor_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomeLivreMeta = const VerificationMeta(
    'nomeLivre',
  );
  @override
  late final GeneratedColumn<String> nomeLivre = GeneratedColumn<String>(
    'nome_livre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _travadaMeta = const VerificationMeta(
    'travada',
  );
  @override
  late final GeneratedColumn<bool> travada = GeneratedColumn<bool>(
    'travada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("travada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    celebracaoId,
    funcao,
    leitorId,
    nomeLivre,
    travada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vagas';
  @override
  VerificationContext validateIntegrity(
    Insertable<VagaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('celebracao_id')) {
      context.handle(
        _celebracaoIdMeta,
        celebracaoId.isAcceptableOrUnknown(
          data['celebracao_id']!,
          _celebracaoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_celebracaoIdMeta);
    }
    if (data.containsKey('funcao')) {
      context.handle(
        _funcaoMeta,
        funcao.isAcceptableOrUnknown(data['funcao']!, _funcaoMeta),
      );
    } else if (isInserting) {
      context.missing(_funcaoMeta);
    }
    if (data.containsKey('leitor_id')) {
      context.handle(
        _leitorIdMeta,
        leitorId.isAcceptableOrUnknown(data['leitor_id']!, _leitorIdMeta),
      );
    }
    if (data.containsKey('nome_livre')) {
      context.handle(
        _nomeLivreMeta,
        nomeLivre.isAcceptableOrUnknown(data['nome_livre']!, _nomeLivreMeta),
      );
    }
    if (data.containsKey('travada')) {
      context.handle(
        _travadaMeta,
        travada.isAcceptableOrUnknown(data['travada']!, _travadaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {celebracaoId, funcao};
  @override
  VagaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VagaRow(
      celebracaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}celebracao_id'],
      )!,
      funcao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}funcao'],
      )!,
      leitorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leitor_id'],
      ),
      nomeLivre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_livre'],
      ),
      travada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}travada'],
      )!,
    );
  }

  @override
  $VagasTable createAlias(String alias) {
    return $VagasTable(attachedDatabase, alias);
  }
}

class VagaRow extends DataClass implements Insertable<VagaRow> {
  final int celebracaoId;
  final String funcao;
  final int? leitorId;
  final String? nomeLivre;
  final bool travada;
  const VagaRow({
    required this.celebracaoId,
    required this.funcao,
    this.leitorId,
    this.nomeLivre,
    required this.travada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['celebracao_id'] = Variable<int>(celebracaoId);
    map['funcao'] = Variable<String>(funcao);
    if (!nullToAbsent || leitorId != null) {
      map['leitor_id'] = Variable<int>(leitorId);
    }
    if (!nullToAbsent || nomeLivre != null) {
      map['nome_livre'] = Variable<String>(nomeLivre);
    }
    map['travada'] = Variable<bool>(travada);
    return map;
  }

  VagasCompanion toCompanion(bool nullToAbsent) {
    return VagasCompanion(
      celebracaoId: Value(celebracaoId),
      funcao: Value(funcao),
      leitorId: leitorId == null && nullToAbsent
          ? const Value.absent()
          : Value(leitorId),
      nomeLivre: nomeLivre == null && nullToAbsent
          ? const Value.absent()
          : Value(nomeLivre),
      travada: Value(travada),
    );
  }

  factory VagaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VagaRow(
      celebracaoId: serializer.fromJson<int>(json['celebracaoId']),
      funcao: serializer.fromJson<String>(json['funcao']),
      leitorId: serializer.fromJson<int?>(json['leitorId']),
      nomeLivre: serializer.fromJson<String?>(json['nomeLivre']),
      travada: serializer.fromJson<bool>(json['travada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'celebracaoId': serializer.toJson<int>(celebracaoId),
      'funcao': serializer.toJson<String>(funcao),
      'leitorId': serializer.toJson<int?>(leitorId),
      'nomeLivre': serializer.toJson<String?>(nomeLivre),
      'travada': serializer.toJson<bool>(travada),
    };
  }

  VagaRow copyWith({
    int? celebracaoId,
    String? funcao,
    Value<int?> leitorId = const Value.absent(),
    Value<String?> nomeLivre = const Value.absent(),
    bool? travada,
  }) => VagaRow(
    celebracaoId: celebracaoId ?? this.celebracaoId,
    funcao: funcao ?? this.funcao,
    leitorId: leitorId.present ? leitorId.value : this.leitorId,
    nomeLivre: nomeLivre.present ? nomeLivre.value : this.nomeLivre,
    travada: travada ?? this.travada,
  );
  VagaRow copyWithCompanion(VagasCompanion data) {
    return VagaRow(
      celebracaoId: data.celebracaoId.present
          ? data.celebracaoId.value
          : this.celebracaoId,
      funcao: data.funcao.present ? data.funcao.value : this.funcao,
      leitorId: data.leitorId.present ? data.leitorId.value : this.leitorId,
      nomeLivre: data.nomeLivre.present ? data.nomeLivre.value : this.nomeLivre,
      travada: data.travada.present ? data.travada.value : this.travada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VagaRow(')
          ..write('celebracaoId: $celebracaoId, ')
          ..write('funcao: $funcao, ')
          ..write('leitorId: $leitorId, ')
          ..write('nomeLivre: $nomeLivre, ')
          ..write('travada: $travada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(celebracaoId, funcao, leitorId, nomeLivre, travada);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VagaRow &&
          other.celebracaoId == this.celebracaoId &&
          other.funcao == this.funcao &&
          other.leitorId == this.leitorId &&
          other.nomeLivre == this.nomeLivre &&
          other.travada == this.travada);
}

class VagasCompanion extends UpdateCompanion<VagaRow> {
  final Value<int> celebracaoId;
  final Value<String> funcao;
  final Value<int?> leitorId;
  final Value<String?> nomeLivre;
  final Value<bool> travada;
  final Value<int> rowid;
  const VagasCompanion({
    this.celebracaoId = const Value.absent(),
    this.funcao = const Value.absent(),
    this.leitorId = const Value.absent(),
    this.nomeLivre = const Value.absent(),
    this.travada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VagasCompanion.insert({
    required int celebracaoId,
    required String funcao,
    this.leitorId = const Value.absent(),
    this.nomeLivre = const Value.absent(),
    this.travada = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : celebracaoId = Value(celebracaoId),
       funcao = Value(funcao);
  static Insertable<VagaRow> custom({
    Expression<int>? celebracaoId,
    Expression<String>? funcao,
    Expression<int>? leitorId,
    Expression<String>? nomeLivre,
    Expression<bool>? travada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (celebracaoId != null) 'celebracao_id': celebracaoId,
      if (funcao != null) 'funcao': funcao,
      if (leitorId != null) 'leitor_id': leitorId,
      if (nomeLivre != null) 'nome_livre': nomeLivre,
      if (travada != null) 'travada': travada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VagasCompanion copyWith({
    Value<int>? celebracaoId,
    Value<String>? funcao,
    Value<int?>? leitorId,
    Value<String?>? nomeLivre,
    Value<bool>? travada,
    Value<int>? rowid,
  }) {
    return VagasCompanion(
      celebracaoId: celebracaoId ?? this.celebracaoId,
      funcao: funcao ?? this.funcao,
      leitorId: leitorId ?? this.leitorId,
      nomeLivre: nomeLivre ?? this.nomeLivre,
      travada: travada ?? this.travada,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (celebracaoId.present) {
      map['celebracao_id'] = Variable<int>(celebracaoId.value);
    }
    if (funcao.present) {
      map['funcao'] = Variable<String>(funcao.value);
    }
    if (leitorId.present) {
      map['leitor_id'] = Variable<int>(leitorId.value);
    }
    if (nomeLivre.present) {
      map['nome_livre'] = Variable<String>(nomeLivre.value);
    }
    if (travada.present) {
      map['travada'] = Variable<bool>(travada.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VagasCompanion(')
          ..write('celebracaoId: $celebracaoId, ')
          ..write('funcao: $funcao, ')
          ..write('leitorId: $leitorId, ')
          ..write('nomeLivre: $nomeLivre, ')
          ..write('travada: $travada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MesesTable extends Meses with TableInfo<$MesesTable, MesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MesesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _anoMeta = const VerificationMeta('ano');
  @override
  late final GeneratedColumn<int> ano = GeneratedColumn<int>(
    'ano',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mesMeta = const VerificationMeta('mes');
  @override
  late final GeneratedColumn<int> mes = GeneratedColumn<int>(
    'mes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('rascunho'),
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pastoraisMeta = const VerificationMeta(
    'pastorais',
  );
  @override
  late final GeneratedColumn<String> pastorais = GeneratedColumn<String>(
    'pastorais',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [ano, mes, status, seed, pastorais];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meses';
  @override
  VerificationContext validateIntegrity(
    Insertable<MesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ano')) {
      context.handle(
        _anoMeta,
        ano.isAcceptableOrUnknown(data['ano']!, _anoMeta),
      );
    } else if (isInserting) {
      context.missing(_anoMeta);
    }
    if (data.containsKey('mes')) {
      context.handle(
        _mesMeta,
        mes.isAcceptableOrUnknown(data['mes']!, _mesMeta),
      );
    } else if (isInserting) {
      context.missing(_mesMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    }
    if (data.containsKey('pastorais')) {
      context.handle(
        _pastoraisMeta,
        pastorais.isAcceptableOrUnknown(data['pastorais']!, _pastoraisMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ano, mes};
  @override
  MesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MesRow(
      ano: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ano'],
      )!,
      mes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
      pastorais: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pastorais'],
      ),
    );
  }

  @override
  $MesesTable createAlias(String alias) {
    return $MesesTable(attachedDatabase, alias);
  }
}

class MesRow extends DataClass implements Insertable<MesRow> {
  final int ano;
  final int mes;

  /// rascunho | publicado
  final String status;
  final int seed;

  /// Sobrescrita das pastorais neste mês (JSON), ou null para usar o padrão.
  final String? pastorais;
  const MesRow({
    required this.ano,
    required this.mes,
    required this.status,
    required this.seed,
    this.pastorais,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ano'] = Variable<int>(ano);
    map['mes'] = Variable<int>(mes);
    map['status'] = Variable<String>(status);
    map['seed'] = Variable<int>(seed);
    if (!nullToAbsent || pastorais != null) {
      map['pastorais'] = Variable<String>(pastorais);
    }
    return map;
  }

  MesesCompanion toCompanion(bool nullToAbsent) {
    return MesesCompanion(
      ano: Value(ano),
      mes: Value(mes),
      status: Value(status),
      seed: Value(seed),
      pastorais: pastorais == null && nullToAbsent
          ? const Value.absent()
          : Value(pastorais),
    );
  }

  factory MesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MesRow(
      ano: serializer.fromJson<int>(json['ano']),
      mes: serializer.fromJson<int>(json['mes']),
      status: serializer.fromJson<String>(json['status']),
      seed: serializer.fromJson<int>(json['seed']),
      pastorais: serializer.fromJson<String?>(json['pastorais']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ano': serializer.toJson<int>(ano),
      'mes': serializer.toJson<int>(mes),
      'status': serializer.toJson<String>(status),
      'seed': serializer.toJson<int>(seed),
      'pastorais': serializer.toJson<String?>(pastorais),
    };
  }

  MesRow copyWith({
    int? ano,
    int? mes,
    String? status,
    int? seed,
    Value<String?> pastorais = const Value.absent(),
  }) => MesRow(
    ano: ano ?? this.ano,
    mes: mes ?? this.mes,
    status: status ?? this.status,
    seed: seed ?? this.seed,
    pastorais: pastorais.present ? pastorais.value : this.pastorais,
  );
  MesRow copyWithCompanion(MesesCompanion data) {
    return MesRow(
      ano: data.ano.present ? data.ano.value : this.ano,
      mes: data.mes.present ? data.mes.value : this.mes,
      status: data.status.present ? data.status.value : this.status,
      seed: data.seed.present ? data.seed.value : this.seed,
      pastorais: data.pastorais.present ? data.pastorais.value : this.pastorais,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MesRow(')
          ..write('ano: $ano, ')
          ..write('mes: $mes, ')
          ..write('status: $status, ')
          ..write('seed: $seed, ')
          ..write('pastorais: $pastorais')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ano, mes, status, seed, pastorais);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MesRow &&
          other.ano == this.ano &&
          other.mes == this.mes &&
          other.status == this.status &&
          other.seed == this.seed &&
          other.pastorais == this.pastorais);
}

class MesesCompanion extends UpdateCompanion<MesRow> {
  final Value<int> ano;
  final Value<int> mes;
  final Value<String> status;
  final Value<int> seed;
  final Value<String?> pastorais;
  final Value<int> rowid;
  const MesesCompanion({
    this.ano = const Value.absent(),
    this.mes = const Value.absent(),
    this.status = const Value.absent(),
    this.seed = const Value.absent(),
    this.pastorais = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MesesCompanion.insert({
    required int ano,
    required int mes,
    this.status = const Value.absent(),
    this.seed = const Value.absent(),
    this.pastorais = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ano = Value(ano),
       mes = Value(mes);
  static Insertable<MesRow> custom({
    Expression<int>? ano,
    Expression<int>? mes,
    Expression<String>? status,
    Expression<int>? seed,
    Expression<String>? pastorais,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ano != null) 'ano': ano,
      if (mes != null) 'mes': mes,
      if (status != null) 'status': status,
      if (seed != null) 'seed': seed,
      if (pastorais != null) 'pastorais': pastorais,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MesesCompanion copyWith({
    Value<int>? ano,
    Value<int>? mes,
    Value<String>? status,
    Value<int>? seed,
    Value<String?>? pastorais,
    Value<int>? rowid,
  }) {
    return MesesCompanion(
      ano: ano ?? this.ano,
      mes: mes ?? this.mes,
      status: status ?? this.status,
      seed: seed ?? this.seed,
      pastorais: pastorais ?? this.pastorais,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ano.present) {
      map['ano'] = Variable<int>(ano.value);
    }
    if (mes.present) {
      map['mes'] = Variable<int>(mes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (pastorais.present) {
      map['pastorais'] = Variable<String>(pastorais.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MesesCompanion(')
          ..write('ano: $ano, ')
          ..write('mes: $mes, ')
          ..write('status: $status, ')
          ..write('seed: $seed, ')
          ..write('pastorais: $pastorais, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnviosTable extends Envios with TableInfo<$EnviosTable, EnvioRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnviosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enviadoEmMeta = const VerificationMeta(
    'enviadoEm',
  );
  @override
  late final GeneratedColumn<String> enviadoEm = GeneratedColumn<String>(
    'enviado_em',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [data, enviadoEm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'envios';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvioRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('enviado_em')) {
      context.handle(
        _enviadoEmMeta,
        enviadoEm.isAcceptableOrUnknown(data['enviado_em']!, _enviadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_enviadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {data};
  @override
  EnvioRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvioRow(
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      enviadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enviado_em'],
      )!,
    );
  }

  @override
  $EnviosTable createAlias(String alias) {
    return $EnviosTable(attachedDatabase, alias);
  }
}

class EnvioRow extends DataClass implements Insertable<EnvioRow> {
  final String data;
  final String enviadoEm;
  const EnvioRow({required this.data, required this.enviadoEm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['data'] = Variable<String>(data);
    map['enviado_em'] = Variable<String>(enviadoEm);
    return map;
  }

  EnviosCompanion toCompanion(bool nullToAbsent) {
    return EnviosCompanion(data: Value(data), enviadoEm: Value(enviadoEm));
  }

  factory EnvioRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvioRow(
      data: serializer.fromJson<String>(json['data']),
      enviadoEm: serializer.fromJson<String>(json['enviadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'data': serializer.toJson<String>(data),
      'enviadoEm': serializer.toJson<String>(enviadoEm),
    };
  }

  EnvioRow copyWith({String? data, String? enviadoEm}) =>
      EnvioRow(data: data ?? this.data, enviadoEm: enviadoEm ?? this.enviadoEm);
  EnvioRow copyWithCompanion(EnviosCompanion data) {
    return EnvioRow(
      data: data.data.present ? data.data.value : this.data,
      enviadoEm: data.enviadoEm.present ? data.enviadoEm.value : this.enviadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvioRow(')
          ..write('data: $data, ')
          ..write('enviadoEm: $enviadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(data, enviadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvioRow &&
          other.data == this.data &&
          other.enviadoEm == this.enviadoEm);
}

class EnviosCompanion extends UpdateCompanion<EnvioRow> {
  final Value<String> data;
  final Value<String> enviadoEm;
  final Value<int> rowid;
  const EnviosCompanion({
    this.data = const Value.absent(),
    this.enviadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnviosCompanion.insert({
    required String data,
    required String enviadoEm,
    this.rowid = const Value.absent(),
  }) : data = Value(data),
       enviadoEm = Value(enviadoEm);
  static Insertable<EnvioRow> custom({
    Expression<String>? data,
    Expression<String>? enviadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (data != null) 'data': data,
      if (enviadoEm != null) 'enviado_em': enviadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnviosCompanion copyWith({
    Value<String>? data,
    Value<String>? enviadoEm,
    Value<int>? rowid,
  }) {
    return EnviosCompanion(
      data: data ?? this.data,
      enviadoEm: enviadoEm ?? this.enviadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (enviadoEm.present) {
      map['enviado_em'] = Variable<String>(enviadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnviosCompanion(')
          ..write('data: $data, ')
          ..write('enviadoEm: $enviadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConfigsTable extends Configs with TableInfo<$ConfigsTable, ConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  ConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigRow(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $ConfigsTable createAlias(String alias) {
    return $ConfigsTable(attachedDatabase, alias);
  }
}

class ConfigRow extends DataClass implements Insertable<ConfigRow> {
  final String chave;
  final String valor;
  const ConfigRow({required this.chave, required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    map['valor'] = Variable<String>(valor);
    return map;
  }

  ConfigsCompanion toCompanion(bool nullToAbsent) {
    return ConfigsCompanion(chave: Value(chave), valor: Value(valor));
  }

  factory ConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigRow(
      chave: serializer.fromJson<String>(json['chave']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'valor': serializer.toJson<String>(valor),
    };
  }

  ConfigRow copyWith({String? chave, String? valor}) =>
      ConfigRow(chave: chave ?? this.chave, valor: valor ?? this.valor);
  ConfigRow copyWithCompanion(ConfigsCompanion data) {
    return ConfigRow(
      chave: data.chave.present ? data.chave.value : this.chave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigRow(')
          ..write('chave: $chave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigRow &&
          other.chave == this.chave &&
          other.valor == this.valor);
}

class ConfigsCompanion extends UpdateCompanion<ConfigRow> {
  final Value<String> chave;
  final Value<String> valor;
  final Value<int> rowid;
  const ConfigsCompanion({
    this.chave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfigsCompanion.insert({
    required String chave,
    required String valor,
    this.rowid = const Value.absent(),
  }) : chave = Value(chave),
       valor = Value(valor);
  static Insertable<ConfigRow> custom({
    Expression<String>? chave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfigsCompanion copyWith({
    Value<String>? chave,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return ConfigsCompanion(
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigsCompanion(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Banco extends GeneratedDatabase {
  _$Banco(QueryExecutor e) : super(e);
  $BancoManager get managers => $BancoManager(this);
  late final $LeitoresTable leitores = $LeitoresTable(this);
  late final $RegrasTable regras = $RegrasTable(this);
  late final $CelebracoesTable celebracoes = $CelebracoesTable(this);
  late final $VagasTable vagas = $VagasTable(this);
  late final $MesesTable meses = $MesesTable(this);
  late final $EnviosTable envios = $EnviosTable(this);
  late final $ConfigsTable configs = $ConfigsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    leitores,
    regras,
    celebracoes,
    vagas,
    meses,
    envios,
    configs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'leitores',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('regras', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'celebracoes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vagas', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LeitoresTableCreateCompanionBuilder = LeitoresCompanion Function({
  Value<int> id,
  required String nome,
  Value<bool> vaiLer,
  Value<String> fazAnimacao,
  Value<bool> leDomingo,
  Value<String> horariosDomingo,
  Value<String> leQuinta,
  Value<bool> leFesta,
  Value<String?> soPastoral,
  Value<int?> parId,
  Value<String?> ultimaParticipacao,
  Value<String> observacoes,
});
typedef $$LeitoresTableUpdateCompanionBuilder = LeitoresCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<bool> vaiLer,
  Value<String> fazAnimacao,
  Value<bool> leDomingo,
  Value<String> horariosDomingo,
  Value<String> leQuinta,
  Value<bool> leFesta,
  Value<String?> soPastoral,
  Value<int?> parId,
  Value<String?> ultimaParticipacao,
  Value<String> observacoes,
});

final class $$LeitoresTableReferences
    extends BaseReferences<_$Banco, $LeitoresTable, LeitorRow> {
  $$LeitoresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RegrasTable, List<RegraRow>> _regrasRefsTable(
    _$Banco db,
  ) => MultiTypedResultKey.fromTable(
    db.regras,
    aliasName: 'leitores__id__regras__leitor_id',
  );

  $$RegrasTableProcessedTableManager get regrasRefs {
    final manager = $$RegrasTableTableManager(
      $_db,
      $_db.regras,
    ).filter((f) => f.leitorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_regrasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LeitoresTableFilterComposer extends Composer<_$Banco, $LeitoresTable> {
  $$LeitoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vaiLer => $composableBuilder(
    column: $table.vaiLer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fazAnimacao => $composableBuilder(
    column: $table.fazAnimacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get leDomingo => $composableBuilder(
    column: $table.leDomingo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horariosDomingo => $composableBuilder(
    column: $table.horariosDomingo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leQuinta => $composableBuilder(
    column: $table.leQuinta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get leFesta => $composableBuilder(
    column: $table.leFesta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soPastoral => $composableBuilder(
    column: $table.soPastoral,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parId => $composableBuilder(
    column: $table.parId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ultimaParticipacao => $composableBuilder(
    column: $table.ultimaParticipacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> regrasRefs(
    Expression<bool> Function($$RegrasTableFilterComposer f) f,
  ) {
    final $$RegrasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.regras,
      getReferencedColumn: (t) => t.leitorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegrasTableFilterComposer(
            $db: $db,
            $table: $db.regras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LeitoresTableOrderingComposer
    extends Composer<_$Banco, $LeitoresTable> {
  $$LeitoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vaiLer => $composableBuilder(
    column: $table.vaiLer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fazAnimacao => $composableBuilder(
    column: $table.fazAnimacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get leDomingo => $composableBuilder(
    column: $table.leDomingo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horariosDomingo => $composableBuilder(
    column: $table.horariosDomingo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leQuinta => $composableBuilder(
    column: $table.leQuinta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get leFesta => $composableBuilder(
    column: $table.leFesta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soPastoral => $composableBuilder(
    column: $table.soPastoral,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parId => $composableBuilder(
    column: $table.parId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ultimaParticipacao => $composableBuilder(
    column: $table.ultimaParticipacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeitoresTableAnnotationComposer
    extends Composer<_$Banco, $LeitoresTable> {
  $$LeitoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<bool> get vaiLer =>
      $composableBuilder(column: $table.vaiLer, builder: (column) => column);

  GeneratedColumn<String> get fazAnimacao => $composableBuilder(
    column: $table.fazAnimacao,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get leDomingo =>
      $composableBuilder(column: $table.leDomingo, builder: (column) => column);

  GeneratedColumn<String> get horariosDomingo => $composableBuilder(
    column: $table.horariosDomingo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leQuinta =>
      $composableBuilder(column: $table.leQuinta, builder: (column) => column);

  GeneratedColumn<bool> get leFesta =>
      $composableBuilder(column: $table.leFesta, builder: (column) => column);

  GeneratedColumn<String> get soPastoral => $composableBuilder(
    column: $table.soPastoral,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parId =>
      $composableBuilder(column: $table.parId, builder: (column) => column);

  GeneratedColumn<String> get ultimaParticipacao => $composableBuilder(
    column: $table.ultimaParticipacao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => column,
  );

  Expression<T> regrasRefs<T extends Object>(
    Expression<T> Function($$RegrasTableAnnotationComposer a) f,
  ) {
    final $$RegrasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.regras,
      getReferencedColumn: (t) => t.leitorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegrasTableAnnotationComposer(
            $db: $db,
            $table: $db.regras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LeitoresTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $LeitoresTable,
          LeitorRow,
          $$LeitoresTableFilterComposer,
          $$LeitoresTableOrderingComposer,
          $$LeitoresTableAnnotationComposer,
          $$LeitoresTableCreateCompanionBuilder,
          $$LeitoresTableUpdateCompanionBuilder,
          (LeitorRow, $$LeitoresTableReferences),
          LeitorRow,
          PrefetchHooks Function({bool regrasRefs})
        > {
  $$LeitoresTableTableManager(_$Banco db, $LeitoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeitoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeitoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeitoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<bool> vaiLer = const Value.absent(),
                Value<String> fazAnimacao = const Value.absent(),
                Value<bool> leDomingo = const Value.absent(),
                Value<String> horariosDomingo = const Value.absent(),
                Value<String> leQuinta = const Value.absent(),
                Value<bool> leFesta = const Value.absent(),
                Value<String?> soPastoral = const Value.absent(),
                Value<int?> parId = const Value.absent(),
                Value<String?> ultimaParticipacao = const Value.absent(),
                Value<String> observacoes = const Value.absent(),
              }) => LeitoresCompanion(
                id: id,
                nome: nome,
                vaiLer: vaiLer,
                fazAnimacao: fazAnimacao,
                leDomingo: leDomingo,
                horariosDomingo: horariosDomingo,
                leQuinta: leQuinta,
                leFesta: leFesta,
                soPastoral: soPastoral,
                parId: parId,
                ultimaParticipacao: ultimaParticipacao,
                observacoes: observacoes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                Value<bool> vaiLer = const Value.absent(),
                Value<String> fazAnimacao = const Value.absent(),
                Value<bool> leDomingo = const Value.absent(),
                Value<String> horariosDomingo = const Value.absent(),
                Value<String> leQuinta = const Value.absent(),
                Value<bool> leFesta = const Value.absent(),
                Value<String?> soPastoral = const Value.absent(),
                Value<int?> parId = const Value.absent(),
                Value<String?> ultimaParticipacao = const Value.absent(),
                Value<String> observacoes = const Value.absent(),
              }) => LeitoresCompanion.insert(
                id: id,
                nome: nome,
                vaiLer: vaiLer,
                fazAnimacao: fazAnimacao,
                leDomingo: leDomingo,
                horariosDomingo: horariosDomingo,
                leQuinta: leQuinta,
                leFesta: leFesta,
                soPastoral: soPastoral,
                parId: parId,
                ultimaParticipacao: ultimaParticipacao,
                observacoes: observacoes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LeitoresTable, LeitorRow>(table),
                  $$LeitoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({regrasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (regrasRefs) db.regras],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (regrasRefs)
                    await $_getPrefetchedDataByColumns<
                      LeitorRow,
                      $LeitoresTable,
                      RegraRow,
                      $RegrasTable
                    >(
                      currentTable: table,
                      referencedTable: $$LeitoresTableReferences
                          ._regrasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LeitoresTableReferences(db, table, p0).regrasRefs,
                      currentColumn: 'id',
                      referencedColumn: 'leitor_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LeitoresTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $LeitoresTable,
      LeitorRow,
      $$LeitoresTableFilterComposer,
      $$LeitoresTableOrderingComposer,
      $$LeitoresTableAnnotationComposer,
      $$LeitoresTableCreateCompanionBuilder,
      $$LeitoresTableUpdateCompanionBuilder,
      (LeitorRow, $$LeitoresTableReferences),
      LeitorRow,
      PrefetchHooks Function({bool regrasRefs})
    >;
typedef $$RegrasTableCreateCompanionBuilder = RegrasCompanion Function({
  Value<int> id,
  required int leitorId,
  required String dados,
});
typedef $$RegrasTableUpdateCompanionBuilder = RegrasCompanion Function({
  Value<int> id,
  Value<int> leitorId,
  Value<String> dados,
});

final class $$RegrasTableReferences
    extends BaseReferences<_$Banco, $RegrasTable, RegraRow> {
  $$RegrasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LeitoresTable _leitorIdTable(_$Banco db) =>
      db.leitores.createAlias('regras__leitor_id__leitores__id');

  $$LeitoresTableProcessedTableManager get leitorId {
    final $_column = $_itemColumn<int>('leitor_id')!;

    final manager = $$LeitoresTableTableManager(
      $_db,
      $_db.leitores,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_leitorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RegrasTableFilterComposer extends Composer<_$Banco, $RegrasTable> {
  $$RegrasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dados => $composableBuilder(
    column: $table.dados,
    builder: (column) => ColumnFilters(column),
  );

  $$LeitoresTableFilterComposer get leitorId {
    final $$LeitoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.leitorId,
      referencedTable: $db.leitores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LeitoresTableFilterComposer(
            $db: $db,
            $table: $db.leitores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegrasTableOrderingComposer extends Composer<_$Banco, $RegrasTable> {
  $$RegrasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dados => $composableBuilder(
    column: $table.dados,
    builder: (column) => ColumnOrderings(column),
  );

  $$LeitoresTableOrderingComposer get leitorId {
    final $$LeitoresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.leitorId,
      referencedTable: $db.leitores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LeitoresTableOrderingComposer(
            $db: $db,
            $table: $db.leitores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegrasTableAnnotationComposer extends Composer<_$Banco, $RegrasTable> {
  $$RegrasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dados =>
      $composableBuilder(column: $table.dados, builder: (column) => column);

  $$LeitoresTableAnnotationComposer get leitorId {
    final $$LeitoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.leitorId,
      referencedTable: $db.leitores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LeitoresTableAnnotationComposer(
            $db: $db,
            $table: $db.leitores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegrasTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $RegrasTable,
          RegraRow,
          $$RegrasTableFilterComposer,
          $$RegrasTableOrderingComposer,
          $$RegrasTableAnnotationComposer,
          $$RegrasTableCreateCompanionBuilder,
          $$RegrasTableUpdateCompanionBuilder,
          (RegraRow, $$RegrasTableReferences),
          RegraRow,
          PrefetchHooks Function({bool leitorId})
        > {
  $$RegrasTableTableManager(_$Banco db, $RegrasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegrasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegrasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegrasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> leitorId = const Value.absent(),
            Value<String> dados = const Value.absent(),
          }) => RegrasCompanion(id: id, leitorId: leitorId, dados: dados),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int leitorId,
                required String dados,
              }) => RegrasCompanion.insert(
                id: id,
                leitorId: leitorId,
                dados: dados,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RegrasTable, RegraRow>(table),
                  $$RegrasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({leitorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (leitorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.leitorId,
                        referencedTable: $$RegrasTableReferences._leitorIdTable(
                          db,
                        ),
                        referencedColumn: $$RegrasTableReferences
                            ._leitorIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RegrasTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $RegrasTable,
      RegraRow,
      $$RegrasTableFilterComposer,
      $$RegrasTableOrderingComposer,
      $$RegrasTableAnnotationComposer,
      $$RegrasTableCreateCompanionBuilder,
      $$RegrasTableUpdateCompanionBuilder,
      (RegraRow, $$RegrasTableReferences),
      RegraRow,
      PrefetchHooks Function({bool leitorId})
    >;
typedef $$CelebracoesTableCreateCompanionBuilder =
    CelebracoesCompanion Function({
      Value<int> id,
      required String data,
      required String hora,
      required String tipo,
      Value<String?> nomeLiturgico,
      required String funcoes,
      Value<String> atribuicao,
      Value<String?> atribuicaoTexto,
      Value<String?> pdfUrl,
      Value<String?> pdfArquivo,
      Value<String> pdfStatus,
    });
typedef $$CelebracoesTableUpdateCompanionBuilder =
    CelebracoesCompanion Function({
      Value<int> id,
      Value<String> data,
      Value<String> hora,
      Value<String> tipo,
      Value<String?> nomeLiturgico,
      Value<String> funcoes,
      Value<String> atribuicao,
      Value<String?> atribuicaoTexto,
      Value<String?> pdfUrl,
      Value<String?> pdfArquivo,
      Value<String> pdfStatus,
    });

final class $$CelebracoesTableReferences
    extends BaseReferences<_$Banco, $CelebracoesTable, CelebracaoRow> {
  $$CelebracoesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VagasTable, List<VagaRow>> _vagasRefsTable(
    _$Banco db,
  ) => MultiTypedResultKey.fromTable(
    db.vagas,
    aliasName: 'celebracoes__id__vagas__celebracao_id',
  );

  $$VagasTableProcessedTableManager get vagasRefs {
    final manager = $$VagasTableTableManager(
      $_db,
      $_db.vagas,
    ).filter((f) => f.celebracaoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vagasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CelebracoesTableFilterComposer
    extends Composer<_$Banco, $CelebracoesTable> {
  $$CelebracoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomeLiturgico => $composableBuilder(
    column: $table.nomeLiturgico,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get funcoes => $composableBuilder(
    column: $table.funcoes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get atribuicao => $composableBuilder(
    column: $table.atribuicao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get atribuicaoTexto => $composableBuilder(
    column: $table.atribuicaoTexto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfUrl => $composableBuilder(
    column: $table.pdfUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfArquivo => $composableBuilder(
    column: $table.pdfArquivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfStatus => $composableBuilder(
    column: $table.pdfStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> vagasRefs(
    Expression<bool> Function($$VagasTableFilterComposer f) f,
  ) {
    final $$VagasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vagas,
      getReferencedColumn: (t) => t.celebracaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VagasTableFilterComposer(
            $db: $db,
            $table: $db.vagas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CelebracoesTableOrderingComposer
    extends Composer<_$Banco, $CelebracoesTable> {
  $$CelebracoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomeLiturgico => $composableBuilder(
    column: $table.nomeLiturgico,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get funcoes => $composableBuilder(
    column: $table.funcoes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get atribuicao => $composableBuilder(
    column: $table.atribuicao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get atribuicaoTexto => $composableBuilder(
    column: $table.atribuicaoTexto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfUrl => $composableBuilder(
    column: $table.pdfUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfArquivo => $composableBuilder(
    column: $table.pdfArquivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfStatus => $composableBuilder(
    column: $table.pdfStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CelebracoesTableAnnotationComposer
    extends Composer<_$Banco, $CelebracoesTable> {
  $$CelebracoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get hora =>
      $composableBuilder(column: $table.hora, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nomeLiturgico => $composableBuilder(
    column: $table.nomeLiturgico,
    builder: (column) => column,
  );

  GeneratedColumn<String> get funcoes =>
      $composableBuilder(column: $table.funcoes, builder: (column) => column);

  GeneratedColumn<String> get atribuicao => $composableBuilder(
    column: $table.atribuicao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get atribuicaoTexto => $composableBuilder(
    column: $table.atribuicaoTexto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pdfUrl =>
      $composableBuilder(column: $table.pdfUrl, builder: (column) => column);

  GeneratedColumn<String> get pdfArquivo => $composableBuilder(
    column: $table.pdfArquivo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pdfStatus =>
      $composableBuilder(column: $table.pdfStatus, builder: (column) => column);

  Expression<T> vagasRefs<T extends Object>(
    Expression<T> Function($$VagasTableAnnotationComposer a) f,
  ) {
    final $$VagasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vagas,
      getReferencedColumn: (t) => t.celebracaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VagasTableAnnotationComposer(
            $db: $db,
            $table: $db.vagas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CelebracoesTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $CelebracoesTable,
          CelebracaoRow,
          $$CelebracoesTableFilterComposer,
          $$CelebracoesTableOrderingComposer,
          $$CelebracoesTableAnnotationComposer,
          $$CelebracoesTableCreateCompanionBuilder,
          $$CelebracoesTableUpdateCompanionBuilder,
          (CelebracaoRow, $$CelebracoesTableReferences),
          CelebracaoRow,
          PrefetchHooks Function({bool vagasRefs})
        > {
  $$CelebracoesTableTableManager(_$Banco db, $CelebracoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CelebracoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CelebracoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CelebracoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<String> hora = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> nomeLiturgico = const Value.absent(),
                Value<String> funcoes = const Value.absent(),
                Value<String> atribuicao = const Value.absent(),
                Value<String?> atribuicaoTexto = const Value.absent(),
                Value<String?> pdfUrl = const Value.absent(),
                Value<String?> pdfArquivo = const Value.absent(),
                Value<String> pdfStatus = const Value.absent(),
              }) => CelebracoesCompanion(
                id: id,
                data: data,
                hora: hora,
                tipo: tipo,
                nomeLiturgico: nomeLiturgico,
                funcoes: funcoes,
                atribuicao: atribuicao,
                atribuicaoTexto: atribuicaoTexto,
                pdfUrl: pdfUrl,
                pdfArquivo: pdfArquivo,
                pdfStatus: pdfStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String data,
                required String hora,
                required String tipo,
                Value<String?> nomeLiturgico = const Value.absent(),
                required String funcoes,
                Value<String> atribuicao = const Value.absent(),
                Value<String?> atribuicaoTexto = const Value.absent(),
                Value<String?> pdfUrl = const Value.absent(),
                Value<String?> pdfArquivo = const Value.absent(),
                Value<String> pdfStatus = const Value.absent(),
              }) => CelebracoesCompanion.insert(
                id: id,
                data: data,
                hora: hora,
                tipo: tipo,
                nomeLiturgico: nomeLiturgico,
                funcoes: funcoes,
                atribuicao: atribuicao,
                atribuicaoTexto: atribuicaoTexto,
                pdfUrl: pdfUrl,
                pdfArquivo: pdfArquivo,
                pdfStatus: pdfStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CelebracoesTable, CelebracaoRow>(table),
                  $$CelebracoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vagasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (vagasRefs) db.vagas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vagasRefs)
                    await $_getPrefetchedDataByColumns<
                      CelebracaoRow,
                      $CelebracoesTable,
                      VagaRow,
                      $VagasTable
                    >(
                      currentTable: table,
                      referencedTable: $$CelebracoesTableReferences
                          ._vagasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CelebracoesTableReferences(db, table, p0).vagasRefs,
                      currentColumn: 'id',
                      referencedColumn: 'celebracao_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CelebracoesTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $CelebracoesTable,
      CelebracaoRow,
      $$CelebracoesTableFilterComposer,
      $$CelebracoesTableOrderingComposer,
      $$CelebracoesTableAnnotationComposer,
      $$CelebracoesTableCreateCompanionBuilder,
      $$CelebracoesTableUpdateCompanionBuilder,
      (CelebracaoRow, $$CelebracoesTableReferences),
      CelebracaoRow,
      PrefetchHooks Function({bool vagasRefs})
    >;
typedef $$VagasTableCreateCompanionBuilder = VagasCompanion Function({
  required int celebracaoId,
  required String funcao,
  Value<int?> leitorId,
  Value<String?> nomeLivre,
  Value<bool> travada,
  Value<int> rowid,
});
typedef $$VagasTableUpdateCompanionBuilder = VagasCompanion Function({
  Value<int> celebracaoId,
  Value<String> funcao,
  Value<int?> leitorId,
  Value<String?> nomeLivre,
  Value<bool> travada,
  Value<int> rowid,
});

final class $$VagasTableReferences
    extends BaseReferences<_$Banco, $VagasTable, VagaRow> {
  $$VagasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CelebracoesTable _celebracaoIdTable(_$Banco db) =>
      db.celebracoes.createAlias('vagas__celebracao_id__celebracoes__id');

  $$CelebracoesTableProcessedTableManager get celebracaoId {
    final $_column = $_itemColumn<int>('celebracao_id')!;

    final manager = $$CelebracoesTableTableManager(
      $_db,
      $_db.celebracoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_celebracaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VagasTableFilterComposer extends Composer<_$Banco, $VagasTable> {
  $$VagasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get funcao => $composableBuilder(
    column: $table.funcao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leitorId => $composableBuilder(
    column: $table.leitorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomeLivre => $composableBuilder(
    column: $table.nomeLivre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get travada => $composableBuilder(
    column: $table.travada,
    builder: (column) => ColumnFilters(column),
  );

  $$CelebracoesTableFilterComposer get celebracaoId {
    final $$CelebracoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.celebracaoId,
      referencedTable: $db.celebracoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CelebracoesTableFilterComposer(
            $db: $db,
            $table: $db.celebracoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VagasTableOrderingComposer extends Composer<_$Banco, $VagasTable> {
  $$VagasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get funcao => $composableBuilder(
    column: $table.funcao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leitorId => $composableBuilder(
    column: $table.leitorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomeLivre => $composableBuilder(
    column: $table.nomeLivre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get travada => $composableBuilder(
    column: $table.travada,
    builder: (column) => ColumnOrderings(column),
  );

  $$CelebracoesTableOrderingComposer get celebracaoId {
    final $$CelebracoesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.celebracaoId,
      referencedTable: $db.celebracoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CelebracoesTableOrderingComposer(
            $db: $db,
            $table: $db.celebracoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VagasTableAnnotationComposer extends Composer<_$Banco, $VagasTable> {
  $$VagasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get funcao =>
      $composableBuilder(column: $table.funcao, builder: (column) => column);

  GeneratedColumn<int> get leitorId =>
      $composableBuilder(column: $table.leitorId, builder: (column) => column);

  GeneratedColumn<String> get nomeLivre =>
      $composableBuilder(column: $table.nomeLivre, builder: (column) => column);

  GeneratedColumn<bool> get travada =>
      $composableBuilder(column: $table.travada, builder: (column) => column);

  $$CelebracoesTableAnnotationComposer get celebracaoId {
    final $$CelebracoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.celebracaoId,
      referencedTable: $db.celebracoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CelebracoesTableAnnotationComposer(
            $db: $db,
            $table: $db.celebracoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VagasTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $VagasTable,
          VagaRow,
          $$VagasTableFilterComposer,
          $$VagasTableOrderingComposer,
          $$VagasTableAnnotationComposer,
          $$VagasTableCreateCompanionBuilder,
          $$VagasTableUpdateCompanionBuilder,
          (VagaRow, $$VagasTableReferences),
          VagaRow,
          PrefetchHooks Function({bool celebracaoId})
        > {
  $$VagasTableTableManager(_$Banco db, $VagasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VagasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VagasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VagasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> celebracaoId = const Value.absent(),
                Value<String> funcao = const Value.absent(),
                Value<int?> leitorId = const Value.absent(),
                Value<String?> nomeLivre = const Value.absent(),
                Value<bool> travada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VagasCompanion(
                celebracaoId: celebracaoId,
                funcao: funcao,
                leitorId: leitorId,
                nomeLivre: nomeLivre,
                travada: travada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int celebracaoId,
                required String funcao,
                Value<int?> leitorId = const Value.absent(),
                Value<String?> nomeLivre = const Value.absent(),
                Value<bool> travada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VagasCompanion.insert(
                celebracaoId: celebracaoId,
                funcao: funcao,
                leitorId: leitorId,
                nomeLivre: nomeLivre,
                travada: travada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VagasTable, VagaRow>(table),
                  $$VagasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({celebracaoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (celebracaoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.celebracaoId,
                        referencedTable: $$VagasTableReferences
                            ._celebracaoIdTable(db),
                        referencedColumn: $$VagasTableReferences
                            ._celebracaoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VagasTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $VagasTable,
      VagaRow,
      $$VagasTableFilterComposer,
      $$VagasTableOrderingComposer,
      $$VagasTableAnnotationComposer,
      $$VagasTableCreateCompanionBuilder,
      $$VagasTableUpdateCompanionBuilder,
      (VagaRow, $$VagasTableReferences),
      VagaRow,
      PrefetchHooks Function({bool celebracaoId})
    >;
typedef $$MesesTableCreateCompanionBuilder = MesesCompanion Function({
  required int ano,
  required int mes,
  Value<String> status,
  Value<int> seed,
  Value<String?> pastorais,
  Value<int> rowid,
});
typedef $$MesesTableUpdateCompanionBuilder = MesesCompanion Function({
  Value<int> ano,
  Value<int> mes,
  Value<String> status,
  Value<int> seed,
  Value<String?> pastorais,
  Value<int> rowid,
});

class $$MesesTableFilterComposer extends Composer<_$Banco, $MesesTable> {
  $$MesesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ano => $composableBuilder(
    column: $table.ano,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mes => $composableBuilder(
    column: $table.mes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pastorais => $composableBuilder(
    column: $table.pastorais,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MesesTableOrderingComposer extends Composer<_$Banco, $MesesTable> {
  $$MesesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ano => $composableBuilder(
    column: $table.ano,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mes => $composableBuilder(
    column: $table.mes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pastorais => $composableBuilder(
    column: $table.pastorais,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MesesTableAnnotationComposer extends Composer<_$Banco, $MesesTable> {
  $$MesesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ano =>
      $composableBuilder(column: $table.ano, builder: (column) => column);

  GeneratedColumn<int> get mes =>
      $composableBuilder(column: $table.mes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<String> get pastorais =>
      $composableBuilder(column: $table.pastorais, builder: (column) => column);
}

class $$MesesTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $MesesTable,
          MesRow,
          $$MesesTableFilterComposer,
          $$MesesTableOrderingComposer,
          $$MesesTableAnnotationComposer,
          $$MesesTableCreateCompanionBuilder,
          $$MesesTableUpdateCompanionBuilder,
          (MesRow, BaseReferences<_$Banco, $MesesTable, MesRow>),
          MesRow,
          PrefetchHooks Function()
        > {
  $$MesesTableTableManager(_$Banco db, $MesesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MesesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MesesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MesesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> ano = const Value.absent(),
                Value<int> mes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<String?> pastorais = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MesesCompanion(
                ano: ano,
                mes: mes,
                status: status,
                seed: seed,
                pastorais: pastorais,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int ano,
                required int mes,
                Value<String> status = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<String?> pastorais = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MesesCompanion.insert(
                ano: ano,
                mes: mes,
                status: status,
                seed: seed,
                pastorais: pastorais,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MesesTable, MesRow>(table),
                  BaseReferences<_$Banco, $MesesTable, MesRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MesesTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $MesesTable,
      MesRow,
      $$MesesTableFilterComposer,
      $$MesesTableOrderingComposer,
      $$MesesTableAnnotationComposer,
      $$MesesTableCreateCompanionBuilder,
      $$MesesTableUpdateCompanionBuilder,
      (MesRow, BaseReferences<_$Banco, $MesesTable, MesRow>),
      MesRow,
      PrefetchHooks Function()
    >;
typedef $$EnviosTableCreateCompanionBuilder = EnviosCompanion Function({
  required String data,
  required String enviadoEm,
  Value<int> rowid,
});
typedef $$EnviosTableUpdateCompanionBuilder = EnviosCompanion Function({
  Value<String> data,
  Value<String> enviadoEm,
  Value<int> rowid,
});

class $$EnviosTableFilterComposer extends Composer<_$Banco, $EnviosTable> {
  $$EnviosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enviadoEm => $composableBuilder(
    column: $table.enviadoEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnviosTableOrderingComposer extends Composer<_$Banco, $EnviosTable> {
  $$EnviosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enviadoEm => $composableBuilder(
    column: $table.enviadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnviosTableAnnotationComposer extends Composer<_$Banco, $EnviosTable> {
  $$EnviosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get enviadoEm =>
      $composableBuilder(column: $table.enviadoEm, builder: (column) => column);
}

class $$EnviosTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $EnviosTable,
          EnvioRow,
          $$EnviosTableFilterComposer,
          $$EnviosTableOrderingComposer,
          $$EnviosTableAnnotationComposer,
          $$EnviosTableCreateCompanionBuilder,
          $$EnviosTableUpdateCompanionBuilder,
          (EnvioRow, BaseReferences<_$Banco, $EnviosTable, EnvioRow>),
          EnvioRow,
          PrefetchHooks Function()
        > {
  $$EnviosTableTableManager(_$Banco db, $EnviosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnviosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnviosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnviosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> data = const Value.absent(),
            Value<String> enviadoEm = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => EnviosCompanion(data: data, enviadoEm: enviadoEm, rowid: rowid),
          createCompanionCallback:
              ({
                required String data,
                required String enviadoEm,
                Value<int> rowid = const Value.absent(),
              }) => EnviosCompanion.insert(
                data: data,
                enviadoEm: enviadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EnviosTable, EnvioRow>(table),
                  BaseReferences<_$Banco, $EnviosTable, EnvioRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnviosTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $EnviosTable,
      EnvioRow,
      $$EnviosTableFilterComposer,
      $$EnviosTableOrderingComposer,
      $$EnviosTableAnnotationComposer,
      $$EnviosTableCreateCompanionBuilder,
      $$EnviosTableUpdateCompanionBuilder,
      (EnvioRow, BaseReferences<_$Banco, $EnviosTable, EnvioRow>),
      EnvioRow,
      PrefetchHooks Function()
    >;
typedef $$ConfigsTableCreateCompanionBuilder = ConfigsCompanion Function({
  required String chave,
  required String valor,
  Value<int> rowid,
});
typedef $$ConfigsTableUpdateCompanionBuilder = ConfigsCompanion Function({
  Value<String> chave,
  Value<String> valor,
  Value<int> rowid,
});

class $$ConfigsTableFilterComposer extends Composer<_$Banco, $ConfigsTable> {
  $$ConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfigsTableOrderingComposer extends Composer<_$Banco, $ConfigsTable> {
  $$ConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfigsTableAnnotationComposer
    extends Composer<_$Banco, $ConfigsTable> {
  $$ConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$ConfigsTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $ConfigsTable,
          ConfigRow,
          $$ConfigsTableFilterComposer,
          $$ConfigsTableOrderingComposer,
          $$ConfigsTableAnnotationComposer,
          $$ConfigsTableCreateCompanionBuilder,
          $$ConfigsTableUpdateCompanionBuilder,
          (ConfigRow, BaseReferences<_$Banco, $ConfigsTable, ConfigRow>),
          ConfigRow,
          PrefetchHooks Function()
        > {
  $$ConfigsTableTableManager(_$Banco db, $ConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> chave = const Value.absent(),
            Value<String> valor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ConfigsCompanion(chave: chave, valor: valor, rowid: rowid),
          createCompanionCallback:
              ({
                required String chave,
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => ConfigsCompanion.insert(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfigsTable, ConfigRow>(table),
                  BaseReferences<_$Banco, $ConfigsTable, ConfigRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $ConfigsTable,
      ConfigRow,
      $$ConfigsTableFilterComposer,
      $$ConfigsTableOrderingComposer,
      $$ConfigsTableAnnotationComposer,
      $$ConfigsTableCreateCompanionBuilder,
      $$ConfigsTableUpdateCompanionBuilder,
      (ConfigRow, BaseReferences<_$Banco, $ConfigsTable, ConfigRow>),
      ConfigRow,
      PrefetchHooks Function()
    >;

class $BancoManager {
  final _$Banco _db;
  $BancoManager(this._db);
  $$LeitoresTableTableManager get leitores =>
      $$LeitoresTableTableManager(_db, _db.leitores);
  $$RegrasTableTableManager get regras =>
      $$RegrasTableTableManager(_db, _db.regras);
  $$CelebracoesTableTableManager get celebracoes =>
      $$CelebracoesTableTableManager(_db, _db.celebracoes);
  $$VagasTableTableManager get vagas =>
      $$VagasTableTableManager(_db, _db.vagas);
  $$MesesTableTableManager get meses =>
      $$MesesTableTableManager(_db, _db.meses);
  $$EnviosTableTableManager get envios =>
      $$EnviosTableTableManager(_db, _db.envios);
  $$ConfigsTableTableManager get configs =>
      $$ConfigsTableTableManager(_db, _db.configs);
}
