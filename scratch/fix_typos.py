def main():
    filepath = 'lib/main.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    content = content.replace('_textColor70', '_textColor.withOpacity(0.7)')
    content = content.replace('_textColor60', '_textColor.withOpacity(0.6)')
    
    with open(filepath, 'w', encoding='utf-8', newline='') as f:
        f.write(content)
    print("Typos fixed!")

if __name__ == '__main__':
    main()
