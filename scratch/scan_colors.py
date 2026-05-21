import re

def main():
    with open('lib/main.dart', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    targets = [
        '0xFF050508', '0xFF1E1E24', '0xFF25252D', '0xFF171923', 
        '0xFF121217', '0xFF00FF88', '0xFF8E92A2', 'Colors.white', 
        'Colors.white70', 'Colors.white54', 'Colors.white38', 
        'Colors.white30', 'Colors.white24', 'Colors.white12', 'Colors.white10'
    ]
    
    print("Scanning main.dart lines 547 to 2780 for hardcoded colors...")
    for idx in range(546, min(2780, len(lines))):
        line = lines[idx]
        for t in targets:
            if t in line:
                print(f"{idx+1}: {line.strip()}")

if __name__ == '__main__':
    main()
