import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/product_provider.dart';
import '../services/notification_service.dart';
import 'product_form_screen.dart';
import 'admin_orders_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.subscribeAdmin();

    FirebaseFirestore.instance.collection('orders').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;
          NotificationService.showLocal(
            'طلب جديد من ${data['customerName'] ?? ''}',
            'المجموع: ${data['total'] ?? 0} JD - ${data['phone'] ?? ''}',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3E2723),
          title: Text('لوحة تحكم Mr. Melt', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.cairo(),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.cake), text: 'المنتجات'),
              Tab(icon: Icon(Icons.receipt_long), text: 'الطلبات'),
            ],
          ),
          actions: [
  IconButton(
    icon: Icon(Icons.notifications_active, color: Colors.white),
    onPressed: () async {
      await NotificationService.showLocal('تجربة', 'اذا شفت هاد يعني الاشعارات شغالة');
    },
  )
],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF3E2723),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          ),
        ),
        body: TabBarView(
          children: [
            products.isEmpty
                ? Center(child: Text('لا يوجد منتجات', style: GoogleFonts.cairo(fontSize: 16)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final p = products[i];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p.image, width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.cake),
                            ),
                          ),
                          title: Text(p.nameAr, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          subtitle: Text('${p.name} - ${p.price.toStringAsFixed(2)} JD', style: GoogleFonts.cairo(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(product: p))),
                              ),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(context, p)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const AdminOrdersScreen(),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('حذف المنتج؟', style: GoogleFonts.cairo()),
        content: Text('هل انت متأكد من حذف ${p.nameAr}؟', style: GoogleFonts.cairo()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء', style: GoogleFonts.cairo())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ProductProvider>().removeProduct(p.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حذف ${p.nameAr}', style: GoogleFonts.cairo())));
            },
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}