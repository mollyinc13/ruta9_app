// lib/screens/main_app_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/cart_provider.dart'; // Import CartProvider
import 'menur9zonafranca.dart';
import '../views/profile/profile_placeholder_view.dart';
import '../views/cart/cart_placeholder_view.dart'; // Will be replaced by CartScreen later
import '../core/constants/colors.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  // _pages list will be updated later to use the actual CartScreen
  final List<Widget> _pages = [
    const MenuR9ZonaFrancaScreen(),
    const ProfilePlaceholderView(),
    const CartPlaceholderView(), // Current placeholder for Cart
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Watch CartProvider for changes to itemCount to update the badge
    final cartItemCount = context.watch<CartProvider>().itemCount;

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
        items: [
          const BottomNavigationBarItem( // Made const
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem( // Made const
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem( // Cart tab - now with badge
            icon: Badge( // Using Badge widget
              label: Text('$cartItemCount'),
              isLabelVisible: cartItemCount > 0,
              backgroundColor: AppColors.accentRed, // Or colorScheme.error
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge( // Badge on active icon as well
              label: Text('$cartItemCount'),
              isLabelVisible: cartItemCount > 0,
              backgroundColor: AppColors.accentRed, // Or colorScheme.error
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
