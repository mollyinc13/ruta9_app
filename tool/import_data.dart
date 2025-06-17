import 'dart:convert'; // For jsonEncode
import 'dart:io';
import '../lib/models/product_model.dart';
import '../lib/services/csv_parser.dart';
import '../lib/utils/local_data_tester.dart';

const String productsCsvPath = 'data/productos.csv';
const String modifiersCsvPath = 'data/modificadores.csv';
const String outputJsonPath = 'assets/data/products.json'; // Output path

Future<void> main() async {
  print('Starting data import process...');
  final csvParser = CsvParser();

  if (!await File(productsCsvPath).exists()) {
    print('Error: $productsCsvPath not found.');
    exit(1);
  }
  if (!await File(modifiersCsvPath).exists()) {
    print('Error: $modifiersCsvPath not found.');
    exit(1);
  }

  List<Product> products = await csvParser.parseProducts(productsCsvPath);
  print('Parsed ${products.length} products.');

  List<Map<String, dynamic>> modifiersRawData = await csvParser.parseModifiersCsv(modifiersCsvPath);
  print('Parsed ${modifiersRawData.length} raw modifier entries.');

  products = csvParser.linkModifiersToProducts(
    products: products,
    modifiersRawData: modifiersRawData,
  );
  print('Finished linking modifiers.');

  LocalDataTester.testProcessedData(products);

  // Create assets/data directory if it doesn't exist
  final assetsDataDir = Directory('assets/data');
  if (!await assetsDataDir.exists()) {
    await assetsDataDir.create(recursive: true);
    print('Created directory: ${assetsDataDir.path}');
  }

  // Serialize to JSON and save
  try {
    final List<Map<String, dynamic>> productsJson = products.map((p) => p.toJson()).toList();
    final String jsonString = jsonEncode(productsJson);
    final File outputFile = File(outputJsonPath);
    await outputFile.writeAsString(jsonString);
    print('Successfully saved processed data to $outputJsonPath');
  } catch (e) {
    print('Error saving products to JSON: $e');
  }

  print('\nData import process completed.');
}
