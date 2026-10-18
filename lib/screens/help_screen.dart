import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: '0796267185');
    await launchUrl(uri);
  }

  Future<void> _contactUs() async {
    const phone = '962796267185';
    final url = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent('مرحبا Mr. Melt بدي مساعدة 🙏')}');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('المساعدة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF3E2723),
          foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _faq('كيف أطلب؟',
            'اختار النكهة، اضغط + ، روح على السلة، عبي بياناتك واكبس إرسال الطلب. الطلب رح يوصلنا مباشرة.'),
        _faq('كم سعر التوصيل؟', 'حسب المنطقة '),
        _faq('كم بياخد وقت التوصيل؟', 'من ساعة لساعتين داخل عمان.'),
        _faq('كيف الدفع؟', 'كاش عند الاستلام حاليا.'),
        _faq('هل الحلى طازة؟', 'أكيد! كل الأكواب بتنعمل يوم بيوم.'),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: _call,
                icon: const Icon(Icons.call, color: Colors.white),
                label: Text('اتصال مباشر - 0796267185',
                    style: GoogleFonts.cairo(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E2723),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))))),
        const SizedBox(height: 12),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: _contactUs,
                icon: const Icon(Icons.chat, color: Colors.white),
                label: Text('تواصل واتساب',
                    style: GoogleFonts.cairo(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }

  Widget _faq(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        title: Text(q,
            style:
                GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(a,
                  style: GoogleFonts.cairo(
                      fontSize: 13, height: 1.6, color: Colors.grey[700])))
        ],
      ),
    );
  }
}