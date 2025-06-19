// lib/screens/main_app_shell.dart
import 'package:flutter/material.dart';
import 'menur9zonafranca.dart';
// Remove direct import of AppTheme if not used directly for colors here
// import '../core/theme/app_theme.dart';
import '../core/constants/colors.dart'; // AppColors is used for BottomNavBar background

// Import the new placeholder views
import '../views/profile/profile_placeholder_view.dart';
import '../views/cart/cart_placeholder_view.dart';

// Remove the local PlaceholderWidget definition:
// class PlaceholderWidget extends StatelessWidget { ... } // DELETE THIS

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  // Updated _pages list to use the new placeholder views
  final List<Widget> _pages = [
    const MenuR9ZonaFrancaScreen(),         // Index 0: Home
    const ProfilePlaceholderView(),         // Index 1: Profile
    const CartPlaceholderView(),            // Index 2: Cart
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Keep for consistency if theme access needed
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
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
