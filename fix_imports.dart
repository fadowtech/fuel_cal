import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true);

  for (final entity in files) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      var changed = false;
      
      if (content.contains('\$1')) {
        content = content.replaceAll('\$1', 'import \'package:flutter/material.dart\';');
        changed = true;
      }
      
      if (changed) {
        entity.writeAsStringSync(content);
        print('Fixed \${entity.path}');
      }
    }
  }
}
