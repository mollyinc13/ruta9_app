// Defines the structure for an "Agregado" (add-on or extra)
class Agregado {
  final String nombre;    // Name of the add-on, e.g., "Extra Queso"
  final double precio;    // Price of the add-on, e.g., 3000
  final String? imagen;   // Optional image filename for the add-on, e.g., "extra_queso.jpg"

  Agregado({
    required this.nombre,
    required this.precio,
    this.imagen,
  });

  // Factory constructor for creating a new Agregado instance from a map (JSON)
  factory Agregado.fromJson(Map<String, dynamic> json) {
    return Agregado(
      nombre: json['nombre'] as String,
      precio: (json['precio'] as num).toDouble(), // Ensure price is parsed as double
      imagen: json['imagen'] as String?,
    );
  }

  // Method for converting an Agregado instance into a map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'precio': precio,
      'imagen': imagen,
    };
  }

  @override
  String toString() {
    return 'Agregado(nombre: $nombre, precio: $precio, imagen: $imagen)';
  }

  // Optional: For equality checks if you plan to use Sets of Agregado or compare them.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Agregado &&
        other.nombre == nombre &&
        other.precio == precio &&
        other.imagen == imagen;
  }

  @override
  int get hashCode => nombre.hashCode ^ precio.hashCode ^ imagen.hashCode;
}
