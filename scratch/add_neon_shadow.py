import os

files = [
    'lib/add_fuel_page.dart',
    'lib/add_expense_page.dart',
    'lib/add_reminder_page.dart',
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    old_str = """      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),"""
    new_str = """      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _neonColor,
            offset: const Offset(-4, 0),
            blurRadius: 0,
          ),
        ],
      ),"""
    
    content = content.replace(old_str, new_str)
    
    # Also handle cases with different indentation
    old_str2 = """            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
            ),"""
    new_str2 = """            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _neonColor,
                  offset: const Offset(-4, 0),
                  blurRadius: 0,
                ),
              ],
            ),"""
    content = content.replace(old_str2, new_str2)

    old_str3 = """        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),"""
    new_str3 = """        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _neonColor,
              offset: const Offset(-4, 0),
              blurRadius: 0,
            ),
          ],
        ),"""
    content = content.replace(old_str3, new_str3)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print("Replaced in all files.")
