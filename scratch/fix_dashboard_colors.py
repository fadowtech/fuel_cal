def main():
    filepath = 'lib/dashboard_page.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Replace all static white icons and text colors
    replacements = {
        'Colors.white': '_textColor',
        'color: Colors.white,': 'color: _textColor,',
        'color: Colors.white': 'color: _textColor',
        'const TextStyle(\n                            color: Colors.white,': 'TextStyle(\n                            color: _textColor,',
        'const TextStyle(\n                        color: Colors.white,': 'TextStyle(\n                        color: _textColor,',
        'const TextStyle(\n                    color: Colors.white,': 'TextStyle(\n                    color: _textColor,',
        'color: Colors.white.withValues': 'color: _textColor.withValues',
    }
    
    for src, dest in replacements.items():
        content = content.replace(src, dest)
        
    with open(filepath, 'w', encoding='utf-8', newline='') as f:
        f.write(content)
    print("Dashboard colors fixed!")

if __name__ == '__main__':
    main()
