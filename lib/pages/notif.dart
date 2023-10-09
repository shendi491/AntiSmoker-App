import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await FirebaseMessaging.instance.getToken();
    var androidInitialize =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    var iosInitialize = const DarwinInitializationSettings();
    var initializeSettings =
        InitializationSettings(android: androidInitialize, iOS: iosInitialize);
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      await flutterLocalNotificationsPlugin.initialize(initializeSettings);
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              event.notification?.android?.channelId ?? Random().toString(),
              event.notification?.android?.channelId ?? Random().toString(),
              playSound: true,
              importance: Importance.max,
              priority: Priority.high);
      var notif = NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
          1, event.notification?.title, event.notification?.body, notif);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Tangani pesan yang diterima saat aplikasi dibuka dari notifikasi
      print('Pesan dibuka dari notifikasi: ${message.notification?.title}');
    });

    // Izinkan pengguna untuk mengontrol notifikasi
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Pengaturan notifikasi: $settings');
  }
}
