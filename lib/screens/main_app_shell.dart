// lib/screens/main_app_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'menur9zonafranca.dart';
import '../views/profile/profile_placeholder_view.dart';
import '../views/cart/cart_screen.dart'; // Assuming CartScreen is now used
import '../core/constants/colors.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});
  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MenuR9ZonaFrancaScreen(),
    const ProfilePlaceholderView(),
    const CartScreen(), // Using CartScreen now
  ];

  void _onTabTapped(int index) {
    setState(() { _currentIndex = index; });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final cartItemCount = context.watch<CartProvider>().itemCount;
    debugPrint("[MainAppShell.build] Rebuilding. Cart item count: $cartItemCount");

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false; // No salir de la app, ir a la pestaña inicial
        }
        return true; // Salir de la app si ya está en la pestaña inicial
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition( // Apply fade transition
            opacity: animation,
            child: child,
          );
        },
        child: _pages[_currentIndex], // Key is important for AnimatedSwitcher to detect change
        // Using ValueKey for child to ensure AnimatedSwitcher detects child change
        // Note: The child itself (_pages[_currentIndex]) must have a Key if it's stateful and you
        // want to preserve its state across switches in a more complex scenario,
        // or ensure AnimatedSwitcher correctly identifies it as a "new" child.
        // For simple view switching, this should work.
        // For state preservation with AnimatedSwitcher, one might need to manage pages differently.
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
          const BottomNavigationBarItem( icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio', ),
          const BottomNavigationBarItem( icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil', ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$cartItemCount'),
              isLabelVisible: cartItemCount > 0,
              backgroundColor: AppColors.accentRed,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              label: Text('$cartItemCount'),
              isLabelVisible: cartItemCount > 0,
              backgroundColor: AppColors.accentRed,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Carrito',
          ),
        ]
      ),
    ));
    
  }
}
