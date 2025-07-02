import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener UID del usuario actual
import 'rutero_run_game.dart'; // Importa la lógica del juego Flame

// Pantalla que contiene el widget del juego
class RuteroRunScreen extends StatelessWidget {
  const RuteroRunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      // AppBar opcional, podría quitarse para una experiencia más inmersiva
      appBar: AppBar(
        title: const Text('Rutero Run'),
        // Podría tener un botón para salir del juego y volver a la app principal
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.close),
        //     onPressed: () => Navigator.of(context).pop(), // O una navegación más específica
        //   )
        // ],
      ),
      body: RuteroRunGameWidget(userId: userId),
    );
  }
}


// Widget que carga el juego Flame
class RuteroRunGameWidget extends StatelessWidget {
  final String? userId; // Para pasar el UID del usuario al juego

  const RuteroRunGameWidget({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: RuteroRunGame(userId: userId),
      // Aquí se pueden añadir widgets de Flutter sobre el juego si es necesario
      // overlayBuilderMap: {
      //   'PauseMenu': (BuildContext context, RuteroRunGame game) {
      //     return Text('Juego Pausado');
      //   },
      // },
      // initialActiveOverlays: const ['PauseMenu'], // Ejemplo
    );
  }
}
