// lib/screens/main_app_shell.dart
import 'package:flutter/material.dart';
import 'menur9zonafranca.dart';
import '../core/theme/app_theme.dart'; // Import AppTheme for colors if needed directly
import '../core/constants/colors.dart'; // Import AppColors

// PlaceholderWidget definition (remains the same)
class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 50, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('$title (Próximamente)', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MenuR9ZonaFrancaScreen(),
    const PlaceholderWidget(title: 'Perfil de Usuario'),
    const PlaceholderWidget(title: 'Carrito de Compras'),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ThemeData and ColorScheme for styling
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: AppColors.backgroundDark, // Use a specific dark color from AppColors or theme
        selectedItemColor: colorScheme.primary, // e.g., AppColors.primaryRed
        unselectedItemColor: AppColors.textMuted, // e.g., Colors.grey[400] or from AppColors
        type: BottomNavigationBarType.fixed, // Ensures labels are always visible
        selectedFontSize: 12.0, // Adjust font size if needed
        unselectedFontSize: 12.0, // Adjust font size if needed
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
