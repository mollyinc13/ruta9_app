import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/product_model.dart';
import '../models/agregado_model.dart'; // Import the Agregado model

// Helper functions (_parseBool, _parseInt, _parseDouble) remain the same
bool _parseBool(String? value) {
  if (value == null) return false;
  return ['true', 'verdadero', '1', 'si', 'yes'].contains(value.toLowerCase().trim());
}

int? _parseInt(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return int.tryParse(value.trim());
}

double? _parseDouble(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

class CsvParser {
  // Modified parseProducts
  Future<List<Product>> parseProducts(String filePath) async {
    final products = <Product>[];
    try {
      final input = File(filePath).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(shouldParseNumbers: false))
          .toList();

      if (fields.length < 2) {
        print('Warning: productos.csv is empty or only contains a header.');
        return products;
      }

      // New header: Subcategoría,Código,Nombre,Descripción,Precio,Zona Franca,Local Central,Imagen,Contiene modificadores
      // Expected columns: 9
      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];

        if (row.length < 9) { // Check against new column count
          print('Warning: Skipping row in productos.csv due to insufficient columns (expected 9): $row');
          continue;
        }

        String getString(int index) => (row[index] is String ? row[index] : row[index]?.toString() ?? '').trim();
        dynamic getRaw(int index) => row[index];

        final codigo = getString(1);
        if (codigo.isEmpty) {
          print('Warning: Skipping row in productos.csv due to empty Código: $row');
          continue;
        }

        final precioStr = getRaw(4)?.toString();

        products.add(Product(
          subcategoria: getString(0).isEmpty ? null : getString(0),       // Subcategoría
          id: codigo,                                                      // Código (used as ID)
          nombre: getString(2),                                            // Nombre
          descripcion: getString(3).isEmpty ? null : getString(3),         // Descripción
          precio: _parseDouble(precioStr) ?? 0.0,                          // Precio
          zonaFranca: _parseBool(getRaw(5)?.toString()),                   // Zona Franca
          localCentral: _parseBool(getRaw(6)?.toString()),                 // Local Central
          imagen: getString(7).isEmpty ? null : getString(7),              // Imagen
          contieneModificadores: _parseBool(getRaw(8)?.toString()),        // Contiene modificadores
          agregados: [], // Initialize empty, will be populated by linkAgregadosToProducts
        ));
      }
    } catch (e) {
      print('Error parsing productos.csv: $e');
    }
    return products;
  }

  // New: parseAgregados
  Future<List<Map<String, dynamic>>> parseAgregados(String filePath) async {
    final agregadosData = <Map<String, dynamic>>[];
    try {
      final input = File(filePath).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(shouldParseNumbers: false))
          .toList();

      if (fields.length < 2) {
        print('Warning: agregados.csv is empty or only contains a header.');
        return agregadosData;
      }

      // Header: ProductoCodigo,AgregadoNombre,AgregadoPrecio,AgregadoImagen
      // Expected columns: 4
      for (var i = 1; i < fields.length; i++) {
          final row = fields[i];
          if (row.length < 4) { // Check against new column count
              print('Warning: Skipping row in agregados.csv due to insufficient columns (expected 4): $row');
              continue;
          }

          String getString(int index) => (row[index] is String ? row[index] : row[index]?.toString() ?? '').trim();
          dynamic getRaw(int index) => row[index];

          final productoCodigo = getString(0);
          final agregadoNombre = getString(1);
          final agregadoPrecioStr = getRaw(2)?.toString();
          final agregadoImagen = getString(3).isEmpty ? null : getString(3);

          if (productoCodigo.isEmpty || agregadoNombre.isEmpty) {
              print('Warning: Skipping agregado row due to empty ProductoCodigo or AgregadoNombre: $row');
              continue;
          }

          agregadosData.add({
            'productoCodigo': productoCodigo,
            'nombre': agregadoNombre,
            'precio': _parseDouble(agregadoPrecioStr) ?? 0.0,
            'imagen': agregadoImagen,
          });
      }
    } catch (e) {
      print('Error parsing agregados.csv: $e');
    }
    return agregadosData;
  }

  // New: linkAgregadosToProducts
  List<Product> linkAgregadosToProducts({
    required List<Product> products,
    required List<Map<String, dynamic>> agregadosRawData,
  }) {
    final productMap = {for (var p in products) p.id: p};

    for (final agregadoData in agregadosRawData) {
      final productoCodigo = agregadoData['productoCodigo'] as String?;
      if (productoCodigo == null || productoCodigo.isEmpty) {
        print('Warning: Agregado data found with no productoCodigo. Data: $agregadoData');
        continue;
      }

      final product = productMap[productoCodigo];

      if (product == null) {
        print('Warning: Product with Código "$productoCodigo" not found for agregado: ${agregadoData['nombre']}.');
        continue;
      }

      // No need to check product.contieneModificadores here for linking,
      // that field is for the UI to know if it *should* display an 'agregados' section.
      // The presence of linked agregados will be the source of truth.

      final agregado = Agregado(
        nombre: agregadoData['nombre'] as String,
        precio: agregadoData['precio'] as double,
        imagen: agregadoData['imagen'] as String?,
      );
      product.agregados.add(agregado);
    }
    return products;
  }

  // Old parseModifiersCsv and linkModifiersToProducts methods are removed.
}
