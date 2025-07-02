import 'package:flutter/material.dart';

// Constante para leer el modo desde el entorno (compilación)
// Para ejecutar en modo tótem: flutter run --dart-define=IS_TOTEM_MODE=true
// Por defecto (si no se define), será modo cliente.
const bool _isTotemModeCompilation = bool.fromEnvironment('IS_TOTEM_MODE', defaultValue: false);

class AppMode extends InheritedWidget {
  final bool isTotemMode;

  const AppMode({
    super.key,
    required this.isTotemMode,
    required super.child,
  });

  static AppMode? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppMode>();
  }

  static AppMode of(BuildContext context) {
    final AppMode? result = maybeOf(context);
    assert(result != null, 'No AppMode found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppMode oldWidget) => isTotemMode != oldWidget.isTotemMode;
}

// Helper para acceder fácilmente al modo
bool isTotemMode(BuildContext context) {
  return AppMode.of(context).isTotemMode;
}

// También podemos tener una forma de obtener el valor de compilación directamente
// si es necesario antes de que el context esté completamente disponible,
// aunque es mejor usar el InheritedWidget.
bool get isTotemModeFromEnv => _isTotemModeCompilation;
