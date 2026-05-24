import 'dart:io';
void main() {
  final file = File('lib/feature_pages.dart');
  final lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Current ODO')) {
      print('${i + 1}: ${lines[i]}');
    }
  }
}
