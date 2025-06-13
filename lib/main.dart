import 'package:flutter/material.dart';
import 'package:ruta9_app/screens/welcome_screen.dart'; // Asegúrate que esta ruta esté bien

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruta9 App',
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(), // <<<<< Cambia esto
    );
  }
}
