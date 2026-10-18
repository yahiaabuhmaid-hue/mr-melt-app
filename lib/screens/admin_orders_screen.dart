import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order.dart';
import '../models/order_provider.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Color _cardColor(String status) {
    if (status == 'accepted') return Colors.green.withValues(alpha: 0.08);
    if (status == 'rejected') return Colors.red.withValues(alpha: 0.08);
    return Colors.white;
  }

  Icon _statusIcon(String status) {
    if (status == 'accepted') return const Icon(Icons.check_circle, color: Colors.green, size: 28);
    if (status == 'rejected') return const Icon(Icons.cancel, color: Colors.red, size: 28);
    return const Icon(Icons.hourglass_empty, color: Colors.orange, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الطلبات الواردة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF3E2723),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<CustomerOrder>>(
        stream: context.read<OrderProvider>().ordersStream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return Center(child: Text('لا يوجد طلبات بعد', style: GoogleFonts.cairo(fontSize: 18)));
          }
          final orders = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final o = orders[i];
              return Card(
                color: _cardColor(o.status),
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: o.status == 'accepted'? Colors.green : o.status == 'rejected'? Colors.red : Colors.grey.shade300,
                    width: o.status == 'pending'? 0.5 : 1.2,
                  ),
                ),
                child: ListTile(
                  leading: _statusIcon(o.status),
                  title: Text(o.customerName, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${o.phone}\n${o.items.length} منتجات - ${o.total} د.أ\n${o.status == 'accepted'? '✅ مقبول' : o.status == 'rejected'? '❌ مرفوض' : '⏳ جديد'}',
                    style: GoogleFonts.cairo(fontSize: 12),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) async {
                      final orderProvider = context.read<OrderProvider>();
                      if (val == 'accept') {
                        await orderProvider.updateStatus(o.id, 'accepted');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: Colors.green, content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Text('تم قبول طلب ${o.customerName}', style: GoogleFonts.cairo(color: Colors.white))])),
                        );
                      } else if (val == 'reject') {
                        await orderProvider.updateStatus(o.id, 'rejected');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: Colors.red, content: Row(children: [const Icon(Icons.close, color: Colors.white), const SizedBox(width: 8), Text('تم رفض طلب ${o.customerName}', style: GoogleFonts.cairo(color: Colors.white))])),
                        );
                      } else if (val == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('حذف الطلب؟', style: GoogleFonts.cairo()),
                            content: Text('هل أنت متأكد من حذف طلب ${o.customerName} نهائياً؟', style: GoogleFonts.cairo()),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء', style: GoogleFonts.cairo())),
                              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await orderProvider.deleteOrder(o.id);
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'accept', child: Row(children: [const Icon(Icons.check, color: Colors.green), const SizedBox(width: 8), Text('قبول', style: GoogleFonts.cairo())])),
                      PopupMenuItem(value: 'reject', child: Row(children: [const Icon(Icons.close, color: Colors.red), const SizedBox(width: 8), Text('رفض', style: GoogleFonts.cairo())])),
                      const PopupMenuDivider(),
                      PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, color: Colors.grey), const SizedBox(width: 8), Text('حذف الطلب', style: GoogleFonts.cairo())])),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (sheetCtx) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                              const SizedBox(height: 16),
                              Row(children: [_statusIcon(o.status), const SizedBox(width: 10), Text('تفاصيل الطلب', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold))]),
                              const Divider(),
                              Text('الاسم: ${o.customerName}', style: GoogleFonts.cairo()),
                              Text('الهاتف: ${o.phone}', style: GoogleFonts.cairo()),
                              Text('العنوان: ${o.address}', style: GoogleFonts.cairo()),
                              Text('المجموع: ${o.total} د.أ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text('المنتجات:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                             ...o.items.map((e) => Text('- ${e.name} x${e.quantity}', style: GoogleFonts.cairo())),
                              const SizedBox(height: 24),
                              Row(children: [
                                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.check, color: Colors.white), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(12)), onPressed: () async { final p = sheetCtx.read<OrderProvider>(); await p.updateStatus(o.id, 'accepted'); if (sheetCtx.mounted) Navigator.pop(sheetCtx); }, label: Text('قبول', style: GoogleFonts.cairo(color: Colors.white)))),
                                const SizedBox(width: 10),
                                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.close, color: Colors.white), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(12)), onPressed: () async { final p = sheetCtx.read<OrderProvider>(); await p.updateStatus(o.id, 'rejected'); if (sheetCtx.mounted) Navigator.pop(sheetCtx); }, label: Text('رفض', style: GoogleFonts.cairo(color: Colors.white)))),
                              ]),
                              const SizedBox(height: 10),
                              SizedBox(width: double.infinity, child: OutlinedButton.icon(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final p = sheetCtx.read<OrderProvider>(); if (sheetCtx.mounted) Navigator.pop(sheetCtx); await p.deleteOrder(o.id); }, label: Text('حذف الطلب نهائياً', style: GoogleFonts.cairo(color: Colors.red)))),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}