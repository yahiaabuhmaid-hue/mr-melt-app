import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(product.name, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              product.image,
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset('assets/images/logo.png', height: 280, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 20),
          Text(product.name, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${product.price} د.أ', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF3E2723))),
          const SizedBox(height: 16),
          // تم إصلاح السطر 37 هنا - بدون ??
          Text(
            product.description.isEmpty ? 'حلى فاخر من Mr. Melt مصنوع بحب' : product.description,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () {
                context.read<CartModel>().addItem(product);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت إضافة ${product.name} للسلة', style: GoogleFonts.cairo()), backgroundColor: Colors.green));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.shopping_bag, color: Colors.white),
              label: Text('أضف للسلة', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}