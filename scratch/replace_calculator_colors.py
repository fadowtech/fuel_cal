import os

def main():
    filepath = 'lib/main.dart'
    if not os.path.exists(filepath):
        print("File main.dart not found.")
        return
        
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    # We want to perform replacements only within the calculators range: lines 547 to 2780 (0-indexed 546 to 2779)
    start_idx = 546
    end_idx = min(2780, len(lines))
    
    replacements = {
        'const Color(0xFF1E1E24)': '_surfaceColor',
        'Color(0xFF1E1E24)': '_surfaceColor',
        'const Color(0xFF25252D)': '_cardColor',
        'Color(0xFF25252D)': '_cardColor',
        'const Color(0xFF171923)': '_surfaceColor',
        'Color(0xFF171923)': '_surfaceColor',
        'const Color(0xFF00FF88)': '_neonColor',
        'Color(0xFF00FF88)': '_neonColor',
        'const Color(0xFF8E92A2)': '_mutedColor',
        'Color(0xFF8E92A2)': '_mutedColor',
        'Colors.white': '_textColor',
        'const Color(0xFF050508)': '_backgroundColor',
        'Color(0xFF050508)': '_backgroundColor',
        'Colors.white70': '_textColor.withOpacity(0.7)',
        'Colors.white60': '_textColor.withOpacity(0.6)',
        'Colors.white54': '_textColor.withOpacity(0.54)',
        'Colors.white38': '_textColor.withOpacity(0.38)',
        'Colors.white30': '_textColor.withOpacity(0.3)',
        'Colors.white24': '_textColor.withOpacity(0.24)',
        'Colors.white12': '_textColor.withOpacity(0.12)',
        'Colors.white10': '_textColor.withOpacity(0.1)',
    }
    
    modified_count = 0
    for idx in range(start_idx, end_idx):
        original = lines[idx]
        modified = original
        for src, dest in replacements.items():
            modified = modified.replace(src, dest)
            
        if modified != original:
            lines[idx] = modified
            modified_count += 1
            
    print(f"Modified {modified_count} lines inside main.dart calculators section.")
    
    with open(filepath, 'w', encoding='utf-8', newline='') as f:
        f.writelines(lines)

if __name__ == '__main__':
    main()
