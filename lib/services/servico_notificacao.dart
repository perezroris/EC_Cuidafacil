import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ServicoNotificacao {
  static final plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);
    await plugin.initialize(settings: settings);

    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> mostrar(String titulo, String corpo) async {
    const detalhes = NotificationDetails(
      android: AndroidNotificationDetails(
        'cuidafacil_channel',
        'CuidaFacil',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await plugin.show(
      id: 0,
      title: titulo,
      body: corpo,
      notificationDetails: detalhes,
    );
  }
}
