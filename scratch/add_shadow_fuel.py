import re
import os

file_path = r"C:\Users\SHA256\Documents\fuel-cal\fuel_cal - 7 v1.0.5 - develope process\lib\add_fuel_page.dart"

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

# Match: border: Border.all(...),
# and the closing parenthesis of the BoxDecoration on the next line(s)
content = re.sub(
    r"(border:\s*Border\.all\([^)]+\),?)\n\s*\)",
    r"\1" + shadow_str + r"\n          )",
    content
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Replaced in add_fuel_page.dart")
