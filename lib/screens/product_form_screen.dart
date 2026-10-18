import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../models/product.dart';
import '../models/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameC, nameArC, flavorC, priceC, descC;
  XFile? _selectedImage;
  Uint8List? _webBytes;
  String? _oldImagePath;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.product?.name ?? '');
    nameArC = TextEditingController(text: widget.product?.nameAr ?? '');
    flavorC = TextEditingController(text: widget.product?.flavor ?? '');
    priceC = TextEditingController(text: widget.product?.price.toString() ?? '');
    descC = TextEditingController(text: widget.product?.description ?? '');
    _oldImagePath = widget.product?.image;
  }

  @override
  void dispose() {
    nameC.dispose();
    nameArC.dispose();
    flavorC.dispose();
    priceC.dispose();
    descC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img == null) return;
    if (kIsWeb) _webBytes = await img.readAsBytes();
    setState(() => _selectedImage = img);
  }

  Future<String> _uploadToFirebase() async {
    if (_selectedImage == null) return _oldImagePath!;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(_selectedImage!.name)}';
    final ref = FirebaseStorage.instance.ref().child('products/$fileName');
    if (kIsWeb) {
      await ref.putData(_webBytes!);
    } else {
      await ref.putFile(File(_selectedImage!.path));
    }
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _oldImagePath == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('اختار صورة المنتج', style: GoogleFonts.cairo())));
      return;
    }
    final provider = context.read<ProductProvider>();
    setState(() => _isUploading = true);
    try {
      final imageUrl = _selectedImage != null ? await _uploadToFirebase() : _oldImagePath!;
      final newProduct = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameC.text.trim(),
        nameAr: nameArC.text.trim(),
        flavor: flavorC.text.trim(),
        price: double.tryParse(priceC.text) ?? 0,
        image: imageUrl,
        description: descC.text.trim(),
      );
      if (widget.product == null) {
        await provider.addProduct(newProduct);
      } else {
        await provider.updateProduct(newProduct);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'إضافة منتج' : 'تعديل منتج', style: GoogleFonts.cairo())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.brown), borderRadius: BorderRadius.circular(12)),
                  child: _selectedImage != null
                      ? kIsWeb
                          ? Image.memory(_webBytes!, fit: BoxFit.cover)
                          : Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
                      : _oldImagePath != null
                          ? Image.network(_oldImagePath!, fit: BoxFit.cover)
                          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_a_photo, size: 40), Text('اضغط لاختيار صورة', style: GoogleFonts.cairo())]),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(controller: nameArC, decoration: const InputDecoration(labelText: 'الاسم عربي'), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              TextFormField(controller: nameC, decoration: const InputDecoration(labelText: 'الاسم انجليزي'), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              TextFormField(controller: flavorC, decoration: const InputDecoration(labelText: 'النكهة')),
              TextFormField(controller: priceC, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              TextFormField(controller: descC, decoration: const InputDecoration(labelText: 'الوصف'), maxLines: 3),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723)),
                  child: _isUploading ? const CircularProgressIndicator(color: Colors.white) : Text('حفظ', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}