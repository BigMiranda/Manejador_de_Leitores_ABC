# Manejador de Leitores ABC — guia para o Claude Code

App Android (Flutter) para o responsável pela Pastoral da Leitura: cadastro de leitores, escala mensal
automática e justa, exportação PNG/PDF no layout da paróquia e lembrete da véspera para o WhatsApp com o
PDF do ABC Litúrgico (Diocese de Santo André). Uso pessoal, um único usuário, dados só no celular.
Interface 100% em português do Brasil.

## Comandos

O Flutter está em `C:\src\flutter\bin` (canal stable, 3.47.x). O JDK usado é o do Android Studio (17).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # depois de mudar lib/data/banco.dart
flutter analyze                                            # tem que sair sem avisos
flutter test                                               # unitários + golden + fumaça
flutter test --update-goldens test/ui                      # só se a mudança no layout for intencional;
                                                           # atualiza goldens/windows. Para o Linux (CI),
                                                           # rode o workflow "Atualizar goldens" e commite
                                                           # o artifact em test/ui/goldens/linux/
flutter build apk --release                                # sem key.properties assina com a chave de debug
```

Release: `git tag vX.Y.Z && git push origin vX.Y.Z` → o workflow `.github/workflows/build-apk.yml` roda
analyze + testes, gera o APK assinado pelos secrets e cria o GitHub Release.

## Arquitetura

```
lib/
  core/        Dart puro, sem Flutter/banco. Toda regra de negócio testável fica aqui.
    modelos.dart        Leitor, RegraEpoca, Celebracao, Vaga, enums; datas "só dia" = DateTime.utc
    regras_epoca.dart   avaliar(leitor, celebracao) -> bloqueado | bonus | penalidade | neutro
    escala.dart         gerarEscala(...) determinística por seed + motivosInelegivel + Historico
    configuracao.dart   Configuracao (modelos de missa, pastorais, intervalo, textos) + calendário do mês
    mensagens.dart      montarMensagem (véspera), saudação, placeholders
    envios.dart         dias que pedem mensagem (sempre enviada 1 dia antes)
    abc_parser.dart     parser da listagem do ABC Litúrgico
    utilitarios.dart    importação colando, retenção de backup, estatísticas, simulação anual
  data/        drift (SQLite). banco.dart (+ banco.g.dart gerado e commitado), repositorio.dart
  services/    rede, arquivos e plataforma: abc_servico, backup_servico, exportacao, notificacoes, tarefas
  state/       providers Riverpod 3. `revisaoProvider` muda a cada gravação e invalida as leituras.
  ui/          telas (inicio, leitores, leitor_form, escala, celebracao_form, estatisticas, enviar, config)
test/          core/, data/ (banco em memória), ui/ (golden da exportação + fumaça); fixtures/abc_liturgico.html
```

- **Desfazer/refazer**: `Repositorio._registrar` tira um instantâneo JSON das tabelas de leitores e escala
  antes e depois de cada alteração (pilha de 50). Configurações e envios ficam fora do desfazer.
- **Backup**: o mesmo instantâneo, com todas as tabelas, versionado (`versaoBackup`). Ao mudar o
  esquema, suba `schemaVersion` com migração E trate backups antigos em `restaurarBackup`.
- **Exportação**: `TabelaExportacao` (widget com altura de linha fixa) → PNG via `screenshot` em 2× (1600 px)
  → PDF A4 com a imagem. A fonte Roboto vai embutida em `assets/fonts` para o golden ser estável.
- **Segundo plano**: WorkManager a cada 12 h (`services/tarefas.dart`): backup semanal + retenção, PDFs da
  semana, reagendar notificações, avisar envio atrasado. A mesma rotina roda ao abrir o app.

## Regras de negócio (resumo)

- Elegibilidade (forte): vai ler, não é "só pastoral", sem impedimento de época, domingo/horário aceito,
  quinta Sim/Às vezes, festa aceita, uma função por dia, animador só quem faz animação.
- Pontuação (fraca): dias desde a última participação (histórico de todos os meses + carga manual);
  desempate por menos participações em 12 meses; ±30 por preferência/"prefere não"; −21 quinta "às vezes";
  animador "prefere" +14 (e −7 em leitura); intervalo mínimo (padrão 4 semanas) −1000; jitter 0–3 da seed.
- Animador "Sim, mas prefere ler" só entra se não houver quem "prefere". Par "ler junto" é bidirecional e
  o algoritmo tenta pôr o par em outra função da mesma celebração (senão gera aviso).
- Geração só preenche células destravadas e vazias (opção de refazer as destravadas); toda edição manual
  trava a célula; comunidade nunca é tocada; pastoral só recebe proposta dos leitores daquela pastoral.
- Histórico do rodízio: tudo antes do 1º dia do mês (publicados e rascunhos anteriores).
- Pastorais padrão: Terço das Mulheres = 1º domingo 18:00; Terço dos Homens = 2º domingo 18:00;
  sobrescrevíveis por mês (`Meses.pastorais`).
- ABC: associar PDF SEMPRE pela data (o site repete rótulos). No máximo uma busca da página por execução,
  User-Agent identificável. Plano B: API de mídia do WordPress para escolha manual; ou colar a URL.
- Mensagem: sempre na véspera; domingo/festa levam o PDF; quinta não. Funções vazias = "(a definir)".
- WhatsApp: só share intent (semiautomático). Nunca automatizar o envio.

## Observações

- `minSdk` é 24 (Android 7): o Flutter atual e o `flutter_local_notifications` 22 não aceitam 23.
- Não troque a chave de assinatura do release: o app instalado não atualiza e desinstalar apaga os dados.
