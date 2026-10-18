import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../screens/admin_orders_screen.dart';

class NotificationService {
  static final _local = FlutterLocalNotificationsPlugin();
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _initialized = false;

  static Future<void> init({required GlobalKey<NavigatorState> navKey}) async {
    _navigatorKey = navKey;

    // 🔥 كان ic_launcher وانت عندك launcher_icon
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: android);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final orderId = response.payload;
        if (orderId != null && orderId.isNotEmpty) _openOrder(orderId);
      },
    );

    const channel = AndroidNotificationChannel(
      'orders_channel',
      'Orders Notifications',
      description: 'New orders for admin',
      importance: Importance.max,
    );

    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;

    FirebaseMessaging.onMessage.listen((message) {
      final orderId = message.data['orderId'];
      if (message.notification != null) {
        showLocal(message.notification!.title ?? 'طلب جديد', 
                  message.notification!.body ?? '', 
                  payload: orderId);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final orderId = message.data['orderId'];
      if (orderId != null) _openOrder(orderId);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final orderId = initialMessage.data['orderId'];
      if (orderId != null) {
        Future.delayed(const Duration(milliseconds: 800), () => _openOrder(orderId));
      }
    }
  }

  static Future<void> subscribeAdmin() async {
    await FirebaseMessaging.instance.subscribeToTopic("admin_orders");
  }

  static Future<void> unsubscribeAdmin() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic("admin_orders");
  }

  static Future<void> showLocal(String title, String body, {String? payload}) async {
    if (!_initialized) return;
    const androidDetails = AndroidNotificationDetails(
      'orders_channel',
      'Orders Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon', // 🔥 نفس الاشي هون
    );
    await _local.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  static void _openOrder(String orderId) {
    _navigatorKey?.currentState?.push(
      MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
    );
  }
}