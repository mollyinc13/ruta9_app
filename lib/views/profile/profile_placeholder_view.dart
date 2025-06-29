// lib/views/profile/profile_placeholder_view.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart'; // Para el CartProvider si se quiere limpiar en logout
import 'package:ruta9_app/providers/cart_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../core/constants/colors.dart';

class ProfilePlaceholderView extends StatelessWidget {
  const ProfilePlaceholderView({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await GoogleSignIn().signOut(); // Sign out from Google
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase

      // Opcional: Limpiar el carrito al cerrar sesión
      // ignore: use_build_context_synchronously
      Provider.of<CartProvider>(context, listen: false).clearCart();

      // Navegar a LoginScreen y remover todas las rutas anteriores
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint("Error signing out: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: currentUser != null
              ? _buildUserProfile(context, currentUser, textTheme) // User is logged in
              : _buildLoginPrompt(context, textTheme), // User is not logged in
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? Icon(Icons.person, size: 50, color: AppColors.textMuted.withOpacity(0.8))
              : null,
          backgroundColor: AppColors.surfaceDark,
        ),
        const SizedBox(height: 20),
        Text(
          user.displayName ?? 'Usuario Ruta9',
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          user.email ?? 'Email no disponible',
          style: textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar Sesión'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
          ),
          onPressed: () => _signOut(context),
        ),
        // Aquí se podrían añadir más opciones de perfil como "Mis Pedidos", "Favoritos", etc.
      ],
    );
  }

  Widget _buildLoginPrompt(BuildContext context, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_outline,
          size: 80,
          color: textTheme.bodyLarge?.color?.withOpacity(0.4)
        ),
        const SizedBox(height: 20),
        Text(
          'Accede a tu Cuenta',
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para ver tu perfil y gestionar tus pedidos.',
          style: textTheme.titleMedium?.copyWith(
            color: textTheme.bodyLarge?.color?.withOpacity(0.6)
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
          ),
          onPressed: () {
            // Si LoginScreen es la ruta inicial cuando no hay auth,
            // este botón podría no ser necesario si el usuario ya fue redirigido.
            // Pero lo mantenemos por si se accede a esta vista de otra forma.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          },
          child: const Text('Iniciar Sesión con Google'),
        ),
      ],
    );
  }
}
