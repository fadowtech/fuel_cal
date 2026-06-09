import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true);
  final skipFiles = ['currency_service.dart', 'mock_data.dart'];

  for (final entity in files) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final fileName = entity.uri.pathSegments.last;
      if (skipFiles.contains(fileName)) continue;

      var content = entity.readAsStringSync();
      if (content.contains('₹')) {
        content = content.replaceAll('₹', '\${CurrencyService.currencySymbol}');
        if (!content.contains('currency_service.dart')) {
          int importIndex = content.indexOf('import ');
          if (importIndex != -1) {
            content = content.replaceRange(importIndex, importIndex, "import 'package:fuel_cal/services/currency_service.dart';\n");
          } else {
            content = "import 'package:fuel_cal/services/currency_service.dart';\n" + content;
          }
        }
        entity.writeAsStringSync(content);
        print('Updated \${entity.path}');
      }
    }
  }
}
