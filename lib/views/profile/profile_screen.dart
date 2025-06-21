// lib/views/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/colors.dart';

// Import the new placeholder screens
import 'favorites_screen_placeholder.dart';
import 'order_history_screen_placeholder.dart';
import 'payment_methods_screen_placeholder.dart';
// (Assuming LoginScreen might be needed for logout, ensure it's imported if not already)
import '../../screens/auth/login_screen.dart';


// Remove the local _navigateToPlaceholder function:
// void _navigateToPlaceholder(BuildContext context, String title) { ... } // DELETE THIS

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    const String userName = "Usuario Ruta9";
    const String userEmail = "usuario@ruta9.app";
    const String profileImageUrl = "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(24.0),
            color: AppColors.surfaceDark,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryRed.withOpacity(0.7),
                  backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                  child: profileImageUrl.isEmpty
                      ? const FaIcon(FontAwesomeIcons.userAstronaut, size: 50, color: AppColors.textLight)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(userName, style: textTheme.headlineSmall?.copyWith(color: AppColors.textLight)),
                const SizedBox(height: 4),
                Text(userEmail, style: textTheme.titleMedium?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildProfileOptionTile(
            context: context,
            icon: FontAwesomeIcons.heart,
            title: 'Mis Favoritos',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreenPlaceholder()));
            },
          ),
          _buildProfileOptionTile(
            context: context,
            icon: FontAwesomeIcons.receipt,
            title: 'Historial de Pedidos',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreenPlaceholder()));
            },
          ),
          _buildProfileOptionTile(
            context: context,
            icon: FontAwesomeIcons.creditCard,
            title: 'Métodos de Pago',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreenPlaceholder()));
            },
          ),
          _buildProfileOptionTile(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Configuración',
            onTap: () {
              Navigator.push( context, MaterialPageRoute( builder: (context) => Scaffold( appBar: AppBar(title: const Text('Configuración')), body: Center(child: Text('Configuración (Próximamente)', style: Theme.of(context).textTheme.headlineSmall)),),),);
            },
          ),
          const Divider(height: 32, indent: 16, endIndent: 16),
          _buildProfileOptionTile(
            context: context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            textColor: colorScheme.error,
            onTap: () {
              print('Logout button pressed');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cerrar Sesión (pendiente).')),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: FaIcon(icon, color: textColor ?? textTheme.bodyLarge?.color?.withOpacity(0.7), size: 22),
      title: Text(title, style: textTheme.titleMedium?.copyWith(color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
