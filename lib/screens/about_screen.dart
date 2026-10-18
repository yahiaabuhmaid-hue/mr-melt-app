
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  static const _phone = '0796267185';
  static const _fbUrl = 'https://www.facebook.com/share/1Eow5Bodbn/?mibextid=LQQJ4d';
  static const _instaUrl = 'https://www.instagram.com/m.r.melt?stkn=MTl3cWsweW1kendtYg==';

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: _phone);
    await launchUrl(uri);
  }
  Future<void> _launch(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('من نحن', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF3E2723), foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Icon(Icons.cake, size: 80, color: Color(0xFF3E2723)),
        const SizedBox(height: 12),
        Center(child: Text('Mr. Melt', style: GoogleFonts.pacifico(fontSize: 28, color: const Color(0xFF3E2723)))),
        const SizedBox(height: 20),
        Text('قصة حب   \u{1F36B}', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Text('بلشنا Mr. Melt من مطبخ صغير بحب كبير للحلى. هدفنا نعمل أكواب حلى فاخرة، طعمها بدوب، بجودة عالية.', style: GoogleFonts.cairo(fontSize: 14, height: 1.8)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _call,
            icon: const Icon(Icons.phone, color: Colors.white),
            label: Text('اتصال مباشر - $_phone', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => _launch(_fbUrl), icon: const Icon(Icons.facebook, color: Colors.white), label: Text('فيسبوك', style: GoogleFonts.cairo(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1877F2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(onPressed: () => _launch(_instaUrl), icon: const Icon(Icons.camera_alt, color: Colors.white), label: Text('انستغرام', style: GoogleFonts.cairo(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE1306C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        ]),
      ]),
    );
  }
}
