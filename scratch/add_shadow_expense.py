import re
import os

file_path = r"C:\Users\SHA256\Documents\fuel-cal\fuel_cal - 7 v1.0.5 - develope process\lib\add_expense_page.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

shadow_str = """,
                          boxShadow: [
                            BoxShadow(
                              color: _neonColor,
                              offset: const Offset(-4, 0),
                              blurRadius: 0,
                            ),
                          ]"""

# Fix Date card (no border)
content = content.replace(
    """                        decoration: BoxDecoration(
                          color: _surfaceColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),""",
    """                        decoration: BoxDecoration(
                          color: _surfaceColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),""" + shadow_str + """
                        ),"""
)

# Fix Category and Notes cards
shadow_str_8 = """,
        boxShadow: [
          BoxShadow(
            color: _neonColor,
            offset: const Offset(-4, 0),
            blurRadius: 0,
          ),
        ]"""

content = re.sub(
    r"(border: Border\.all\([^)]+\)),?\n\s*\)",
    r"\1" + shadow_str_8 + r"\n      )",
    content
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Replaced in add_expense_page.dart")
