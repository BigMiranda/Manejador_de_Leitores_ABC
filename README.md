# Manejador de Leitores ABC

App Android para o responsável pela **Pastoral da Leitura**:

- cadastro dos leitores e das restrições de cada um (horários, quinta, festas, pastoral, épocas, par "ler junto");
- **escala mensal automática e justa** (rodízio por tempo desde a última leitura), editável à mão com travas;
- **exportação PNG e PDF** no layout que a paróquia já usa, para mandar no grupo;
- **lembrete na véspera** de cada missa, com a mensagem pronta e o **PDF da liturgia** do
  [ABC Litúrgico](https://diocesesa.org.br/abc-liturgico/) (Diocese de Santo André) nos domingos e festas;
- backup semanal automático, exportação para o Google Drive e desfazer/refazer.

Os dados ficam **só no celular** (sem servidor e sem login). A internet só é usada para baixar a liturgia.

## Instalar o app

1. Abra a página [Releases](https://github.com/BigMiranda/Manejador_de_Leitores_ABC/releases) no celular e
   baixe o arquivo `leitores-abc-X.Y.Z.apk` da versão mais recente.
2. Toque no arquivo. O Android vai pedir para **permitir instalar apps desta fonte** (navegador ou
   gerenciador de arquivos): permita e volte.
3. Na primeira abertura, **permita as notificações** (são elas que avisam na véspera).
4. Para atualizar, instale o APK novo por cima. **Não desinstale**: desinstalar apaga todos os dados.

Requer Android 7.0 ou mais novo.

## Primeiros passos

1. **Leitores → Importar lista**: cole os nomes, um por linha (marcadores como `1.`, `-` e `•` são
   removidos). Aparece uma prévia com novos e repetidos antes de confirmar.
2. Abra cada leitor que tem restrição e ajuste: animação, horários de domingo, quinta, festas, "só lê pela
   pastoral", épocas (impedimento, preferência ou "prefere não") e com quem prefere ler junto.
3. **Carga inicial do rodízio** (escolha uma):
   - preencha a **Última participação** na ficha de cada leitor; ou
   - vá em **Escala**, volte aos meses anteriores e lance as escalas passadas à mão (toque em cada célula).
4. **Ajustes**: confira os horários das missas, os domingos das pastorais, o intervalo mínimo e o horário
   da notificação (padrão 14:00).

## Uso do mês

- **Escala → Gerar**: preenche as células vazias e destravadas. Toda edição manual trava a célula
  (cadeado). Segure uma célula para travar ou destravar. **Sortear alternativa** gera outra distribuição
  válida.
- Os avisos (vaga sem candidato, par não atendido, intervalo abaixo do mínimo) aparecem no chip de avisos.
- **Pastorais do mês** muda o domingo ou o horário de cada pastoral só naquele mês.
- Festas encontradas no ABC Litúrgico fora do domingo aparecem como sugestão no topo do mês.
  Novenas, Corpus Christi e outras ficam em **Adicionar celebração** (atribuição *Comunidade* = linha em
  vermelho mesclada na exportação).
- **Publicar mês** marca o mês como oficial. A geração considera o histórico de todos os meses anteriores
  (publicados e rascunhos).
- **Exportar PNG / PDF** abre o compartilhamento (WhatsApp, Drive…).
- **Estatísticas** mostra vagas, elegíveis, intervalo médio entre leituras, contagem por leitor e uma
  simulação dos próximos 12 meses.

## Véspera de cada missa

Às 14:00 do dia anterior chega a notificação **"Escala de amanhã pronta — tocar para enviar"**:

1. **1. Enviar mensagem**: abre o compartilhamento com o texto (também copiado). Escolha o grupo no WhatsApp.
2. **2. Enviar PDF da liturgia** (domingo e festa): compartilha o PDF já baixado.
3. **Marcar como enviado**.

A tela Início lista os envios pendentes e atrasados. Os textos são editáveis em **Ajustes → Textos das
mensagens**. O app nunca envia nada sozinho no WhatsApp.

## Backup

- Toda semana o app guarda um backup interno. Os semanais ficam 3 meses; o último de cada mês fica para
  sempre.
- **Ajustes → Exportar backup** compartilha o arquivo `.json`: salve no Google Drive. A tela Início avisa
  quando faz mais de 30 dias sem exportar.
- **Restaurar** (de um arquivo ou de um backup interno) mostra uma prévia e, antes de substituir, guarda um
  backup do estado atual.

---

## Para quem mantém o projeto

### Assinatura do APK (fazer uma única vez)

O GitHub Actions assina o APK com um keystore guardado nos *secrets* do repositório. **Gere o keystore uma
vez e guarde-o (e as senhas) num lugar seguro.** Se a assinatura mudar, o Android não deixa atualizar o app
instalado: seria preciso desinstalar, e **desinstalar apaga os dados** (restaure depois pelo backup).

1. Gere o keystore (o `keytool` vem com o JDK do Android Studio):

   ```bash
   "/c/Program Files/Android/Android Studio/jbr/bin/keytool" -genkeypair -v -keystore leitores-abc.jks -alias leitores -keyalg RSA -keysize 2048 -validity 10000
   ```

2. Converta para base64:

   ```bash
   base64 -w 0 leitores-abc.jks > leitores-abc.jks.b64
   ```

3. Cadastre os quatro secrets (pelo site em *Settings → Secrets and variables → Actions*, ou com o `gh`):

   ```bash
   gh secret set ANDROID_KEYSTORE_BASE64 < leitores-abc.jks.b64
   ```

   ```bash
   gh secret set ANDROID_KEYSTORE_PASSWORD
   ```

   ```bash
   gh secret set ANDROID_KEY_ALIAS --body leitores
   ```

   ```bash
   gh secret set ANDROID_KEY_PASSWORD
   ```

4. Apague o `.b64` e **não** coloque o `.jks` no repositório (o `.gitignore` já ignora `*.jks` e
   `key.properties`).

Para assinar um build local, crie `android/key.properties`:

```properties
storeFile=C:/caminho/leitores-abc.jks
storePassword=...
keyAlias=leitores
keyPassword=...
```

### Publicar uma versão

```bash
git tag v1.0.1
```

```bash
git push origin v1.0.1
```

O workflow **Build APK** roda `flutter analyze`, os testes, gera o APK assinado, anexa como artifact e
cria o GitHub Release. Também dá para rodar à mão em *Actions → Build APK → Run workflow* (sem os
secrets, o APK sai com a chave de debug, só para teste).

### Desenvolvimento

Flutter stable (3.47) e JDK 17.

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter test
```

Detalhes de arquitetura e regras de negócio em [CLAUDE.md](CLAUDE.md).

### Diferenças em relação à especificação da v1

- `minSdk` 24 (Android 7.0) em vez de 23: o Flutter atual e o plugin de notificações não suportam 23.
- O PDF exportado contém a tabela como imagem em alta resolução (a mesma do PNG), para os dois saírem
  idênticos.

A fonte Roboto embutida (`assets/fonts`) é distribuída sob a licença Apache 2.0.
