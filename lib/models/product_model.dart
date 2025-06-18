import 'package:flutter/foundation.dart';
import './agregado_model.dart'; // Import the new Agregado model

// Remove the temporary Agregado class definition that was here:
// class Agregado { ... } // DELETE THIS

class Product {
  final String id;
  final String nombre;
  final double precio;
  final String? descripcion;
  final String? subcategoria;
  final bool contieneModificadores;
  final bool zonaFranca;
  final bool localCentral;
  final String? imagen;
  List<Agregado> agregados;

  Product({
    required this.id,
    required this.nombre,
    required this.precio,
    this.descripcion,
    this.subcategoria,
    required this.contieneModificadores,
    required this.zonaFranca,
    required this.localCentral,
    this.imagen,
    this.agregados = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var agregadosList = json['agregados'] as List? ?? [];
    List<Agregado> parsedAgregados = agregadosList
        .map((i) => Agregado.fromJson(i as Map<String, dynamic>))
        .toList();
    return Product(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      precio: (json['precio'] as num).toDouble(),
      descripcion: json['descripcion'] as String?,
      subcategoria: json['subcategoria'] as String?,
      contieneModificadores: json['contieneModificadores'] as bool? ?? false,
      zonaFranca: json['zonaFranca'] as bool? ?? false,
      localCentral: json['localCentral'] as bool? ?? false,
      imagen: json['imagen'] as String?,
      agregados: parsedAgregados,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'subcategoria': subcategoria,
      'contieneModificadores': contieneModificadores,
      'zonaFranca': zonaFranca,
      'localCentral': localCentral,
      'imagen': imagen,
      'agregados': agregados.map((a) => a.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, nombre: $nombre, precio: $precio, subcategoria: $subcategoria, ZF: $zonaFranca, LC: $localCentral, imagen: $imagen, cm: $contieneModificadores, agregados: ${agregados.length})';
  }
}
