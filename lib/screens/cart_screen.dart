import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';
import '../models/order.dart';
import '../models/order_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _showOrderDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('معلومات الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty? 'الاسم مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.trim().length < 7? 'رقم الهاتف مطلوب' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text('إلغاء', style: GoogleFonts.cairo())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723)),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final customerName = nameController.text.trim();
                final customerPhone = phoneController.text.trim();
                final orderProvider = context.read<OrderProvider>();
                final cart = context.read<CartModel>();
                final double total = cart.items.fold<double>(0, (prev, item) => prev + (item.product.price * item.quantity));
                final orderItems = cart.items.map((ci) {
                  return OrderItem(
                    productId: ci.product.id,
                    name: ci.product.nameAr,
                    price: ci.product.price,
                    quantity: ci.quantity,
                  );
                }).toList();
                final order = CustomerOrder(
                  id: '',
                  customerName: customerName,
                  phone: customerPhone,
                  items: orderItems,
                  total: total,
                  address: '',
                  status: 'pending',
                  timestamp: Timestamp.now(),
                );
                await orderProvider.addOrder(order);
                cart.clear();
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.green, content: Text('تم إرسال طلبك بنجاح', style: GoogleFonts.cairo(color: Colors.white))),
                );
              },
              child: Text('تأكيد الطلب', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final double total = cart.items.fold<double>(0, (prev, item) => prev + (item.product.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: Text('السلة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF3E2723),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cart.items.isEmpty
         ? Center(child: Text('السلة فارغة', style: GoogleFonts.cairo(fontSize: 18)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Image.network(item.product.image, width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset('assets/images/logo.png', width: 50)),
                          title: Text(item.product.nameAr, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.product.price} JD x ${item.quantity}', style: GoogleFonts.cairo()),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => context.read<CartModel>().removeOne(item.product),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المجموع:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('$total JD', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3E2723))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3E2723), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: _showOrderDialog,
                          child: Text('اتمام الطلب', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}