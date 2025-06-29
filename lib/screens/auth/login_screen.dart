import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ruta9_app/screens/main_app_shell.dart'; // Para navegar después del login
import 'package:ruta9_app/services/firestore_service.dart'; // Para guardar usuario en Firestore
import 'package:ruta9_app/core/constants/colors.dart'; // Para colores
// Asegúrate que FontAwesomeIcons esté disponible si decides usarlo para el logo de Google
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  final FirestoreService _firestoreService = FirestoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) return;
    setState(() {
      _isSigningIn = true;
    });

    try {
      // Iniciar el proceso de Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el flujo de login
        if (mounted) setState(() { _isSigningIn = false; });
        return;
      }

      // Obtener los detalles de autenticación de la cuenta de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear una credencial para Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con la credencial
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Guardar/Actualizar usuario en Firestore
        await _firestoreService.saveUser(user);

        if (mounted) {
          // Navegar a la pantalla principal
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainAppShell()),
            (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
          );
        }
      } else {
        // No se pudo obtener el usuario de Firebase
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo iniciar sesión con Google.')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error en signInWithGoogle: $e");
      // Si el error es por network, google_sign_in a veces lanza PlatformException
      // con código 'network_error'.
      String errorMessage = 'Error al iniciar sesión. Intenta de nuevo.';
      if (e is FirebaseException) {
        errorMessage = e.message ?? errorMessage;
      } else if (e.toString().contains('network_error')) { // Heurística para error de red de google_sign_in
        errorMessage = 'Error de red. Verifica tu conexión e intenta de nuevo.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logos/R9.png', // Logo de la app
                height: 120,
              ),
              const SizedBox(height: 40),
              Text(
                'Bienvenido a Ruta9 App',
                style: textTheme.headlineSmall?.copyWith(color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Ingresa para continuar y realizar tus pedidos para retiro en local.',
                style: textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              _isSigningIn
                  ? const CircularProgressIndicator(color: AppColors.primaryRed)
                  : ElevatedButton.icon(
                      // Si no tienes 'assets/images/logos/google_logo.png', puedes usar un Icon:
                      // icon: const Icon(FontAwesomeIcons.google, color: Colors.red), // Ejemplo con FontAwesome
                      icon: Image.asset('assets/images/logos/google_logo.png', height: 22.0, width: 22.0),
                      label: const Text('Ingresar con Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        minimumSize: const Size(double.infinity, 50),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )
                      ),
                      onPressed: _signInWithGoogle,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
