import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String nombre;
  final double precio;
  final String? descripcion;
  final bool activo;
  final bool favorito;
  final bool controlStock;
  final int? stock;
  final double? costo;
  final double? margen;
  final bool contieneModificadores;
  final bool permitirVenderSolo;
  final int posicion;
  final String? subcategoria;
  List<Modifier> modificadores;

  Product({
    required this.id,
    required this.nombre,
    required this.precio,
    this.descripcion,
    required this.activo,
    required this.favorito,
    required this.controlStock,
    this.stock,
    this.costo,
    this.margen,
    required this.contieneModificadores,
    required this.permitirVenderSolo,
    required this.posicion,
    this.subcategoria,
    this.modificadores = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var modifiersList = json['modificadores'] as List? ?? [];
    List<Modifier> parsedModifiers = modifiersList
        .map((i) => Modifier.fromJson(i as Map<String, dynamic>))
        .toList();

    return Product(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      precio: (json['precio'] as num).toDouble(),
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool,
      favorito: json['favorito'] as bool,
      controlStock: json['controlStock'] as bool,
      stock: json['stock'] as int?,
      costo: (json['costo'] as num?)?.toDouble(),
      margen: (json['margen'] as num?)?.toDouble(),
      contieneModificadores: json['contieneModificadores'] as bool,
      permitirVenderSolo: json['permitirVenderSolo'] as bool,
      posicion: json['posicion'] as int,
      subcategoria: json['subcategoria'] as String?,
      modificadores: parsedModifiers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'activo': activo,
      'favorito': favorito,
      'controlStock': controlStock,
      'stock': stock,
      'costo': costo,
      'margen': margen,
      'contieneModificadores': contieneModificadores,
      'permitirVenderSolo': permitirVenderSolo,
      'posicion': posicion,
      'subcategoria': subcategoria,
      'modificadores': modificadores.map((m) => m.toJson()).toList(),
    };
  }

  @override
  String toString() {
    // Keep the existing toString for debugging if needed
    return 'Product(id: $id, nombre: $nombre, precio: $precio, subcategoria: $subcategoria, contieneModificadores: $contieneModificadores, modificadores: ${modificadores.length})';
  }
}

class Modifier {
  final int grupoId;
  final String titulo;
  final int cantidadMinima;
  final int cantidadMaxima;

  Modifier({
    required this.grupoId,
    required this.titulo,
    required this.cantidadMinima,
    required this.cantidadMaxima,
  });

  factory Modifier.fromJson(Map<String, dynamic> json) {
    return Modifier(
      grupoId: json['grupoId'] as int,
      titulo: json['titulo'] as String,
      cantidadMinima: json['cantidadMinima'] as int,
      cantidadMaxima: json['cantidadMaxima'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grupoId': grupoId,
      'titulo': titulo,
      'cantidadMinima': cantidadMinima,
      'cantidadMaxima': cantidadMaxima,
    };
  }

  @override
  String toString() {
    return 'Modifier(grupoId: $grupoId, titulo: $titulo, min: $cantidadMinima, max: $cantidadMaxima)';
  }
}
