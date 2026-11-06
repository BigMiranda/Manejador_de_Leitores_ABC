import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/envios.dart';
import '../core/modelos.dart';
import '../data/repositorio.dart';

const _canal = AndroidNotificationDetails(
  'lembrete_vespera',
  'Lembrete da véspera',
  channelDescription: 'Aviso para enviar a escala no grupo de WhatsApp',
  importance: Importance.high,
  priority: Priority.high,
);

/// Notificações locais "Escala de amanhã pronta — tocar para enviar".
class Notificacoes {
  static final plugin = FlutterLocalNotificationsPlugin();
  static bool _pronto = false;

  static void iniciarFuso() {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
  }

  /// [aoTocar] recebe o dia (aaaa-mm-dd) da celebração.
  static Future<void> inicializar({void Function(String dia)? aoTocar}) async {
    iniciarFuso();
    await plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (r) {
        final dia = _diaDoPayload(r.payload);
        if (dia != null) aoTocar?.call(dia);
      },
    );
    _pronto = true;
  }

  static String? _diaDoPayload(String? payload) =>
      payload != null && payload.startsWith('envio:') ? payload.substring(6) : null;

  /// Dia da notificação que abriu o app, se houver.
  static Future<String?> diaQueAbriuOApp() async {
    final d = await plugin.getNotificationAppLaunchDetails();
    if (d?.didNotificationLaunchApp != true) return null;
    return _diaDoPayload(d!.notificationResponse?.payload);
  }

  static Future<void> pedirPermissao() async {
    try {
      await plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Permissão de notificação: $e');
    }
  }

  static int _id(DateTime dia) => dia.year * 10000 + dia.month * 100 + dia.day;

  /// Reagenda os lembretes dos próximos 60 dias que ainda não foram enviados.
  static Future<void> reagendar(Repositorio repo) async {
    if (!_pronto) await inicializar();
    final cfg = await repo.configuracao();
    final hoje = soDia(DateTime.now());
    final dias = diasDeEnvio(
      await repo.celebracoesEntre(hoje, hoje.add(const Duration(days: 60))),
      await repo.diasEnviados(),
    );
    await plugin.cancelAll();
    final partes = cfg.horaNotificacao.split(':');
    final agora = tz.TZDateTime.now(tz.local);
    for (final d in dias.where((d) => !d.enviado)) {
      final v = d.diaDoEnvio;
      final quando = tz.TZDateTime(tz.local, v.year, v.month, v.day, int.parse(partes[0]), int.parse(partes[1]));
      if (!quando.isAfter(agora)) continue;
      try {
        await plugin.zonedSchedule(
          id: _id(d.dia),
          scheduledDate: quando,
          notificationDetails: const NotificationDetails(android: _canal),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: 'Escala de amanhã pronta',
          body: 'Tocar para enviar a mensagem ${d.comPdf ? 'e o PDF da liturgia ' : ''}ao grupo.',
          payload: 'envio:${dataIso(d.dia)}',
        );
      } catch (e) {
        debugPrint('Falha ao agendar ${d.dia}: $e');
      }
    }
  }

  /// Mostra agora um aviso de envio pendente (usado pela tarefa diária).
  static Future<void> mostrarPendente(DiaDeEnvio d) async {
    if (!_pronto) await inicializar();
    await plugin.show(
      id: _id(d.dia),
      title: 'Envio pendente',
      body: 'A escala de ${d.dia.day.toString().padLeft(2, '0')}/${d.dia.month.toString().padLeft(2, '0')} ainda não foi enviada.',
      notificationDetails: const NotificationDetails(android: _canal),
      payload: 'envio:${dataIso(d.dia)}',
    );
  }
}
