// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for PlatformException
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audioplayers/audioplayers.dart'; // Added audioplayers
import 'main_app_shell.dart';
import 'totem_kiosk_screen.dart'; // Added import for TotemKioskScreen

// Helper class for Fade Page Route (can be in its own file or here for simplicity)
class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
                opacity: animation,
                child: child,
              ),
          transitionDuration: const Duration(milliseconds: 400), // Adjust duration as needed
        );
}


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Added AudioPlayer instance
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  final String instagramUrl = 'https://www.instagram.com/ruta9.burgers/?hl=es';
  final String whatsappUrl = 'https://api.whatsapp.com/send/?phone=56957636076&text&type=phone_number&app_absent=0';
  final String mollyIncUrl = 'https://mollyinc.cl';

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset("assets/videos/welcome.mp4")
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _audioPlayer.dispose(); // Dispose AudioPlayer
    _passwordController.dispose(); // Dispose TextEditingController
    super.dispose();
  }

  Future<void> _playSecretSound() async {
    try {
      // Assuming you have 'exclamation.mp3' in 'assets/audio/'
      // The path for AssetSource should be relative to 'assets/' folder
      await _audioPlayer.play(AssetSource('audio/exclamation.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
      // Handle error, e.g., show a generic error message or log it
    }
  }

  void _showPasswordDialog() {
    _passwordController.clear(); // Clear previous input
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Acceso Restringido'),
          content: TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Ingrese la clave',
              icon: Icon(Icons.lock_outline),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Ingresar'),
              onPressed: () {
                _validatePasswordAndNavigate();
              },
            ),
          ],
        );
      },
    );
  }

  void _validatePasswordAndNavigate() {
    const String correctPassword = 'ruta 9.9196';
    if (_passwordController.text == correctPassword) {
      Navigator.of(context).pop(); // Close the dialog
      Navigator.pushReplacement( // Navigate to Kiosk screen
        context,
        MaterialPageRoute(builder: (context) => const TotemKioskScreen()),
      );
    } else {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clave incorrecta.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Future<void> _openUrl(String url) async { // This line was part of the duplicated methods, ensure it's correctly placed or removed if logic is already above.
  // For now, assuming the _openUrl, _animatedButton, _iconButton, and build method below are the correct ones to keep.
  // The duplicated initState and dispose that used _controller are removed by this diff not including them after the corrected section.

  Future<void> _openUrl(String url) async { // KEEPING THIS _openUrl and below
    final uri = Uri.parse(url);
    String errorMessage = 'No se pudo abrir el enlace.';
    try {
      if (await canLaunchUrl(uri)) {
        bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          errorMessage = 'El sistema no pudo iniciar el enlace.';
          debugPrint("launchUrl returned false for: $url");
        } else {
          return;
        }
      } else {
        errorMessage = 'No se encontró una aplicación para abrir el enlace.';
        debugPrint("canLaunchUrl returned false for: $url");
      }
    } on PlatformException catch (e) {
      errorMessage = 'Error de plataforma al abrir el enlace: ${e.message}';
      debugPrint("PlatformException while opening url: $url, Error: $e");
    } catch (e) {
      errorMessage = 'Error desconocido al abrir el enlace: $e';
      debugPrint("Unknown error while opening url: $url, Error: $e");
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)),);
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
    return WillPopScope(
      onWillPop: () async {
        // Permite salir de la app desde WelcomeScreen
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
            child: _videoController.value.isInitialized // Corrected to _videoController
                ? FittedBox( fit: BoxFit.cover, child: SizedBox( width: _videoController.value.size.width, height: _videoController.value.size.height, child: VideoPlayer(_videoController),),) // Corrected to _videoController
                : const Center(child: CircularProgressIndicator()),
          ),
          Positioned( // Botón secreto
            top: 30,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.priority_high_rounded, color: Colors.white70),
              iconSize: 24.0, // Tamaño similar o más pequeño que los de redes sociales
              tooltip: 'Acceso Kiosco',
              onPressed: () {
                _playSecretSound();
                _showPasswordDialog();
              },
            ),
          ),
          Positioned(
            top: 30, right: 20,
            child: Row( children: [ _iconButton(FontAwesomeIcons.instagram, instagramUrl), _iconButton(FontAwesomeIcons.whatsapp, whatsappUrl),],),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration( color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12), boxShadow: const [ BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4),),],),
                  child: Image.asset('assets/images/logos/R9.png', height: 120,),
                ),
                const SizedBox(height: 80),
                _animatedButton(
                  text: "RUTA 9 CENTRAL",
                  onPressed: () {
                    Navigator.pushReplacement(context, FadeRoute(page: const MainAppShell())); // MODIFIED
                  },
                ),
                const SizedBox(height: 16),
                _animatedButton(
                  text: "R9 ZONA FRANCA",
                  onPressed: () {
                    Navigator.pushReplacement(context, FadeRoute(page: const MainAppShell())); // MODIFIED
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
    ));
  }
}
