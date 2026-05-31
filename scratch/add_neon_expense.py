import os

file = 'lib/add_expense_page.dart'
with open(file, 'r', encoding='utf-8') as f:
    content = f.read()

old_str = """          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.redAccent : _surfaceColor),
          ),"""
new_str = """          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.redAccent : _surfaceColor),
            boxShadow: [
              BoxShadow(
                color: _neonColor,
                offset: const Offset(-4, 0),
                blurRadius: 0,
              ),
            ]
          ),"""
content = content.replace(old_str, new_str)

old_str2 = """                      decoration: BoxDecoration(
                        color: _surfaceColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _surfaceColor),
                      ),"""
new_str2 = """                      decoration: BoxDecoration(
                        color: _surfaceColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _surfaceColor),
                        boxShadow: [
                          BoxShadow(
                            color: _neonColor,
                            offset: const Offset(-4, 0),
                            blurRadius: 0,
                          ),
                        ]
                      ),"""
content = content.replace(old_str2, new_str2)

with open(file, 'w', encoding='utf-8') as f:
    f.write(content)
