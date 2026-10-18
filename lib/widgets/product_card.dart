import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final qty = cart.quantity(product.id);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(
                  color: Colors.brown.shade50,
                  child: Center(child: Image.asset('assets/images/logo.png', width: 40, height: 40)),
                ),
                errorWidget: (c, u, e) => Container(
                  color: Colors.brown.shade50,
                  child: Center(child: Image.asset('assets/images/logo.png', width: 40, height: 40)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.nameAr, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(product.name, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(child: Text('${product.price} JD', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis)),
                        if (qty == 0)
                          InkWell(
                            onTap: () => context.read<CartModel>().add(product),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add, color: Colors.white, size: 16),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => context.read<CartModel>().removeOne(product),
                                  child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.remove, color: Colors.white, size: 16)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text('$qty', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                InkWell(
                                  onTap: () => context.read<CartModel>().add(product),
                                  child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add, color: Colors.white, size: 16)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}