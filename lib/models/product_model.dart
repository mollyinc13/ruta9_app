import 'package:flutter/foundation.dart';

class Product {
  final String id; // Assuming CSV 'Código' will be used as id
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
  List<Modifier> modificadores; // Will be populated later

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

  @override
  String toString() {
    return 'Product(id: $id, nombre: $nombre, precio: $precio, descripcion: $descripcion, activo: $activo, favorito: $favorito, controlStock: $controlStock, stock: $stock, costo: $costo, margen: $margen, contieneModificadores: $contieneModificadores, permitirVenderSolo: $permitirVenderSolo, posicion: $posicion, subcategoria: $subcategoria, modificadores: ${modificadores.map((m) => m.toString()).toList()})';
  }
}

class Modifier {
  final int grupoId;
  final String titulo;
  final int cantidadMinima;
  final int cantidadMaxima;
  // It might be useful to have a product identifier here if modifiers are parsed separately
  // and then linked. For now, assuming they are parsed in context of a product or linked by product name/code.
  // final String productoNombreOrCodigo; // Example: To link back to product from CSV

  Modifier({
    required this.grupoId,
    required this.titulo,
    required this.cantidadMinima,
    required this.cantidadMaxima,
    // this.productoNombreOrCodigo,
  });

  @override
  String toString() {
    return 'Modifier(grupoId: $grupoId, titulo: $titulo, cantidadMinima: $cantidadMinima, cantidadMaxima: $cantidadMaxima)';
  }
}
