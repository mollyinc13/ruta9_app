import '../models/product_model.dart';

class LocalDataTester {
  static void testProcessedData(List<Product> products) {
    if (products.isEmpty) {
      print('No products to display.');
      return;
    }

    print('\n--- Processed Product Data (Local Test) ---');
    for (final product in products) {
      print('\n-----------------------------------------');
      print('Producto: ${product.nombre} (ID/Código: ${product.id})');
      print('  Precio: ${product.precio}');
      print('  Subcategoría: ${product.subcategoria ?? 'N/A'}');
      print('  Descripción: ${product.descripcion ?? 'N/A'}');
      print('  Activo: ${product.activo}');
      print('  Favorito: ${product.favorito}');
      print('  Control de Stock: ${product.controlStock}');
      print('  Stock: ${product.stock ?? 'N/A'}');
      print('  Costo: ${product.costo ?? 'N/A'}');
      print('  Margen: ${product.margen ?? 'N/A'}');
      print('  Contiene Modificadores: ${product.contieneModificadores}');
      print('  Permitir Vender Solo: ${product.permitirVenderSolo}');
      print('  Posición: ${product.posicion}');

      if (product.contieneModificadores && product.modificadores.isNotEmpty) {
        print('  Modificadores (${product.modificadores.length}):');
        for (final modifier in product.modificadores) {
          print('    - Grupo ID: ${modifier.grupoId}');
          print('      Título: ${modifier.titulo}');
          print('      Cantidad Mínima: ${modifier.cantidadMinima}');
          print('      Cantidad Máxima: ${modifier.cantidadMaxima}');
        }
      } else if (product.contieneModificadores && product.modificadores.isEmpty) {
        print('  Modificadores: (No modifiers linked despite "contieneModificadores" being true)');
      } else {
        // print('  Modificadores: (Product does not contain modifiers)');
      }
    }
    print('\n-----------------------------------------');
    print('--- End of Processed Product Data ---');
  }
}
