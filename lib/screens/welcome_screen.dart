// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Import MainAppShell
import 'main_app_shell.dart';
// Remove direct imports to menu screens if they are no longer directly navigated to
// import 'menuruta9central.dart';
// import 'menur9zonafranca.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _controller;

  final String instagramUrl = 'https://www.instagram.com/ruta9.burgers/?hl=es';
  final String whatsappUrl = 'https://api.whatsapp.com/send/?phone=56957636076&text&type=phone_number&app_absent=0';
  final String mollyIncUrl = 'https://mollyinc.cl';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/welcome.mp4")
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("No se pudo abrir la url: $url");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }

  Widget _animatedButton({ required String text, required VoidCallback onPressed, }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return Material(
          elevation: isHovered ? 6 : 3,
          borderRadius: BorderRadius.circular(8),
          color: isHovered ? Colors.white : Colors.red,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            onHover: (hovering) { setState(() { isHovered = hovering; }); },
            child: Container(
              width: 200, height: 48, alignment: Alignment.center,
              child: Text( text, style: TextStyle( color: isHovered ? Colors.red : Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, ), textAlign: TextAlign.center, ),
            ),
          ),
        );
      },
    );
  }

  Widget _iconButton(IconData icon, String url) {
     return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(12), boxShadow: const [ BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2),),],),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox( fit: BoxFit.cover, child: SizedBox( width: _controller.value.size.width, height: _controller.value.size.height, child: VideoPlayer(_controller),),)
                : const Center(child: CircularProgressIndicator()),
          ),
          Positioned(
            top: 30, right: 20,
            child: Row( children: [ _iconButton(FontAwesomeIcons.instagram, instagramUrl), _iconButton(FontAwesomeIcons.whatsapp, whatsappUrl),],),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration( color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12), boxShadow: const [ BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4),),],),
                  child: Image.asset('assets/images/logos/R9.png', height: 120,),
                ),
                const SizedBox(height: 80),
                _animatedButton(
                  text: "RUTA 9 CENTRAL", // This button will now also go to MainAppShell
                  onPressed: () {
                    // Navigate to MainAppShell. MainAppShell defaults to Zona Franca (Home tab).
                    // Specific logic to show Central menu might be handled by passing args to MainAppShell
                    // or if Central becomes its own tab later. For now, both go to MainAppShell.
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAppShell()));
                  },
                ),
                const SizedBox(height: 16),
                _animatedButton(
                  text: "R9 ZONA FRANCA",
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAppShell()));
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20, left: 0, right: 0,
            child: GestureDetector(
              onTap: () => _openUrl(mollyIncUrl),
              child: const Center( child: Text( "Diseñado por Molly Inc.", style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.normal,),),),
            ),
          ),
        ],
      ),
    );
  }
}
