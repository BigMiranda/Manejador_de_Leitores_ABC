import 'package:flutter_test/flutter_test.dart';
import 'package:manejador_leitores/core/configuracao.dart';
import 'package:manejador_leitores/core/modelos.dart';
import 'package:manejador_leitores/core/utilitarios.dart';

void main() {
  group('importação colando', () {
    test('limpa marcadores, espaços e linhas vazias', () {
      expect(limparLinhaImportacao('1. Maria  José '), 'Maria José');
      expect(limparLinhaImportacao('12) João'), 'João');
      expect(limparLinhaImportacao('- Ana'), 'Ana');
      expect(limparLinhaImportacao('• Beto'), 'Beto');
      expect(limparLinhaImportacao('   '), '');
    });

    test('detecta duplicados na lista e contra os cadastrados', () {
      final p = analisarImportacao(
        '1. Débora\n2. debora\n\n- Luiz do Vale\n• Rosa\n  rosa \nTita',
        ['Luiz do Vale', 'Maria'],
      );
      expect(p.novos, ['Débora', 'Rosa', 'Tita']);
      expect(p.jaExistem, ['Luiz do Vale']);
      expect(p.repetidosNaLista, ['debora', 'rosa']);
      expect(p.resumo, '3 novos, 1 já existe, 2 repetidos na lista');
    });
  });

  group('retenção de backups', () {
    test('mantém o último de cada mês e apaga semanais com mais de 3 meses', () {
      final agora = DateTime(2026, 11, 6);
      final backups = [
        InfoBackup('jun-1', DateTime(2026, 6, 7)),
        InfoBackup('jun-2', DateTime(2026, 6, 28)),
        InfoBackup('jul-1', DateTime(2026, 7, 5)),
        InfoBackup('jul-2', DateTime(2026, 7, 26)),
        InfoBackup('ago-1', DateTime(2026, 8, 2)),
        InfoBackup('ago-2', DateTime(2026, 8, 9)),
        InfoBackup('ago-3', DateTime(2026, 8, 30)),
        InfoBackup('out-1', DateTime(2026, 10, 4)),
        InfoBackup('nov-1', DateTime(2026, 11, 1)),
      ];
      final plano = planejarRetencao(backups, agora);
      expect(plano.mensais, {'jun-2', 'jul-2', 'ago-3', 'out-1', 'nov-1'});
      expect(plano.apagar, {'jun-1', 'jul-1', 'ago-1'});
    });

    test('mensais antigos nunca são apagados', () {
      final plano = planejarRetencao([InfoBackup('2020', DateTime(2020, 1, 31))], DateTime(2026, 11, 6));
      expect(plano.apagar, isEmpty);
    });
  });

  group('calendário do mês', () {
    test('junho/2026: domingos, quintas, festas e pastorais padrão', () {
      final cels = gerarCelebracoesDoMes(2026, 6, const Configuracao());
      expect(cels.where((c) => c.tipo == TipoCelebracao.domingo), hasLength(4 * 3));
      // Corpus Christi (quinta 04/06) substitui a missa de quinta.
      expect(cels.where((c) => c.tipo == TipoCelebracao.quinta).map((c) => c.data.day), [11, 18, 25]);
      expect(cels.where((c) => c.tipo == TipoCelebracao.festa).map((c) => (c.data.day, c.hora, c.nomeLiturgico)), [
        (4, '19:00', 'Corpus Christi'),
        (12, '19:30', 'Sagrado Coração de Jesus'),
        (24, '19:30', 'Natividade de São João Batista'),
      ]);
      final pastorais = cels.where((c) => c.atribuicao == Atribuicao.pastoral).toList();
      expect(pastorais.map((c) => (c.data.day, c.hora, c.atribuicaoTexto)), [
        (7, '18:00', pastoralTercoMulheres),
        (14, '18:00', pastoralTercoHomens),
      ]);
      expect(cels.firstWhere((c) => c.tipo == TipoCelebracao.quinta).funcoes, isNot(contains(Funcao.leitura2)));
    });

    test('configuração serializa e volta igual', () {
      final c = const Configuracao().copyWith(intervaloMinimoSemanas: 6, horaNotificacao: '15:30');
      expect(Configuracao.fromJson(c.toJson()).toJson(), c.toJson());
    });
  });

  group('estatísticas', () {
    test('intervalo médio = elegíveis / vagas', () {
      final cels = gerarCelebracoesDoMes(2026, 6, const Configuracao());
      final leitores = [for (var i = 0; i < 100; i++) Leitor(id: i, nome: 'L$i')];
      final e = calcularEstatisticas(
        leitores: leitores,
        celebracoesDoMes: cels,
        historico: const {},
        referencia: DateTime(2026, 6, 1),
      );
      // 4 domingos x 3 missas x 4 funções - 2 missas de pastoral + 3 quintas x 3 + 3 festas x 4.
      expect(e.vagas, 40 + 9 + 12);
      expect(e.intervaloMedioMeses, closeTo(100 / 61, 0.001));
    });
  });
}
