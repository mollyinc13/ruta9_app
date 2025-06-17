import 'dart:io';
import '../lib/models/product_model.dart';
import '../lib/services/csv_parser.dart';
import '../lib/utils/local_data_tester.dart';

// Ensure this script can be run from the root of the project.
// CSV files are expected in a 'data/' directory at the project root.
const String productsCsvPath = 'data/productos.csv';
const String modifiersCsvPath = 'data/modificadores.csv';

Future<void> main() async {
  print('Starting data import process...');

  // Instantiate the parser
  final csvParser = CsvParser();

  // Check if CSV files exist
  if (!await File(productsCsvPath).exists()) {
    print('Error: $productsCsvPath not found. Please create it with product data.');
    exit(1);
  }
  if (!await File(modifiersCsvPath).exists()) {
    print('Error: $modifiersCsvPath not found. Please create it with modifier data.');
    exit(1);
  }

  // 1. Parse Products
  print('Parsing products from $productsCsvPath...');
  List<Product> products = await csvParser.parseProducts(productsCsvPath);
  if (products.isEmpty && File(productsCsvPath).lengthSync() > 50) { // Basic check if file has content but parsing failed
      print('No products parsed, but file seems to have data. Check CSV format and parser logic.');
  } else {
      print('Parsed ${products.length} products.');
  }


  // 2. Parse Modifiers Raw Data
  print('Parsing modifiers from $modifiersCsvPath...');
  List<Map<String, dynamic>> modifiersRawData = await csvParser.parseModifiersCsv(modifiersCsvPath);
  if (modifiersRawData.isEmpty && File(modifiersCsvPath).lengthSync() > 50) { // Basic check
      print('No modifiers parsed, but file seems to have data. Check CSV format and parser logic.');
  } else {
      print('Parsed ${modifiersRawData.length} raw modifier entries.');
  }


  // 3. Link Modifiers to Products
  print('Linking modifiers to products...');
  products = csvParser.linkModifiersToProducts(
    products: products,
    modifiersRawData: modifiersRawData,
  );
  print('Finished linking modifiers.');

  // 4. Test Processed Data (Print to Console)
  print('Displaying processed data (local test):');
  LocalDataTester.testProcessedData(products);

  print('\nData import process completed.');
  print('Next steps would involve uploading this processed data to Firestore.');
}
