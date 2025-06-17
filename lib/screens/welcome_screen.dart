import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/welcome.mp4")
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
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
          SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }

  Widget _animatedButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false; // No tiene efecto en Android pero lo dejamos
        return Material(
          elevation: isHovered ? 6 : 3,
          borderRadius: BorderRadius.circular(8),
          color: isHovered ? Colors.white : Colors.red,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            onHover: (hovering) {
              setState(() {
                isHovered = hovering;
              });
            },
            child: Container(
              width: 200,
              height: 48,
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  color: isHovered ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
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
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video de fondo
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // Íconos RRSS arriba derecha
          Positioned(
            top: 30,
            right: 20,
            child: Row(
              children: [
                _iconButton(FontAwesomeIcons.instagram, 'https://ruta9.cl'),
                _iconButton(FontAwesomeIcons.whatsapp, 'https://ruta9.cl'),
              ],
            ),
          ),

          // Logo y botones
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logos/R9.png',
                    height: 120,
                  ),
                ),
                const SizedBox(height: 80),
                _animatedButton(
                  text: "RUTA 9 CENTRAL",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const menuruta9central()),
                    );
                  },
                ),
                SizedBox(height: 16),
                _animatedButton(
                  text: "R9 ZONA FRANCA",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const menur9zonafranca()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer Molly Inc.
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _openUrl("https://mollyinc.cl"),
              child: const Center(
                child: Text(
                  "Diseñado por Molly Inc.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla de Iniciar Sesión (placeholder)
class menuruta9central extends StatelessWidget {
  const menuruta9central({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Ruta9 Central")),
      body: const Center(child: Text("Local Central")),
    );
  }
}

// Pantalla de Menú Rutero (placeholder)
class menur9zonafranca extends StatelessWidget {
  const menur9zonafranca({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu R9 ZonaFranca")),
      body: const Center(child: Text("Local zona franca")),
    );
  }
}
