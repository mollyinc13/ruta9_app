import 'dart:convert'; // For jsonEncode
import 'dart:io';
import '../lib/models/product_model.dart';
import '../lib/services/csv_parser.dart';
import '../lib/utils/local_data_tester.dart'; // LocalDataTester might need review for new Product structure, but basic toString will work.

const String productsCsvPath = 'data/productos.csv';
const String agregadosCsvPath = 'data/agregados.csv'; // Changed from modifiersCsvPath
const String outputJsonPath = 'assets/data/products.json';

Future<void> main() async {
  print('Starting data import process...');
  final csvParser = CsvParser();

  // Check if products CSV file exists
  if (!await File(productsCsvPath).exists()) {
    print('Error: $productsCsvPath not found. Please create it with product data.');
    exit(1);
  }
  // Check if agregados CSV file exists
  if (!await File(agregadosCsvPath).exists()) {
    print('Error: $agregadosCsvPath not found. Please create it with agregado data.');
    exit(1);
  }

  // 1. Parse Products
  print('Parsing products from $productsCsvPath...');
  List<Product> products = await csvParser.parseProducts(productsCsvPath);
  if (products.isEmpty && File(productsCsvPath).lengthSync() > 50) {
      print('No products parsed, but file seems to have data. Check CSV format and parser logic.');
  } else {
      print('Parsed ${products.length} products.');
  }

  // 2. Parse Agregados Raw Data
  print('Parsing agregados from $agregadosCsvPath...');
  List<Map<String, dynamic>> agregadosRawData = await csvParser.parseAgregados(agregadosCsvPath); // Changed method call
  if (agregadosRawData.isEmpty && File(agregadosCsvPath).lengthSync() > 20) { // Basic check for content
      print('No agregados parsed, but file seems to have data. Check CSV format and parser logic.');
  } else {
      print('Parsed ${agregadosRawData.length} raw agregado entries.');
  }

  // 3. Link Agregados to Products
  print('Linking agregados to products...');
  products = csvParser.linkAgregadosToProducts( // Changed method call
    products: products,
    agregadosRawData: agregadosRawData,
  );
  print('Finished linking agregados.');

  // 4. Test Processed Data (Print to Console)
  // LocalDataTester.testProcessedData(products);
  // The existing LocalDataTester will print basic info due to Product.toString()
  // For more detailed testing of agregados, LocalDataTester might need an update,
  // but for now, ensuring products.json is generated is the main goal.
  print('--- Sample of Processed Product Data (from tool/import_data.dart) ---');
  for (int i = 0; i < products.length && i < 2; i++) { // Print first 2 products as sample
      print(products[i].toString());
      if (products[i].agregados.isNotEmpty) {
          print('  Agregados for ${products[i].nombre}:');
          for (var agregado in products[i].agregados) {
              print('    - ${agregado.nombre}, Precio: ${agregado.precio}, Imagen: ${agregado.imagen}');
          }
      }
  }
  print('--------------------------------------------------------------------');


  // Create assets/data directory if it doesn't exist
  final assetsDataDir = Directory('assets/data');
  if (!await assetsDataDir.exists()) {
    await assetsDataDir.create(recursive: true);
    print('Created directory: ${assetsDataDir.path}');
  }

  // Serialize to JSON and save
  try {
    final List<Map<String, dynamic>> productsJson = products.map((p) => p.toJson()).toList();
    final String jsonString = jsonEncode(productsJson); // Use an encoder with indent for readability
    // final String jsonString = JsonEncoder.withIndent('  ').convert(productsJson); // More readable JSON
    final File outputFile = File(outputJsonPath);
    await outputFile.writeAsString(jsonString);
    print('Successfully saved processed data to $outputJsonPath');
  } catch (e) {
    print('Error saving products to JSON: $e');
  }

  print('\nData import process completed.');
  print('Run the app to see the changes. The new products.json is in assets/data/.');
}
