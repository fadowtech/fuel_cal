import os

files = [
    'lib/add_fuel_page.dart',
    'lib/add_expense_page.dart',
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace withOpacity(0.5)
    content = content.replace(
        "color: _surfaceColor.withOpacity(0.5),",
        "color: _cardColor,"
    )

    # Replace withValues(alpha: 0.5)
    content = content.replace(
        "color: _surfaceColor.withValues(alpha: 0.5),",
        "color: _cardColor,"
    )

    # Also for transparent in add_fuel_page.dart _buildCurrentStatusCard
    # decoration: BoxDecoration(
    #    color: Colors.transparent,
    #    borderRadius: BorderRadius.circular(16),
    content = content.replace(
        "color: Colors.transparent,\n        borderRadius: BorderRadius.circular(16),\n        border: Border.all(color: _neonColor.withOpacity(0.3)),\n        boxShadow:",
        "color: _cardColor,\n        borderRadius: BorderRadius.circular(16),\n        border: Border.all(color: _neonColor.withOpacity(0.3)),\n        boxShadow:"
    )

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print("Done fixing transparencies.")
