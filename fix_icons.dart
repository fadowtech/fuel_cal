import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true);
  final skipFiles = ['currency_service.dart'];

  for (final entity in files) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final fileName = entity.uri.pathSegments.last;
      if (skipFiles.contains(fileName)) continue;

      var content = entity.readAsStringSync();
      var updated = false;

      if (content.contains('Icons.currency_rupee_rounded')) {
        content = content.replaceAll('Icons.currency_rupee_rounded', 'CurrencyService.currentCurrencyIcon');
        updated = true;
      }
      if (content.contains('Icons.currency_rupee')) {
        content = content.replaceAll('Icons.currency_rupee', 'CurrencyService.currentCurrencyIconNotRounded');
        updated = true;
      }

      if (updated) {
        if (!content.contains('currency_service.dart')) {
          int importIndex = content.indexOf('import ');
          if (importIndex != -1) {
            content = content.replaceRange(importIndex, importIndex, "import 'package:fuel_cal/services/currency_service.dart';\n");
          } else {
            content = "import 'package:fuel_cal/services/currency_service.dart';\n" + content;
          }
        }
        entity.writeAsStringSync(content);
        print('Fixed \${entity.path}');
      }
    }
  }
}
