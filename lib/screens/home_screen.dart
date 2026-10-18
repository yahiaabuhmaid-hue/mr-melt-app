import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/cart_model.dart';
import '../models/product_provider.dart';
import '../models/order_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'admin_screen.dart';
import 'admin_orders_screen.dart';
import 'about_screen.dart';
import 'help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAdmin = false;
  int _tapCount = 0;
  DateTime? _lastTap;
  static const String _adminPassword = '202010609';

  void _handleSecretTap() {
    final now = DateTime.now();
    if (_lastTap == null || now.difference(_lastTap!).inSeconds > 2) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTap = now;
    if (_tapCount >= 5) {
      _tapCount = 0;
      _showAdminLogin();
    }
  }

  void _showAdminLogin() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('دخول الأدمن', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, obscureText: true, autofocus: true, decoration: const InputDecoration(labelText: 'كلمة السر', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء', style: GoogleFonts.cairo())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723)),
            onPressed: () async {
              if (controller.text == _adminPassword) {
                Navigator.pop(context);
                // 🔥 هون الاشتراك - بس للادمن
                await FirebaseMessaging.instance.subscribeToTopic("admin_orders");
                setState(() => _isAdmin = true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('أهلا أدمن! تم تفعيل اشعارات الطلبات', style: GoogleFonts.cairo())));
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة السر خطأ')));
                }
              }
            },
            child: Text('دخول', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    return Scaffold(
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF3E2723)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              Text('Mr. Melt', style: GoogleFonts.pacifico(color: Colors.white, fontSize: 24)),
              Text('جميع اصناف الحلى فاخرة', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          ListTile(leading: const Icon(Icons.home), title: Text('الرئيسية', style: GoogleFonts.cairo()), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.info_outline), title: Text('من نحن', style: GoogleFonts.cairo()), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())); }),
          ListTile(leading: const Icon(Icons.help_outline), title: Text('المساعدة', style: GoogleFonts.cairo()), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())); }),
          const Divider(),
          if (_isAdmin)
            ListTile(
              leading: Consumer<OrderProvider>(builder: (_, op, __) => Badge(label: Text('${op.newCount}'), isLabelVisible: op.newCount > 0, child: const Icon(Icons.receipt_long, color: Colors.green))),
              title: Text('الطلبات الواردة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen())); },
            ),
          if (_isAdmin)
            ListTile(leading: const Icon(Icons.admin_panel_settings, color: Colors.amber), title: Text('إدارة المنتجات', style: GoogleFonts.cairo()), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())); }),
          if (_isAdmin)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text('تسجيل خروج ادمن', style: GoogleFonts.cairo()),
              onTap: () async {
                await FirebaseMessaging.instance.unsubscribeFromTopic("admin_orders");
                setState(() => _isAdmin = false);
                if (mounted) Navigator.pop(context);
              },
            ),
          const Divider(),
          ListTile(leading: const Icon(Icons.facebook, color: Color(0xFF1877F2)), title: Text('فيسبوك', style: GoogleFonts.cairo()), onTap: () async { await launchUrl(Uri.parse('https://www.facebook.com/share/1Eow5Bodbn/?mibextid=LQQJ4d'), mode: LaunchMode.externalApplication); }),
          // شعار انستا الحقيقي
          ListTile(leading: const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE1306C)), title: Text('انستغرام', style: GoogleFonts.cairo()), onTap: () async { await launchUrl(Uri.parse('https://www.instagram.com/m.r.melt'), mode: LaunchMode.externalApplication); }),
          ListTile(leading: const Icon(Icons.phone, color: Color(0xFF3E2723)), title: Text('اتصال مباشر', style: GoogleFonts.cairo()), onTap: () async { await launchUrl(Uri(scheme: 'tel', path: '0796267185')); }),
        ]),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        iconTheme: const IconThemeData(color: Colors.white),
        title: GestureDetector(onTap: _handleSecretTap, child: Text('Mr. Melt', style: GoogleFonts.pacifico(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22))),
        actions: [
          Consumer<CartModel>(
            builder: (_, cart, __) => Badge(
              label: Text('${cart.count}'),
              isLabelVisible: cart.count > 0,
              child: IconButton(icon: const Icon(Icons.shopping_bag, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(
          child: GestureDetector(
            onTap: _handleSecretTap,
            child: Image.asset('assets/images/logo.png', height: 120, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.cake, size: 80, color: Color(0xFF3E2723))),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: BorderRadius.circular(24)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('بلش يومك بشي بتحبه', style: GoogleFonts.cairo(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(' جميع اصناف الحلى فاخرة ', style: GoogleFonts.cairo(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        Text('الاصناف الأكثر طلبا (${products.length})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: products.length,
          itemBuilder: (context, i) => ProductCard(product: products[i]),
        ),
      ]),
    );
  }
}