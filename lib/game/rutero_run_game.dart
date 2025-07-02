import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Para obtener UID
// import 'package:cloud_firestore/cloud_firestore.dart'; // Para guardar puntajes
// import 'package:ruta9_app/services/firestore_service.dart'; // Si se usa el servicio existente

// Componentes del juego (se crearán más adelante)
// class Player extends SpriteAnimationComponent with HasGameRef<RuteroRunGame> { ... }
// class Obstacle extends PositionComponent with HasGameRef<RuteroRunGame> { ... }

class RuteroRunGame extends FlameGame with TapCallbacks, HasCollisionDetection { // Agregado HasCollisionDetection
  late TextComponent _scoreText;
  late TextComponent _highScoreText; // Para mostrar el puntaje máximo del usuario
  int score = 0;
  int _userHighScore = 0; // Se cargaría desde Firestore

  // Referencia al UID del usuario (se pasaría o se obtendría)
  String? userId;

  // TODO: Añadir FirestoreService para interactuar con la base de datos
  // final FirestoreService _firestoreService = FirestoreService();

  // TODO: Añadir Player y ObstacleManager
  // late Player _player;
  // late ObstacleManager _obstacleManager;

  bool _isGameOver = false;
  bool _gameStarted = false;

  RuteroRunGame({this.userId});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Configuración de la cámara y el mundo si es necesario
    // camera.viewport = FixedResolutionViewport(Vector2(360, 640)); // Ejemplo

    _scoreText = TextComponent(
      text: 'Puntaje: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 20)),
    );
    add(_scoreText);

    _highScoreText = TextComponent(
      text: 'Max: $_userHighScore',
      position: Vector2(size.x - 10, 10), // Alineado a la derecha
      anchor: Anchor.topRight,
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
    add(_highScoreText);

    // TODO: Cargar _userHighScore desde Firestore usando userId
    // await _loadHighScore();

    // Pantalla de inicio del juego
    _showStartScreen();
  }

  void _showStartScreen() {
    final startScreenText = TextComponent(
      text: 'Toca para Empezar\nRutero Run!',
      position: size / 2,
      anchor: Anchor.center,
      textAlign: TextAlign.center,
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
    );
    add(startScreenText);
  }

  void startGame() {
    if (_gameStarted) return;
    _gameStarted = true;
    _isGameOver = false;
    score = 0;
    _scoreText.text = 'Puntaje: 0';

    // Remover mensajes de inicio/game over
    children.whereType<TextComponent>().where((c) => c.text.contains('Toca para Empezar') || c.text.contains('Game Over')).forEach(remove);

    // TODO: Inicializar y añadir jugador
    // _player = Player();
    // add(_player);

    // TODO: Inicializar y añadir ObstacleManager
    // _obstacleManager = ObstacleManager();
    // add(_obstacleManager);

    // TODO: Resetear posiciones y estados de componentes del juego
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!_gameStarted) {
      startGame();
    } else if (_isGameOver) {
      // Reiniciar juego
      // TODO: Implementar lógica de reinicio completo
      _showStartScreen(); // Temporalmente muestra la pantalla de inicio de nuevo
       _gameStarted = false; // Para permitir que el próximo tap inicie el juego
       _isGameOver = false;
    } else {
      // TODO: Lógica de tap durante el juego (ej. salto del jugador)
      // _player.jump();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_gameStarted || _isGameOver) return;

    // Lógica de incremento de puntaje (ej. basado en tiempo)
    // score += (dt * 100).toInt(); // Ejemplo
    // _scoreText.text = 'Puntaje: $score';

    // TODO: Lógica de colisiones, fin de juego, etc.
  }

  void gameOver() {
    if (_isGameOver) return;
    _isGameOver = true;
    _gameStarted = false; // Para que el próximo tap no sea una acción de juego

    // TODO: Detener movimiento de obstáculos y jugador
    // _obstacleManager.stop();
    // _player.stop();

    final gameOverText = TextComponent(
      text: 'Game Over\nPuntaje: $score\nToca para reintentar',
      position: size / 2,
      anchor: Anchor.center,
      textAlign: TextAlign.center,
      textRenderer: TextPaint(style: const TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
    );
    add(gameOverText);

    // TODO: Guardar puntaje en Firestore y actualizar high score si es necesario
    // await _saveScore();
  }

  // TODO: Implementar _loadHighScore y _saveScore
  // Future<void> _loadHighScore() async { ... }
  // Future<void> _saveScore() async { ... }
}
