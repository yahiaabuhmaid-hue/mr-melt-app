import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'models/cart_model.dart';
import 'models/product_provider.dart';
import 'models/order_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.init(navKey: navigatorKey); // 🔥 لازم تمرر navKey

  await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MrMeltApp(),
    ),
  );
}

class MrMeltApp extends StatelessWidget {
  const MrMeltApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 🔥 مهم عشان يفتح الطلب من الاشعار
      debugShowCheckedModeBanner: false,
      title: 'Mr. Melt',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFCF8F3),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E2723)),
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}