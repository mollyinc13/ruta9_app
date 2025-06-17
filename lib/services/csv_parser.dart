import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/product_model.dart';

// Helper function to safely parse boolean values from CSV
bool _parseBool(String? value) {
  if (value == null) return false;
  return ['true', 'verdadero', '1', 'si', 'yes'].contains(value.toLowerCase().trim());
}

// Helper function to safely parse int values from CSV
int? _parseInt(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return int.tryParse(value.trim());
}

// Helper function to safely parse double values from CSV
double? _parseDouble(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  // Replace comma with dot for decimal conversion if necessary
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

class CsvParser {
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

      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];

        if (row.length < 15) {
          print('Warning: Skipping row in productos.csv due to insufficient columns: $row');
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
        final costoStr = getRaw(5)?.toString();
        final stockStr = getRaw(10)?.toString();
        final margenStr = getRaw(11)?.toString();
        final posicionStr = getRaw(14)?.toString();

        products.add(Product(
          subcategoria: getString(0).isEmpty ? null : getString(0),
          id: codigo,
          nombre: getString(2),
          descripcion: getString(3).isEmpty ? null : getString(3),
          precio: _parseDouble(precioStr) ?? 0.0,
          costo: _parseDouble(costoStr),
          activo: _parseBool(getRaw(7)?.toString()),
          favorito: _parseBool(getRaw(8)?.toString()),
          controlStock: _parseBool(getRaw(9)?.toString()),
          stock: _parseInt(stockStr),
          margen: _parseDouble(margenStr),
          contieneModificadores: _parseBool(getRaw(12)?.toString()),
          permitirVenderSolo: _parseBool(getRaw(13)?.toString()),
          posicion: _parseInt(posicionStr) ?? 0,
          modificadores: [],
        ));
      }
    } catch (e) {
      print('Error parsing productos.csv: $e');
    }
    return products;
  }

  Future<List<Map<String, dynamic>>> parseModifiersCsv(String filePath) async {
    final modifiersData = <Map<String, dynamic>>[];
    try {
      final input = File(filePath).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(shouldParseNumbers: false))
          .toList();

      if (fields.length < 2) {
        print('Warning: modificadores.csv is empty or only contains a header.');
        return modifiersData;
      }

      for (var i = 1; i < fields.length; i++) {
          final row = fields[i];
          if (row.length < 5) {
              print('Warning: Skipping row in modificadores.csv due to insufficient columns: $row');
              continue;
          }

          String getString(int index) => (row[index] is String ? row[index] : row[index]?.toString() ?? '').trim();
          dynamic getRaw(int index) => row[index];

          final productoRef = getString(0);
          final grupoIdStr = getRaw(1)?.toString();
          final titulo = getString(2);
          final minCantidadStr = getRaw(3)?.toString();
          final maxCantidadStr = getRaw(4)?.toString();

          if (productoRef.isEmpty || titulo.isEmpty) {
              print('Warning: Skipping modifier row due to empty product reference or title: $row');
              continue;
          }

          modifiersData.add({
            'productoRef': productoRef, // This is the product identifier (Código)
            'grupoId': _parseInt(grupoIdStr) ?? 0,
            'titulo': titulo,
            'cantidadMinima': _parseInt(minCantidadStr) ?? 0,
            'cantidadMaxima': _parseInt(maxCantidadStr) ?? 1,
          });
      }
    } catch (e) {
      print('Error parsing modificadores.csv: $e');
    }
    return modifiersData;
  }

  // New method to link modifiers to products
  List<Product> linkModifiersToProducts({
    required List<Product> products,
    required List<Map<String, dynamic>> modifiersRawData,
  }) {
    final productMap = {for (var p in products) p.id: p};

    for (final modifierData in modifiersRawData) {
      final productRef = modifierData['productoRef'] as String?;
      if (productRef == null || productRef.isEmpty) {
        print('Warning: Modifier data found with no product reference. Data: $modifierData');
        continue;
      }

      final product = productMap[productRef];

      if (product == null) {
        print('Warning: Product with Código "$productRef" not found for modifier: ${modifierData['titulo']}.');
        continue;
      }

      if (!product.contieneModificadores) {
        print('Warning: Product "${product.nombre}" (Código: ${product.id}) is marked as not containing modifiers, but modifier data found: ${modifierData['titulo']}. Skipping this modifier.');
        continue;
      }

      final modifier = Modifier(
        grupoId: modifierData['grupoId'] as int,
        titulo: modifierData['titulo'] as String,
        cantidadMinima: modifierData['cantidadMinima'] as int,
        cantidadMaxima: modifierData['cantidadMaxima'] as int,
      );
      product.modificadores.add(modifier);
    }
    return products; // Return the list of products, now with linked modifiers
  }
}
